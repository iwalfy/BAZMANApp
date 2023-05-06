import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../models/base.dart';
import '../models/history.dart';
import '../models/settings.dart';
import '../utils.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool prefsLoaded = false;
  List<HistoryEntry> history = [];
  String _result = 'Давно тебя не было в уличных гонках...';
  List<Base> bases = [];
  var uuid = const Uuid();
  late String currentResultUuid;

  SettingsController settings = SettingsController();
  HistoryController historyController = HistoryController();

  late PackageInfo packageInfo;

  Future<void> _loadSettings() async {
    await settings.loadSettings();
    history = await historyController.loadHistory();
    packageInfo = await PackageInfo.fromPlatform();
    prefsLoaded = true;
  }

  Future<List<Base>> _getBases() async {
    await _loadSettings();
    if (bases.isEmpty && prefsLoaded) {
      bases = await BaseController(serverUrl: settings.serverUrl).loadBases();
    }
    return bases;
  }

  Future<void> _addToHistory(int base, String text) async {
    if (history.length > settings.historyDepth) {
      history.removeRange(settings.historyDepth, history.length);
    }
    HistoryEntry newHistoryEntry = HistoryEntry(
      base: bases[base].name,
      baseNum: base,
      text: text,
      uuid: currentResultUuid,
      time: DateTime.now(),
    );
    history.add(newHistoryEntry);
    historyController.saveHistory();
  }

  Future<void> _genBase(int num) async {
    String url = '${settings.serverUrl}/gen?num=$num';
    currentResultUuid = uuid.v4();
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _result = response.body;
        _addToHistory(num, _result);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    var availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
        title: const Text('BAZMAN'),
        centerTitle: true,
        flexibleSpace: Image(
          image: const AssetImage('assets/background.jpg'),
          fit: BoxFit.cover,
          color: Colors.white.withOpacity(0.4),
          colorBlendMode: BlendMode.modulate,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/history');
            },
            icon: const Icon(Icons.history),
            tooltip: AppLocalizations.of(context)!.history,
          ),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem<int> (
                  value: 1,
                  child: ListTile(
                    leading: const Icon(Icons.favorite),
                    title: Text(AppLocalizations.of(context)!.favourites),
                  ),
                ),
                PopupMenuItem<int> (
                  value: 2,
                  child: ListTile(
                    leading: const Icon(Icons.settings),
                    title: Text(AppLocalizations.of(context)!.settings),
                  ),
                ),
                PopupMenuItem<int> (
                  value: 3,
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(AppLocalizations.of(context)!.aboutApp),
                  ),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 1:
                  Navigator.pushNamed(context, '/favourites');
                  break;
                case 2:
                  Navigator.pushNamed(context, '/settings').then((_){
                    setState((){
                      bases = [];
                    });
                  });
                  break;
                case 3:
                  showAboutDialog(
                    context: context,
                    applicationName: 'BAZMAN App',
                    applicationVersion: packageInfo.version,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.appDesc),
                          TextButton.icon(
                            onPressed: () => openUrl("https://github.com/Catware-Foundation"),
                            label: const Text('GitHub'),
                            icon: const Icon(Icons.link),
                          ),
                          TextButton.icon(
                            onPressed: () => openUrl("https://ctw.re"),
                            label: const Text('Catware'),
                            icon: const Icon(Icons.link),
                          ),
                          TextButton.icon(
                            onPressed: () => openUrl("https://github.com/iwalfy/BAZMANApp"),
                            label: Text(AppLocalizations.of(context)!.sourceCode),
                            icon: const Icon(Icons.code),
                          ),
                        ],
                      )
                    ]
                  );
                  break;
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: availableHeight / 3,
              width: ((){
                if (MediaQuery.of(context).size.width <= 600) {
                  return MediaQuery.of(context).size.width;
                } else {
                  return 600.0;
                }
              }()),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: availableHeight / 3.2,
                      width: ((){
                        if (MediaQuery.of(context).size.width <= 600) {
                          return MediaQuery.of(context).size.width / 1.3;
                        } else {
                          return 460.0;
                        }
                      }()),
                      child: Center(
                        child: ShaderMask(
                          shaderCallback: (Rect rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
                              stops: [0.0, 0.1, 0.9, 1.0],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstOut,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              _result,
                              style: const TextStyle(
                                fontSize: 24,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () => copyToClipboard(_result, context),
                          icon: const Icon(Icons.copy),
                          tooltip: AppLocalizations.of(context)!.copyToClipboard,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border),
                          tooltip: AppLocalizations.of(context)!.addToFavourites,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: availableHeight / 1.5,
              width: ((){
                if (MediaQuery.of(context).size.width <= 600) {
                  return MediaQuery.of(context).size.width;
                } else {
                  return 600.0;
                }
              }()),
              child: FutureBuilder(
                future: _getBases(),
                builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!.failedToLoadBases,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }
                  if (snapshot.data == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (ctx, index) => ListTile(
                        title: Text(snapshot.data[index].name),
                        subtitle: Text(snapshot.data[index].description),
                        onTap: () => _genBase(index),
                        onLongPress: () => showToast(snapshot.data[index].author, context),
                        contentPadding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
