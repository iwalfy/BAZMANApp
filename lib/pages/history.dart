import 'dart:convert';

import 'package:bazman/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class HistoryEntry {
  final int baseNum;
  final String base;
  final String text;
  final DateTime time;
  final String uuid;

  HistoryEntry({
    required this.base,
    required this.text,
    required this.time,
    required this.baseNum,
    required this.uuid
  });

  Map<String, dynamic> toJson() => {
    "base": base,
    "text": text,
    "time": time.millisecondsSinceEpoch,
    "baseNum": baseNum,
    "uuid": uuid
  };
}

class _HistoryState extends State<History> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late SharedPreferences prefs;
  List<Base> bases = [];
  List<HistoryEntry> history = [];
  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  Future<void> clearHistory() async {
    prefs = await _prefs;
    prefs.setString("history", stringToBase64.encode("[]"));
    setState(() {
      history = [];
    });
  }

  Future<void> _showToast(String msg) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  Future<void> _copyToClipboard(String result) async {
    Clipboard.setData(ClipboardData(text: result));
    _showToast(AppLocalizations.of(context)!.copiedToClipboard);
  }

  Future<void> loadHistory() async {
    prefs = await _prefs;
    var historyB64 = stringToBase64.decode(prefs.getString("history") ?? '');
    var historyData = [];
    if (historyB64 != '') {
      historyData = json.decode(historyB64);
    }

    /*var basecache = json.decode(prefs.getString("basecache") ?? "[]");
    for (var currentBase in basecache) {
      Base base = Base(
        name: currentBase['name'],
        description: currentBase['description'],
        author: currentBase['author'],
        path: currentBase['path'],
      );
      bases.add(base);
    }*/

    history = [];
    for (var historyEntryData in historyData) {
      HistoryEntry historyEntry = HistoryEntry(
        base: historyEntryData["base"],
        text: historyEntryData["text"],
        baseNum: historyEntryData["baseNum"],
        uuid: historyEntryData["uuid"],
        time: DateTime.fromMillisecondsSinceEpoch(historyEntryData["time"])
      );
      history.insert(0, historyEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.history),
        centerTitle: true,
        flexibleSpace: Image(
          image: const AssetImage('assets/background.png'),
          fit: BoxFit.cover,
          color: Colors.white.withOpacity(0.4),
          colorBlendMode: BlendMode.modulate,
        ),
        actions: [
          IconButton(
            onPressed: () {
              clearHistory();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete),
            tooltip: AppLocalizations.of(context)!.clearHistory,
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: loadHistory(),
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            if (history.isEmpty) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.nothingToSeeHere,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: history.length + 1,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index != history.length) {
                  return Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 800,
                      child: MouseRegion(
                        child: ListTile(
                          hoverColor: Colors.transparent,
                          contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          title: Text(history[index].text),
                          subtitle: Text("${DateFormat("yyyy-MM-dd HH:mm:ss").format(history[index].time)} - ${history[index].base}"),
                          onTap: () => _copyToClipboard(history[index].text),
                          trailing: IconButton(
                            onPressed: (){},
                            icon: const Icon(Icons.favorite_border),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.noMoreHistory,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  );
                }
              }
            );
          },
        ),
      ),
    );
  }
}
