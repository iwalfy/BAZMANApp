import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils.dart';

class Base {
  final String name;
  final String description;
  final String author;
  final String path;

  Base({
    required this.name,
    required this.description,
    required this.author,
    required this.path,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "description": description,
    "author": author,
    "path": path
  };
}

class BaseController {
  final String serverUrl;
  List<Base> bases = [];

  BaseController({required this.serverUrl});

  Future<void> saveToCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("basecache", stringToBase64.encode(json.encode(bases)));
  }

  Future<List<Base>> loadBases() async {
    String url = '$serverUrl/bases';
    final response = await http.get(Uri.parse(url));

    var responseData = json.decode(response.body);

    bases = [];
    for (var currentBase in responseData) {
      Base base = Base(
        name: currentBase['name'],
        description: currentBase['description'],
        author: currentBase['author'],
        path: currentBase['path'],
      );
      bases.add(base);
    }
    saveToCache();

    return bases;
  }
}