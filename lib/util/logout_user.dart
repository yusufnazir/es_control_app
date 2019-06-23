import 'package:es_control_app/preferences.dart';
import 'package:flutter/material.dart';

void logoutUser(BuildContext context) async {
  await Preferences.writeCredentials("");
  await Preferences.writeUsername("");
  Navigator.of(context)
      .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
}
