import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

Codec<String, String> stringToBase64 = utf8.fuse(base64);

Future<void> showToast(String msg, BuildContext context) async {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
  ));
}

Future<void> copyToClipboard(String text, BuildContext context) async {
  Clipboard.setData(ClipboardData(text: text));
  showToast(AppLocalizations.of(context)!.copiedToClipboard, context);
}

Future<void> openUrl(String url) async {
  if (!await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Could not launch $url';
  }
}
