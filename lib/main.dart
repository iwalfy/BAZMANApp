import 'package:flutter/material.dart';
import 'package:bazman/pages/home.dart';
import 'package:bazman/pages/settings.dart';
import 'package:bazman/pages/history.dart';
import 'package:bazman/pages/favourites.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.deepPurpleAccent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.deepPurpleAccent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.deepPurpleAccent,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.deepPurpleAccent,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
    ),
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blueAccent,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color.fromARGB(255, 61, 61, 61),
      contentTextStyle: TextStyle(
        color: Colors.white,
      ),
    ),
    tooltipTheme: const TooltipThemeData(
      textStyle: TextStyle(
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 61, 61, 61),
      )
    )
  ),
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
    '/settings': (context) => const Settings(),
    '/history': (context) => const History(),
    '/favourites': (context) => const Favourites(),
  },
));
