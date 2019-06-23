import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences{

//  static Future<String> get _localPath async {
//    final directory = await getApplicationDocumentsDirectory();
//    return directory.path;
//  }

//  static Future<File> get _localCredentialsFile async {
//    final path = await _localPath;
//    return File('$path/credentials.txt');
//  }

//  static Future<File> get _localUsernameFile async {
//    final path = await _localPath;
//    return File('$path/username.txt');
//  }

  static Future<String> readCredentials() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
//      final file = await _localCredentialsFile;

      // Read the file
      String credentials = prefs.getString('credentials');
//      String contents = await file.readAsString();

      return credentials;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  static writeCredentials(String credentials) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
//    final file = await _localCredentialsFile;

    // Write the file
    prefs.setString('credentials', credentials);
  }

  static Future<String> readUsername() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
//      final file = await _localUsernameFile;

      // Read the file
      String username = prefs.getString('username');
//      String contents = await file.readAsString();

      return username;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  static writeUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
//    final file = await _localUsernameFile;

    // Write the file
    prefs.setString('username', username);
//    return file.writeAsString('$username');
  }

//  static Future<String> getAppversion() async {
//    try {
//      final file = await _localUsernameFile;
//
//      // Read the file
//      String contents = await file.readAsString();
//
//      return contents;
//    } catch (e) {
//      // If encountering an error, return 0
//      return "";
//    }
//  }

}