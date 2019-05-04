import 'package:flutter/material.dart';

class Constants{

  static double borderRadius = 5.0;

  static Color primaryColor = const Color(0xFF33691e);
  static Color primaryColorLight = const Color(0xFF629749);
  static Color primaryColorLighter = const Color(0xFFD3FFBF);
  static Color accentColor = const Color(0xFFffd600);
  static Color accentColorLight = const Color(0xFFffff52);
  static Color kShrinePink50 = const Color(0xFFFEEAE6);
  static Color kShrinePink300 = const Color(0xFFFBB8AC);
  static Color kShrinePink400 = const Color(0xFFEAA4A4);
  static Color kShrineErrorRed = const Color(0xFFC5032B);
  static Color cardHeaderColor = const Color(0xFFffd740);
  static Color kShrineBackgroundWhite = Colors.white;

  static Color dark = const Color(0xFF3B4254);
  static Color accent = const Color(0xFF32C4E6);

  static String host = "http://192.168.0.105:9300/escontrol/";
  static String tokenUri = host + "oauth/token";

  static String getAllSurveys = host + "rest/api/v1/surveys/";
  static String getAllSurveyResponses = host + "rest/api/v1/surveyResponses/";

  static String dateFormat = "yyyy-MM-dd HH:mm";
  static String dateFormatPrecise = "yyyy-MM-dd HH:mm:ss";

  static String client = "escontrol";
  static String clientSecret = "escontrol";
}