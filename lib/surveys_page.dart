import 'package:connectivity/connectivity.dart';
import 'package:es_control_app/constants.dart';
import 'package:es_control_app/preferences.dart';
import 'package:es_control_app/rest/survey_rest_api.dart';
import 'package:es_control_app/survey_forms_page.dart';
import 'package:es_control_app/util/logout_user.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:progress_hud_v2/progress_hud.dart';

import 'model/survey_model.dart';
import 'repository/db_provider.dart';

class SurveysListingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _SurveysListingPageState();
  }
}

class _SurveysListingPageState extends State<SurveysListingPage> {
  int present = 0;
  int perPage = 15;
  List<Survey> surveys;
  ProgressHUD _progressHUD;
  bool _loading = true;
  String _username = "A";

  @override
  void initState() {
    super.initState();
    _progressHUD = new ProgressHUD(
      backgroundColor: Colors.black12,
      color: Colors.white,
      containerColor: Constants.primaryColor,
      borderRadius: 5.0,
      text: 'Loading...',
    );
    surveys = List<Survey>();
    getSurveys();
    getUsername();
  }

  void dismissProgressHUD() {
    setState(() {
      if (_loading) {
        _progressHUD.state.dismiss();
      } else {
        _progressHUD.state.show();
      }
      _loading = !_loading;
    });
  }

  getSurveys() async {
    List<Survey> surveys = await DBProvider.db.getAllSurveys();
    setState(() {
      this.surveys.addAll(surveys);
    });
    dismissProgressHUD();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              margin: EdgeInsets.all(0.0),
              padding: EdgeInsets.all(0.0),
              child: UserAccountsDrawerHeader(
                  margin: EdgeInsets.all(0.0),
                  decoration: BoxDecoration(color: Constants.primaryColor),
                  accountName: Text(
                    _username[0].toUpperCase() + _username.substring(1),
                    style: TextStyle(fontSize: 20, letterSpacing: 2),
                  ),
                  currentAccountPicture: CircleAvatar(
                    radius: 50.0,
                    backgroundColor:
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? Colors.green
                            : Colors.white,
                    child: Text(
                      _username.substring(0, 1).toUpperCase(),
                      style: TextStyle(fontSize: 40.0, color: Colors.green),
                    ),
                  )),
              decoration: BoxDecoration(
                color: Colors.green,
              ),
            ),
            ListTile(
                contentPadding: EdgeInsets.only(top: 16.0, left: 16.0),
                leading: Icon(
                  Icons.sync,
                  color: Constants.primaryColor,
                ),
                title: new Text("Sync",
                    style: TextStyle(
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.bold,
                    )),
                onTap: () {
                  syncQuestionsDialog(callback: () => {Navigator.pop(context)});
                }),
            ListTile(
                contentPadding: EdgeInsets.only(top: 16.0, left: 16.0),
                leading: Icon(
                  Icons.power_settings_new,
                  color: Colors.red,
                ),
                title: new Text("Logout",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    )),
                onTap: () {
                  logoutUser(context);
                }),
          ],
        ),
      ),
      appBar: new AppBar(
        title: Text("Surveys"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
              syncQuestionsDialog();
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
              itemCount: surveys.length,
              itemBuilder: (context, position) {
                return Card(
                    child: Column(
                  children: <Widget>[
                    Divider(height: 5.0),
                    ListTile(
                      title: Text('${surveys[position].name}',
                          style: TextStyle(
                            fontSize: 22.0,
                            color: Theme.of(context).primaryColorLight,
//                            color: Colors.deepOrangeAccent,
                          )),
                      subtitle: Text(
                        '${surveys[position].description}',
                        style: new TextStyle(
                          fontSize: 18.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      onTap: () =>
                          _navigateToSurvey(context, surveys[position]),
                    )
                  ],
                ));
              }),
          _progressHUD,
        ],
      ),
    );
  }

  _reSync() async {
    int success = await RestApi().getSurveysFromServerAndStoreInDB();
    await getSurveys();

    if (success > 0) {
      Flushbar(
        duration: Duration(seconds: 8),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        isDismissible: true,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        title: "Well done.",
        message: "Your data has been successfully retrieved.",
        backgroundGradient: LinearGradient(
          colors: [Colors.green[400], Colors.green[600]],
        ),
        boxShadows: <BoxShadow>[
          BoxShadow(
            color: Colors.green[800],
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0,
          )
        ],
      )..show(context);
    } else if (success == 0) {
      Flushbar(
        duration: Duration(seconds: 8),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        isDismissible: true,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        title: "Nothing found.",
        message: "Unfortunatly there was no data to retrieve.",
        backgroundGradient: LinearGradient(
          colors: [Colors.orange[400], Colors.orange[600]],
        ),
        boxShadows: <BoxShadow>[
          BoxShadow(
            color: Colors.orange[800],
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0,
          )
        ],
      )..show(context);
    } else if (success == -1) {
      Flushbar(
        duration: Duration(seconds: 8),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        isDismissible: true,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        title: "Oops, what happened?.",
        message: "There was an error retrieving your the data.",
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
    } else if (success == -2) {
      logoutUser(context);
    }
  }

  _navigateToSurvey(BuildContext context, Survey survey) {
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) => new SurveyPage(survey)));
  }

  void getUsername() async {
    String username = await Preferences.readUsername();
    setState(() {
      _username = username;
    });
  }

  void syncQuestionsDialog({Function callback}) async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      showDialog(
          context: context,
          builder: (BuildContext buildContext) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              title: Text(
                "Are you sure you want to sync the data?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Constants.primaryColor),
              ),
              actions: <Widget>[
                FlatButton(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(ConfirmAction.CANCEL);
                  },
                ),
                FlatButton(
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () {
                    if (callback != null) {
                      callback();
                    }
                    dismissProgressHUD();
                    setState(() {
                      present = 0;
                      surveys.clear();
                      _reSync();
                    });
                    Navigator.of(context).pop(ConfirmAction.ACCEPT);
                  },
                )
              ],
            );
          });
    } else {
      Flushbar(
        duration: Duration(seconds: 8),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        isDismissible: true,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        title: "No connection.",
        message: "We could not find an internet connection to use.",
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
  }
}
