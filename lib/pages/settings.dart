import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _serverUrlController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await _prefs;
    _serverUrlController.text = prefs.getString('serverUrl') ?? '';
  }
  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('serverUrl', _serverUrlController.text);
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
          image: const AssetImage('assets/background.png'),
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
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
              ),
              controller: _serverUrlController,
              autocorrect: false,
            ),
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
