import 'package:es_control_app/rest/survey_rest_api.dart';
import 'package:es_control_app/survey_forms_page.dart';
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

  @override
  void initState() {
    super.initState();
    _progressHUD = new ProgressHUD(
      backgroundColor: Colors.black12,
      color: Colors.white,
      containerColor: Colors.blue,
      borderRadius: 5.0,
      text: 'Loading...',
    );
    surveys = List<Survey>();
    getSurveys();
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
//    debugPrint("List of surveys $surveys");
    setState(() {
      this.surveys.addAll(surveys);
    });
    dismissProgressHUD();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: new AppBar(
        title: Text("Surveys"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
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
                        style: TextStyle(color: Colors.indigo),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(ConfirmAction.CANCEL);
                          },
                        ),
                        FlatButton(
                          child: const Text('Yes'),
                          onPressed: () {
                            dismissProgressHUD();
                            setState(() {
                              present = 0;
                              surveys.clear();
                              debugPrint("resyncing surveys");
                              _reSync();
                            });
                            Navigator.of(context).pop(ConfirmAction.ACCEPT);
                          },
                        )
                      ],
                    );
                  });

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
    await RestApi().getSurveysFromServerAndStoreInDB();
    debugPrint("Retrieved from the server and stored in the database");
    await getSurveys();
  }

  _navigateToSurvey(BuildContext context, Survey survey) {
    debugPrint(survey.toString());
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) => new SurveyPage(survey)));
  }
}
