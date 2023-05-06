import 'package:shared_preferences/shared_preferences.dart';

class SettingsController {
  String serverUrl = '';
  int historyDepth = 500;
  int fontSize = 24;
  int theme = 0; // 0 - auto, 1 - light, 2 - dark, 3 - black

  SettingsController();

  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // load server url. if not present use default
    serverUrl = prefs.getString("serverUrl") ?? 'https://bmapi.ctw.re';
    if (serverUrl == '') serverUrl = 'https://bmapi.ctw.re';

    // check if history depth not higher than 5000 in case user increase this value himself
    historyDepth = prefs.getInt("historyDepth") ?? 500;
    if (historyDepth > 5000 || historyDepth < 10) historyDepth = 500;

    // load font size
    fontSize = prefs.getInt("fontSize") ?? 24;
    if (fontSize > 72 || fontSize < 12) fontSize = 24;

    // use light theme if invalid theme set
    theme = prefs.getInt("fontSize") ?? 0;
    if (theme > 2 || theme < 0) theme = 0;
  }

  Future<void> saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("serverUrl", serverUrl);
    prefs.setInt("historyDepth", historyDepth);
    prefs.setInt("fontSize", fontSize);
    prefs.setInt("theme", theme);
  }
}