import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class ServerEntry {
  final int id;
  final String name;
  final String title;
  final String url;
  final String owner;
  final String uuid;

  ServerEntry({
    required this.id,
    required this.name,
    required this.title,
    required this.url,
    required this.owner,
    required this.uuid,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "title": title,
    "url": url,
    "owner": owner,
    "uuid": uuid
  };
}

class _SettingsState extends State<Settings> {
  final TextEditingController _serverUrlController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String serverStatus = "Checking...";
  String serverUrl = '';
  bool prefsLoaded = false;
  bool serverListCached = false;
  bool showFromCache = false;
  late SharedPreferences prefs;
  List<ServerEntry> publicServers = [];
  List<ServerEntry> serverCache = [];

  Future<void> _loadSettings() async {
    prefs = await _prefs;
    serverUrl = prefs.getString('serverUrl') ?? 'https://bmapi.ctw.re';
    if (serverUrl == '') {
      serverUrl = 'https://bmapi.ctw.re';
    }
    _serverUrlController.text = serverUrl;
    prefsLoaded = true;
    checkServer();
  }
  Future<void> _saveSettings() async {
    prefs.setString('serverUrl', _serverUrlController.text);
  }

  Future<void> checkServer() async {
    if (prefsLoaded) {
      try {
        String url = '$serverUrl/bmd';
        final response = await http.get(Uri.parse(url));
        if (response.body.contains("BAZMAN SERVER")) {
          serverStatus = "OK";
        } else {
          serverStatus = "DOWN";
        }
      } catch(error) {
        serverStatus = "DOWN";
      }
      setState(() {});
    }
  }

  Future<List<ServerEntry>> getServerList() async {
    if (publicServers.isEmpty && prefsLoaded) {
      String url = 'https://bazman.ctw.re/data/public_servers.json';
      final response = await http.get(Uri.parse(url));
      var responseData = json.decode(response.body);
      var servers = responseData["servers"];

      publicServers = [];
      for (var currentServer in servers) {
        ServerEntry server = ServerEntry(
          id: currentServer["id"],
          name: currentServer["name"],
          title: currentServer["title"],
          url: currentServer["url"],
          owner: currentServer["owner"],
          uuid: currentServer["uuid"]
        );
        publicServers.add(server);
      }
      prefs.setString("servercache", json.encode(publicServers));
    }

    return publicServers;
  }

  Future<void> setServer(String url) async {
    serverUrl = url;
    _serverUrlController.text = url;
    setState(() {
      serverStatus = "Checking...";
      checkServer();
    });
  }

  Future<void> showServerList(BuildContext context) async {
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.selectServer),
      content: SizedBox (
        width: 400,
        height: 500,
        child: FutureBuilder(
          future: getServerList(),
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            var servers = snapshot.data;
            if (snapshot.hasError) {
              var serverCacheData = json.decode(prefs.getString('servercache') ?? '[]');
              if (serverCache.isEmpty) {
                for (var currentServer in serverCacheData) {
                  ServerEntry server = ServerEntry(
                    id: currentServer["id"],
                    name: currentServer["name"],
                    title: currentServer["title"],
                    url: currentServer["url"],
                    owner: currentServer["owner"],
                    uuid: currentServer["uuid"],
                  );
                  serverCache.add(server);
                }
              }
              if (serverCache.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.failedToLoadServers,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.red,
                    ),
                  ),
                );
              }
              servers = serverCache;
              showFromCache = true;
            }
            if (servers == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Column(
                children: [
                  showFromCache ? Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Text(
                      AppLocalizations.of(context)!.failedToLoadServersCache,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ) : Container(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: servers.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          title: Text(servers[index].title),
                          subtitle: Text(servers[index].owner + '\n' + servers[index].url),
                          onTap: () {
                            setServer(servers[index].url);
                            Navigator.pop(context);
                          },
                          contentPadding: const EdgeInsets.only(
                              left: 15, right: 15, top: 8, bottom: 8),
                        );
                      }
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        centerTitle: true,
        flexibleSpace: Image(
          image: const AssetImage('assets/background.jpg'),
          fit: BoxFit.cover,
          color: Colors.white.withOpacity(0.4),
          colorBlendMode: BlendMode.modulate,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.customServerText),
            TextFormField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.customServer,
                suffixIcon: TextButton(
                  onPressed: (){
                    showServerList(context);
                  },
                  child: Text(AppLocalizations.of(context)!.selectServer),
                )
              ),
              controller: _serverUrlController,
              autocorrect: false,
            ),
            RichText(text: TextSpan(
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)!.serverStatus,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color
                  )
                ),
                TextSpan(
                  text: serverStatus,
                  style: TextStyle(
                    color: ((){
                      if (serverStatus == "Checking...") {
                        return Colors.orangeAccent;
                      } else if (serverStatus == "OK") {
                        return Colors.green;
                      } else {
                        return Colors.red;
                      }
                    }()),
                  )
                )
              ]
            ))
            //Text(AppLocalizations.of(context)!.selectLanguage),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveSettings().then((value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)!.settingsSaved)
            ));
            Navigator.pop(context);
          });
        },
        tooltip: AppLocalizations.of(context)!.saveSettings,
        child: const Icon(Icons.save),
      ),
    );
  }
}
