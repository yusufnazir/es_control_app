import 'package:es_control_app/constants.dart';
import 'package:es_control_app/form_card.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/util/question_validator.dart';
import 'package:flutter/material.dart';
import 'package:progress_hud_v2/progress_hud.dart';
import 'package:uuid/uuid.dart';

import 'model/survey_model.dart';
import 'repository/db_provider.dart';
import 'survey_form_questions_page.dart';

class SurveyPage extends StatefulWidget {
  final Survey survey;

  SurveyPage(this.survey);

  @override
  State<StatefulWidget> createState() {
    return SurveyPageState();
  }
}

enum ConfirmAction { CANCEL, ACCEPT }

class SurveyPageState extends State<SurveyPage> {
  final _formKey = GlobalKey<FormState>();
  List<SurveyResponse> surveyResponses;
  ProgressHUD _progressHUD;
  bool _loading = false;

  @override
  void initState() {
    _progressHUD = new ProgressHUD(
      loading: _loading,
      backgroundColor: Colors.black12,
      color: Colors.white,
      containerColor: Constants.primaryColor,
      borderRadius: 5.0,
      text: 'Uploading...',
    );
    surveyResponses = List<SurveyResponse>();
    getSurveyResponses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var surveyCard = Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title:
                Text("You have ${surveyResponses.length} forms at the moment."),
          )
        ],
      ),
    );

    return new Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
              child: Text(widget.survey.description,
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.white)),
              preferredSize: null),
          title: Text(
            widget.survey.name,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            createNewFormLayout(context);
          },
          child: Icon(Icons.add),
        ),
        body: Stack(
          children: <Widget>[
            Column(children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: surveyCard,
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: surveyResponses.length,
                      itemBuilder: (context, position) {
                        return Card(
//                        color: Color.fromRGBO(58, 66, 86, 1.0),
                            color: Constants.primaryColorLight,
                            child: Column(children: <Widget>[
                              Divider(height: 5.0),
                              createFormListTile(
                                  surveyResponses[position], position)
                            ]));
                      }))
            ]),
            _progressHUD
          ],
        ));
  }

  createFormListTile(SurveyResponse surveyResponse, int position) {
    return FormCardTile(
      prepareForUpload: (Function callback) async{
        await surveyFormSelectedForValidation(context, surveyResponses[position],callback);
      },
      surveyFormSelected: () {
        surveyFormSelected(context, surveyResponses[position]);
      },
      surveyResponse: surveyResponse,
    );
  }

  void createNewFormLayout(BuildContext context) {
    TextEditingController formNameController = TextEditingController();

    TextFormField formNameField = TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
          labelText: "Form name", labelStyle: TextStyle(color: Colors.white)),
      controller: formNameController,
    );

    void createNewForm() async {
      var text = formNameController.text;

      SurveyResponse surveyResponse = new SurveyResponse();
      Uuid uuid = Uuid();
      String uniqueId = uuid.v4();
      surveyResponse.uniqueId = uniqueId;
      surveyResponse.surveyId = widget.survey.id;
      surveyResponse.createdOn = DateTime.now();
      surveyResponse.formName = text;
      await DBProvider.db.createSurveyResponse(surveyResponse);
      List<SurveyResponse> surveyResponses =
          await DBProvider.db.getAllSurveyResponses(widget.survey.id);
      setState(() {
        this.surveyResponses.add(surveyResponse);
      });
    }

    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
              backgroundColor: Constants.primaryColor,
              contentPadding: EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              title: Text(
                "Create a new form",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green),
              ),
              actions: <Widget>[
                FlatButton(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(ConfirmAction.CANCEL);
                  },
                ),
                FlatButton(
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  onPressed: () {
                    createNewForm();
                    Navigator.of(context).pop(ConfirmAction.ACCEPT);
                  },
                )
              ],
              content: Form(
                  key: _formKey,
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: const Divider(
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: formNameField,
                    )
                  ])));
        });
  }

  void createUploadFormConfirmationLayout(
      BuildContext context, SurveyResponse surveyResponse,Function callback) {
    void uploadForm(Function callback) async{
      await new Future.delayed(const Duration(seconds: 1));
      callback();
      toggleProgressHUD();
//      SurveyResponse surveyResponse = new SurveyResponse();
//      Uuid uuid = Uuid();
//      String uniqueId = uuid.v4();
//      surveyResponse.uniqueId = uniqueId;
//      surveyResponse.surveyId = widget.survey.id;
//      surveyResponse.createdOn = DateTime.now();
//      await DBProvider.db.createSurveyResponse(surveyResponse);
//      List<SurveyResponse> surveyResponses =
//          await DBProvider.db.getAllSurveyResponses(widget.survey.id);
    }

    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            backgroundColor: Constants.primaryColor,
            contentPadding: EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text(
              "Upload your completed form!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green),
            ),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  FlatButton(
                    child: const Text('Cancel',
                        style: TextStyle(fontSize: 20, color: Colors.red)),
                    onPressed: () {
                      Navigator.of(context).pop(ConfirmAction.CANCEL);
                    },
                  ),
                  FlatButton(
                    child: const Text(
                      'Upload',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    onPressed: () {
                      toggleProgressHUD();
                      uploadForm(callback);
                      Navigator.of(context).pop(ConfirmAction.ACCEPT);
                    },
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              )
            ],
          );
        });
  }

  void getSurveyResponses() async {
    List<SurveyResponse> surveyResponses =
        await DBProvider.db.getAllSurveyResponses(widget.survey.id);
    setState(() {
      this.surveyResponses.addAll(surveyResponses);
    });
  }

  surveyFormSelected(BuildContext context, SurveyResponse surveyResponse) {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => new SurveyFormQuestionsPage(
              survey: widget.survey,
              surveyResponse: surveyResponse,
            )));
  }

  surveyFormSelectedForValidation(
      BuildContext context, SurveyResponse surveyResponse,Function callback) async {
    QuestionValidator questionValidator =
        QuestionValidator(widget.survey.id, surveyResponse.uniqueId);
    await questionValidator.validateQuestions();
    SurveyQuestion surveyQuestion = questionValidator.surveyQuestion;
    if (surveyQuestion != null) {
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (context) => new SurveyFormQuestionsPage(
              survey: widget.survey,
              surveyResponse: surveyResponse,
              surveyQuestionRequired: surveyQuestion)));
    } else {
      createUploadFormConfirmationLayout(context, surveyResponse, callback);
    }
  }

  void toggleProgressHUD() {
//    setState(() {
    if (_loading) {
      _progressHUD.state.dismiss();
    } else {
      _progressHUD.state.show();
    }
    _loading = !_loading;
//    });
  }
}
