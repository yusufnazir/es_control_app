import 'package:es_control_app/constants.dart';
import 'package:es_control_app/file_storage.dart';
import 'package:es_control_app/routes.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _usernameFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _username = "";
  String _password = "";
  int _state = 0;
  AnimationController _controller;
  GlobalKey _globalKey = GlobalKey();

  _LoginPageState() {
    _usernameFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _emailListen() {
    if (_usernameFilter.text.isEmpty) {
      _username = "";
    } else {
      _username = _usernameFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appNameFld = Text(
      "Elevator Survey",
      style: TextStyle(
        color: Constants.accentColor,
        fontWeight: FontWeight.bold,
        fontSize: 40,
      ),
    );

    final emailField = TextField(
      controller: _usernameFilter,
      obscureText: false,
      style: TextStyle(
          fontFamily: 'Montserrat', fontSize: 20.0, color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.person,
          size: 40,
          color: Colors.white,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.0),
        ),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Username",
        hintStyle: TextStyle(color: Colors.white),
        labelText: "Enter your username",
        labelStyle: TextStyle(color: Colors.white),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
    final passwordField = TextField(
        controller: _passwordFilter,
        obscureText: true,
        style: TextStyle(
            fontFamily: 'Montserrat', fontSize: 20.0, color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock,
            size: 40,
            color: Colors.white,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.0),
          ),
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          hintStyle: TextStyle(color: Colors.white),
          labelText: "Enter your password",
          labelStyle: TextStyle(color: Colors.white),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ));
    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.white,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          if (_state == 0) {
            animateButton();
          }
        },
        child: setUpButtonChild(),
      ),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [
              0.1,
              0.5,
              0.7,
              0.9
            ],
                colors: [
              // Colors are easy thanks to Flutter's Colors class.
              Colors.green[800],
              Colors.green[700],
              Colors.green[600],
              Colors.green[400],
            ])),
        child: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                Center(
                  child: Container(
                    key: _globalKey,
//                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
//                SizedBox(
//                  height: 155.0,
//                  child: Image.asset(
//                    "assets/logo.png",
//                    fit: BoxFit.contain,
//                  ),
//                ),
                          SizedBox(height: 45.0),
                          appNameFld,
                          SizedBox(height: 90.0),
                          emailField,
                          SizedBox(height: 25.0),
                          passwordField,
                          SizedBox(
                            height: 60.0,
                          ),
                          loginButton,
                          SizedBox(
                            height: 15.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  loginUser() async {
    // This URL is an endpoint that's provided by the authorization server. It's
// usually included in the server's documentation of its OAuth2 API.
    final authorizationEndpoint = Uri.parse(Constants.tokenUri);

// The user should supply their own username and password.
//    final username = "example user";
//    final password = "example password";

// The authorization server may issue each client a separate client
// identifier and secret, which allows the server to tell which client
// is accessing it. Some servers may also have an anonymous
// identifier/secret pair that any client may use.
//
// Some servers don't require the client to authenticate itself, in which case
// these should be omitted.

// Make a request to the authorization endpoint that will produce the fully
// authenticated Client.
    try {
      var client = await oauth2.resourceOwnerPasswordGrant(
          authorizationEndpoint, _username, _password,
          identifier: Constants.client, secret: Constants.clientSecret);
      FileStorage.writeCredentials(client.credentials.toJson());
      FileStorage.writeUsername(_username);
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.surveys, (Route<dynamic> route) => false);
    } catch (e) {
      print(e.toString());
      setState(() {
        _state = 0;
      });
      Flushbar(
        duration: Duration(seconds: 8),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        isDismissible: true,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        title: "Login error.",
        message: "Please check your credentials and try again.",
        backgroundGradient: LinearGradient(
          colors: [Colors.red[400], Colors.red[600]],
        ),
        boxShadows: <BoxShadow>[
          BoxShadow(
            color: Colors.red[800],
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0,
          )
        ],
      )..show(context);
    }

//    var string = new File("~/.escontrol/credentials.json").readAsStringSync();
//    oauth2.Client cl = oauth2.Client(oauth2.Credentials.fromJson(string));

// Once you have the client, you can use it just like any other HTTP client.
//    var result = await client.read("http://example.com/protected-resources.txt");

// Once we're done with the client, save the credentials file. This will allow
// us to re-use the credentials and avoid storing the username and password
// directly.
  }

  void animateButton() {
    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _controller.forward();

    setState(() {
      _state = 1;
    });
    FocusScope.of(context).requestFocus(new FocusNode());
    loginUser();
  }

  setUpButtonChild() {
    if (_state == 0) {
      return Text(
        "Sign in",
        style: const TextStyle(
          color: Colors.green,
          fontSize: 25,
        ),
      );
    } else if (_state == 1) {
      return SizedBox(
        height: 36,
        width: 36,
        child: CircularProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    } else {
      return Icon(Icons.check, color: Colors.green);
    }
  }
}
