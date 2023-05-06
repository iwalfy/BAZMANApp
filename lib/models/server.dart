import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

class ServerController {
  List<ServerEntry> publicServers = [];
  List<ServerEntry> serverCache = [];

  ServerController();

  Future<void> cacheServerList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("servercache", json.encode(publicServers));
  }

  Future<List<ServerEntry>> getServerList() async {
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
    if (publicServers != []) {
      serverCache = publicServers;
      cacheServerList();
    }

    return publicServers;
  }
}