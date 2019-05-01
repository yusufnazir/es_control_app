import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileStorage{

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localCredentialsFile async {
    final path = await _localPath;
    return File('$path/credentials.txt');
  }

  static Future<File> get _localUsernameFile async {
    final path = await _localPath;
    return File('$path/username.txt');
  }

  static Future<String> readCredentials() async {
    try {
      final file = await _localCredentialsFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  static Future<File> writeCredentials(String credentials) async {
    final file = await _localCredentialsFile;

    // Write the file
    return file.writeAsString('$credentials');
  }

  static Future<String> readUsername() async {
    try {
      final file = await _localUsernameFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  static Future<File> writeUsername(String username) async {
    final file = await _localUsernameFile;

    // Write the file
    return file.writeAsString('$username');
  }

}