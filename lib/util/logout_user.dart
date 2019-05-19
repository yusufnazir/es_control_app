import 'package:es_control_app/file_storage.dart';
import 'package:flutter/material.dart';

void logoutUser(BuildContext context) async {
  await FileStorage.writeCredentials("");
  await FileStorage.writeUsername("");
  Navigator.of(context)
      .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
}
