import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';

class HistoryEntry {
  final int baseNum;
  final String base;
  final String text;
  final DateTime time;
  final String uuid;
  final String sourceServer;

  HistoryEntry({
    required this.base,
    required this.text,
    required this.time,
    required this.baseNum,
    required this.uuid,
    this.sourceServer = ""
  });

  Map<String, dynamic> toJson() => {
    "base": base,
    "text": text,
    "time": time.millisecondsSinceEpoch,
    "baseNum": baseNum,
    "uuid": uuid,
    "sourceServer": sourceServer,
  };
}

class HistoryController {
  List<HistoryEntry> history = [];

  HistoryController();

  Future<List<HistoryEntry>> loadHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var historyB64 = stringToBase64.decode(prefs.getString('history') ?? '');
    var historyData = [];
    if (historyB64 != '') historyData = json.decode(historyB64);

    history = [];
    for (var historyEntryData in historyData) {
      HistoryEntry historyEntry = HistoryEntry(
          base: historyEntryData["base"],
          text: historyEntryData["text"],
          baseNum: historyEntryData["baseNum"],
          uuid: historyEntryData["uuid"],
          time: DateTime.fromMillisecondsSinceEpoch(historyEntryData["time"])
      );
      history.add(historyEntry);
    }

    return history;
  }

  Future<void> saveHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("history", stringToBase64.encode(json.encode(history)));
  }

  Future<void> clearHistory() async {
    history = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("history", "");
  }
}