import 'package:es_control_app/constants.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    surveyResponses = List<SurveyResponse>();
    getSurveyResponses();
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
        body: Column(children: <Widget>[
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
        ]));
  }

  createFormListTile(SurveyResponse surveyResponse, int position) {
    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: new BoxDecoration(
              border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24))),
          child: Icon(Icons.cloud_upload, color: Colors.white),
        ),
        title: Text(
          surveyResponse.formName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

        subtitle: Row(
          children: <Widget>[
            Icon(Icons.date_range, color: Colors.yellowAccent),
            Text(" ${surveyResponse.createdOn}", style: TextStyle(color: Colors.white))
          ],
        ),
        trailing: IconButton(
          onPressed: () {
            surveyFormSelected(context, surveyResponses[position]);
          },
          icon: Icon(
            Icons.keyboard_arrow_right,
            color: Colors.white,
            size: 30.0,
          ),
          padding: EdgeInsets.all(0.0),
        )
//        trailing:Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0)
        );
  }

  void createNewFormLayout(BuildContext context) {
    TextEditingController formNameController = TextEditingController();

    TextFormField formNameField = TextFormField(
      decoration: InputDecoration(labelText: "Form name"),
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
              contentPadding: EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              title: Text(
                "Create a new form",
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
                  child: const Text('Submit'),
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

  void getSurveyResponses() async {
    List<SurveyResponse> surveyResponses =
        await DBProvider.db.getAllSurveyResponses(widget.survey.id);
    setState(() {
      this.surveyResponses.addAll(surveyResponses);
    });
  }

  surveyFormSelected(BuildContext context, SurveyResponse surveyResponse) {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) =>
            new SurveyFormQuestionsPage(widget.survey, surveyResponse)));
  }
}
