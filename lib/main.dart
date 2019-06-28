// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:es_control_app/constants.dart';
import 'package:es_control_app/home.dart';
import 'package:es_control_app/l10n/localizations.dart';
import 'package:es_control_app/login/login_page.dart';
import 'package:es_control_app/preferences.dart';
import 'package:es_control_app/surveys_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RouteObserver<PageRoute> routeObserver = new RouteObserver<PageRoute>();

void main() {
  ThemeData _buildShrineTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      accentColor: Constants.accentColor,
      primaryColor: Constants.primaryColor,
      primaryColorLight: Constants.primaryColorLight,
      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: Constants.primaryColor,
        textTheme: ButtonTextTheme.normal,
      ),
      scaffoldBackgroundColor: Constants.kShrineBackgroundWhite,
      cardColor: Constants.kShrineBackgroundWhite,
      textSelectionColor: Constants.primaryColor,
      errorColor: Constants.kShrineErrorRed,
      // TODO: Add the text themes (103)
      // TODO: Add the icon themes (103)
      // TODO: Decorate the inputs (103)
    );
  }

  final ThemeData _kShrineTheme = _buildShrineTheme();

  runApp(new MaterialApp(
    navigatorObservers: <NavigatorObserver>[routeObserver],
    localizationsDelegates: [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate
    ],
    supportedLocales: [Locale("en")],
    onGenerateTitle: (BuildContext context) =>
        AppLocalizations.of(context).title,
    home: MyApp(),
    theme: _kShrineTheme,
    routes: {
      '/login': (context) => LoginPage(),
      '/home': (context) => Home(),
      '/surveys': (context) => SurveysListingPage()
    },
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: toLoginOrNot(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return snapshot.data;
          } else {
            return Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Image.asset('images/es_controls.jpg'),
                ));
          }
        });
  }

  toLoginOrNot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await Future.delayed(Duration(seconds: 2));
    String credentials = await Preferences.readCredentials();
    if (credentials == null || credentials.trim().isEmpty) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/surveys', (Route<dynamic> route) => false);
    }
  }
//    return new SplashScreen(
//        seconds: 1,
//        navigateAfterSeconds: new SurveysListingPage(),
//        title: new Text(
//          'Welcome In SplashScreen',
//          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
//        ),
////        image: new Image.network('https://i.imgur.com/TyCSG9A.png'),
//        backgroundColor: Colors.white,
//        styleTextUnderTheLoader: new TextStyle(),
//        photoSize: 100.0,
//        onClick: () => print("Flutter Egypt"),
//        loaderColor: Colors.red);
//  }
}

class AfterSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("Welcome In SplashScreen Package"),
          automaticallyImplyLeading: false),
      body: new Center(
        child: new Text(
          "Done!",
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
        ),
      ),
    );
  }
}

//class MyApp extends StatelessWidget {
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      localizationsDelegates: [
//        AppLocalizationsDelegate(),
//        GlobalMaterialLocalizations.delegate,
//        GlobalWidgetsLocalizations.delegate
//      ],
//      supportedLocales: [Locale("en")],
//      onGenerateTitle: (BuildContext context) =>
//          AppLocalizations.of(context).title,
//      theme: ThemeData(
//        primarySwatch: Colors.blue,
//      ),
//      home: LoginPage(),
//    );
//  }
//}

//class MyStatelessWidget extends StatelessWidget {
//  MyStatelessWidget({Key key}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text(AppLocalizations.of(context).title),
//        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.shopping_cart),
//            tooltip: 'Open shopping cart',
//            onPressed: () {
//              // ...
//            },
//          ),
//        ],
//      ),
//    );
//  }
//}
