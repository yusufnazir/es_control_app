import 'package:es_control_app/constants.dart';
import 'package:es_control_app/file_storage.dart';
import 'package:es_control_app/routes.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:oauth2/oauth2.dart';
import 'package:progress_hud_v2/progress_hud.dart';
import 'FormType.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  final TextEditingController _usernameFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _username = "";
  String _password = "";
  FormType _form = FormType
      .login; // our default setting is to login, and we should switch to creating an account when the user chooses to
  int _state = 0;
  Animation _animation;
  AnimationController _controller;
  ProgressHUD _progressHUD;
  GlobalKey _globalKey = GlobalKey();
  bool _loading = true;
  double _width = double.maxFinite;

  _LoginPageState() {
    _usernameFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
  }

  @override
  void initState() {
    _progressHUD = new ProgressHUD(
      loading: _loading,
      backgroundColor: Colors.black12,
      color: Colors.white,
      containerColor: Constants.primaryColorLighter,
      borderRadius: 5.0,
    );
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

  // Swap in between our two forms, registering and logging in
  void _formChange() async {
    setState(() {
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextField(
      controller: _usernameFilter,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Username",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextField(
      controller: _passwordFilter,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Constants.primaryColor,
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
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Center(
                child: Container(
                  key: _globalKey,
                  color: Colors.white,
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
                        emailField,
                        SizedBox(height: 25.0),
                        passwordField,
                        SizedBox(
                          height: 35.0,
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
    );
  }

  void _loginPressed() {
//    getQuote();
    getSurveysFromServer();
//    _launchURL();
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => Home()),
//    );
  }

  getSurveysFromServer() async {
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
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.surveys, (Route<dynamic> route) => false);
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
        boxShadow: BoxShadow(
          color: Colors.red[800],
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        ),
      )..show(context);
    }

//    var string = new File("~/.escontrol/credentials.json").readAsStringSync();
//    oauth2.Client cl = oauth2.Client(oauth2.Credentials.fromJson(string));

// Once you have the client, you can use it just like any other HTTP client.
//    var result = await client.read("http://example.com/protected-resources.txt");

// Once we're done with the client, save the credentials file. This will allow
// us to re-use the credentials and avoid storing the username and password
// directly.

//      RestApi().getSurveysFromServerAndStoreInDB();
  }

  void animateButton() {
    double initialWidth = _globalKey.currentContext.size.width;

    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    _animation = Tween(begin: 0.0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - 48) * _animation.value);
        });
      });
    _controller.forward();

    setState(() {
      _state = 1;
    });
    getSurveysFromServer();
  }

  setUpButtonChild() {
    if (_state == 0) {
      return Text(
        "Sign in",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      );
    } else if (_state == 1) {
      return SizedBox(
        height: 36,
        width: 36,
        child: CircularProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }
}
