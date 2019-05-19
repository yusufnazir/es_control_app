import 'package:es_control_app/constants.dart';
import 'package:es_control_app/file_storage.dart';
import 'package:es_control_app/form_card.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/rest/survey_rest_api.dart';
import 'package:es_control_app/util/logout_user.dart';
import 'package:es_control_app/util/question_validator.dart';
import 'package:es_control_app/widgets/sized_circular_progress_bar.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:progress_hud_v2/progress_hud.dart';
import 'package:uuid/uuid.dart';

import 'model/survey_model.dart';
import 'repository/db_provider.dart';
import 'survey_form_questions_page.dart';

//class OnScrollCallback<T extends Widget> extends ItemListCallback {
//  int availableItems = 0;
//
//  @override
//  Future<EventModel> getItemList() async{
//      List<T> itemList = List();
//      if (availableItems < totalItems) {
//        for (int i = availableItems; i < availableItems + threshold; i++) {
//          Widget widget;
//          if (i % 5 == 0) {
//            widget = TitleWidget(i);
//          } else {
//            widget = ListItemWidget(ItemModel("Title $i", "Subtitle $i"));
//          }
//          itemList.add(widget);
//        }
//        availableItems += threshold;
//        return EventModel(progress: false, data: itemList, error: null);
//      } else {
//        for (int i = availableItems; i < availableItems + 3; i++) {
//          Widget widget = ListItemWidget(ItemModel("Title $i", "Subtitle $i"));
//          itemList.add(widget);
//        }
//        availableItems += 3;
//        return EventModel(
//            progress: false, data: itemList, error: null, stopLoading: true);
//      }
//  }
//}

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
    super.initState();
    _progressHUD = new ProgressHUD(
      loading: _loading,
      backgroundColor: Colors.black12,
      color: Colors.white,
      containerColor: Constants.primaryColor,
      borderRadius: 5.0,
      text: 'Uploading...',
    );
    surveyResponses = List<SurveyResponse>();
//    getSurveyResponses();
  }

  @override
  Widget build(BuildContext context) {
//    var surveyCard = Card(
//      child: Column(
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//          ListTile(
//            title:
//                Text("You have ${surveyResponses.length} forms at the moment."),
//          )
//        ],
//      ),
//    );

    return FutureBuilder(
      future: getSurveyResponses(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
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
                      child: Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title:
                              Text("You have ${surveyResponses.length} forms at the moment."),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child:
//                  PaginatedListWidget(
//                      progressWidget: Center(
//                        child: Text("Loading..."),
//                      ),
//                      itemListCallback: OnScrollCallback()),
                            ListView.builder(
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
        } else {
          return SizedCircularProgressBar(
            height: 25,
            width: 25,
          );
        }
      },
    );
  }

  createFormListTile(SurveyResponse surveyResponse, int position) {
    return FormCardTile(
      prepareForUpload: (Function callback) async {
        await surveyFormSelectedForValidation(
            context, surveyResponse, callback);
      },
      surveyFormSelected: () {
        surveyFormSelected(context, surveyResponse);
      },
      surveyResponse: surveyResponse,
      key: Key(surveyResponse.uniqueId) ,
    );
  }

  void createNewFormLayout(BuildContext context) {
    TextEditingController formNameController = TextEditingController();

    TextFormField formNameField = TextFormField(
      style: TextStyle(color: Colors.green),
      decoration: InputDecoration(
          labelText: "Form name", labelStyle: TextStyle(color: Colors.green)),
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
      surveyResponse.uploaded = false;
      String username = await FileStorage.readUsername();
      surveyResponse.username = username;
      surveyResponse.active = true;
      await DBProvider.db.createSurveyResponse(surveyResponse);
      List<SurveyResponse> surveyResponses =
          await DBProvider.db.getAllSurveyResponses(widget.survey.id);
      this.surveyResponses.clear();
      setState(() {
        this.surveyResponses.addAll(surveyResponses);
      });
    }

    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
              backgroundColor: Colors.white,
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
                      style: TextStyle(color: Colors.green, fontSize: 20)),
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
      BuildContext context, SurveyResponse surveyResponse, Function callback) {
    void uploadForm(Function callback) async {
//      await new Future.delayed(const Duration(seconds: 1));
      int responseCode = await uploadSurveyResponse(surveyResponse.uniqueId);
      if (responseCode == 200) {
        await DBProvider.db
            .updateSurveyResponseUploaded(surveyResponse.uniqueId, true);
        callback();
      } else if(responseCode==-2){
        logoutUser(context);
      } else {
        Flushbar(
          duration: Duration(seconds: 8),
          flushbarPosition: FlushbarPosition.TOP,
          flushbarStyle: FlushbarStyle.FLOATING,
          isDismissible: true,
          dismissDirection: FlushbarDismissDirection.HORIZONTAL,
          title: "Upload failure.",
          message: "There was an error uploading the data.",
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
      toggleProgressHUD();
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

  getSurveyResponses() async {
    List<SurveyResponse> surveyResponses =
        await DBProvider.db.getAllSurveyResponses(widget.survey.id);
//    setState(() {
    this.surveyResponses.clear();
    this.surveyResponses.addAll(surveyResponses);
//    });
    return surveyResponses;
  }

  surveyFormSelected(BuildContext context, SurveyResponse surveyResponse) {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => new SurveyFormQuestionsPage(
              survey: widget.survey,
              surveyResponse: surveyResponse,
            )));
  }

  surveyFormSelectedForValidation(BuildContext context,
      SurveyResponse surveyResponse, Function callback) async {
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

  Future<int> uploadSurveyResponse(String surveyResponseUniqueId) async {
    return await RestApi().uploadSurveyResponse(surveyResponseUniqueId);
  }
}
