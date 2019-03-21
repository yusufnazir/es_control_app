import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

import 'FormType.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _email = "";
  String _password = "";
  FormType _form = FormType
      .login; // our default setting is to login, and we should switch to creating an account when the user chooses to

  _LoginPageState() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
  }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
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
    return new Scaffold(
      appBar: _buildBar(context),
      body: new Container(
        padding: EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            _buildTextFields(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text("Simple Login Example"),
      centerTitle: true,
    );
  }

  Widget _buildTextFields() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new TextField(
              controller: _emailFilter,
              decoration: new InputDecoration(labelText: 'Email'),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _passwordFilter,
              decoration: new InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtons() {
    if (_form == FormType.login) {
      return new Container(
        child: new Column(
          children: <Widget>[
            new RaisedButton(
              child: new Text('Login'),
              onPressed: _loginPressed,
            ),
            new FlatButton(
              child: new Text('Dont have an account? Tap here to register.'),
              onPressed: _formChange,
            ),
            new FlatButton(
              child: new Text('Forgot Password?'),
              onPressed: _passwordReset,
            )
          ],
        ),
      );
    } else {
      return new Container(
        child: new Column(
          children: <Widget>[
            new RaisedButton(
              child: new Text('Create an Account'),
              onPressed: _createAccountPressed,
            ),
            new FlatButton(
              child: new Text('Have an account? Click here to login.'),
              onPressed: _formChange,
            )
          ],
        ),
      );
    }
  }

  // These functions can self contain any user auth logic required, they all have access to _email and _password

  void _loginPressed() {
    print('The user wants to login with $_email and $_password');
    getQuote();
//    _launchURL();
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => Home()),
//    );
  }

  _launchURL() async {
    const url = 'http://192.168.1.9:8082/ui/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<String> getQuote() async {
//    Map jsonMap = {
//      'data': {'scope': 'read',
//        'response_type': 'code',
//        'client_id': 'escontrol',
//        'redirect_uri': 'http://192.168.1.9:9300/escontroler/app'},
//    };
//
//    String basicAuth =
//        'Basic ' + base64Encode(utf8.encode('$_email:$_password'));
//    HttpClient httpClient = new HttpClient();
//    HttpClientRequest request = await httpClient.postUrl(Uri.parse('http://192.168.1.9:9300/escontroler/oauth/authorize'));
//    request.headers.set('content-type', 'application/json');
//    request.headers.set('accept', 'application/json');
//    request.headers.set('authorization', basicAuth);
//    request.add(utf8.encode(json.encode(jsonMap)));
//    HttpClientResponse response = await request.close();
//    // todo - you should check the response.statusCode
//    String reply = await response.transform(utf8.decoder).join();
//    httpClient.close();
//    return reply;

    String url = 'http://192.168.1.9:9300/escontroler/oauth/authorize';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$_email:$_password'));
    var requestBody = {
      'scope': 'read',
      'response_type': 'code',
      'client_id': 'escontrol',
      'redirect_uri': 'http://192.168.1.9:9300/escontroler/app'
    };
    Map map = {
      'data': {
        'response_type': 'code',
        'client_id': 'escontrol',
        'redirect_uri': 'http://192.168.1.9:9300/escontroler/app',
        'scope': 'read'
      },
    };
    final response = await http.post(url,
        headers: {
//          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
//          "Accept": "application/x-www-form-urlencoded",
          "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
          'authorization': basicAuth
        },
        encoding: Encoding.getByName("utf-8"),
        body: requestBody);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load post');
    }
  }

  void _createAccountPressed() {
    print('The user wants to create an accoutn with $_email and $_password');
  }

  void _passwordReset() {
    print("The user wants a password reset request sent to $_email");
  }
}
