import 'package:flutter/material.dart';
import 'package:bazman/pages/home.dart';
import 'package:bazman/pages/settings.dart';
import 'package:bazman/pages/history.dart';
import 'package:bazman/pages/favourites.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'models/themes.dart';

void main() {
  runApp(const BAZMANApp());
}

class BAZMANApp extends StatelessWidget {
  const BAZMANApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      themeMode: ThemeMode.system,
      title: 'BAZMAN',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ru', ''),
        Locale('uk', ''),
      ],
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/settings': (context) => const SettingsPage(),
        '/history': (context) => const History(),
        '/favourites': (context) => const Favourites(),
      },
    );
  }
}
