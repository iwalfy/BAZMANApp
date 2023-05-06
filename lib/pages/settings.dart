import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import '../models/server.dart';
import '../models/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _serverUrlController = TextEditingController();
  String serverStatus = "Checking...";
  bool prefsLoaded = false;
  bool serverListCached = false;
  bool showFromCache = false;
  List<ServerEntry> publicServers = [];
  List<ServerEntry> serverCache = [];

  String selectedLang = "";

  SettingsController settings = SettingsController();
  ServerController serverController = ServerController();

  Future<void> _loadSettings() async {
    await settings.loadSettings();
    _serverUrlController.text = settings.serverUrl;
    prefsLoaded = true;
    checkServer();
  }

  Future<void> _saveSettings() async {
    settings.saveSettings();
  }

  Future<void> checkServer() async {
    serverStatus = "Checking...";
    if (prefsLoaded) {
      try {
        String url = '${settings.serverUrl}/bmd';
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
    publicServers = await serverController.getServerList();
    serverCache = serverController.serverCache;
    return publicServers;
  }

  Future<void> setServer(String url) async {
    settings.serverUrl = url;
    _serverUrlController.text = url;
    setState(() {
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
      body: Center(
        child: SizedBox(
          width: 800,
          child: Container(
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
                )),
                //Text(AppLocalizations.of(context)!.selectLanguage),
              ],
            ),
          ),
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
