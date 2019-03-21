// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:es_control_app/home.dart';
import 'package:es_control_app/l10n/localizations.dart';
import 'package:es_control_app/login/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  runApp(new MaterialApp(
    localizationsDelegates: [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate
    ],
    supportedLocales: [Locale("en")],
    onGenerateTitle: (BuildContext context) =>
        AppLocalizations.of(context).title,
    home: new MyApp(),
    routes: {
      '/login': (context) => LoginPage(),
      '/home': (context) => Home()
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
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 5,
        navigateAfterSeconds: new LoginPage(),
        title: new Text(
          'Welcome In SplashScreen',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image: new Image.network('https://i.imgur.com/TyCSG9A.png'),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        onClick: () => print("Flutter Egypt"),
        loaderColor: Colors.red);
  }
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