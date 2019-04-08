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
                        child: Column(children: <Widget>[
                      Divider(height: 5.0),
                      ListTile(
                        onTap: () => surveyFormSelected(
                            context, surveyResponses[position]),
                        title: Text('${surveyResponses[position].formName}',
                            style: TextStyle(
                              fontSize: 22.0,
                              color: Theme.of(context).primaryColorLight,
                            )),
                      ),
                    ]));
                  }))
        ]));
  }

  void createNewFormLayout(BuildContext context) {
    TextEditingController formNameController = TextEditingController();

    TextFormField formNameField = TextFormField(
      decoration: InputDecoration(labelText: "Form name"),
      controller: formNameController,
    );

    void createNewForm() async {
      var text = formNameController.text;
      debugPrint("Formname [$text]");

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
      debugPrint("SurveyResponses $surveyResponses");
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
    debugPrint("List of surveyResponses $surveyResponses");
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
