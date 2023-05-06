import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../models/history.dart';
import '../utils.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<HistoryEntry> history = [];
  HistoryController historyController = HistoryController();

  Future<void> clearHistory() async {
    history = [];
    historyController.clearHistory();
    setState(() {});
  }
  Future<void> loadHistory() async {
    history = await historyController.loadHistory();
    history = history.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.history),
        centerTitle: true,
        flexibleSpace: Image(
          image: const AssetImage('assets/background.jpg'),
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
                      child: ListTile(
                        hoverColor: Colors.transparent,
                        contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        title: Text(history[index].text),
                        subtitle: Text("${DateFormat("yyyy-MM-dd HH:mm:ss").format(history[index].time)} - ${history[index].base}"),
                        onTap: () => copyToClipboard(history[index].text, context),
                        trailing: IconButton(
                          onPressed: (){},
                          icon: const Icon(Icons.favorite_border),
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
