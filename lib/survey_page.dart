import 'package:flutter/material.dart';

import 'model/survey_model.dart';

class SurveyPage extends StatefulWidget {
  final Survey survey;

  SurveyPage(this.survey);

  @override
  State<StatefulWidget> createState() {
    return SurveyPageState(survey);
  }
}

class SurveyPageState extends State<SurveyPage> {
  final Survey survey;

  SurveyPageState(this.survey);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
            child: Text(survey.description,
                style: TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.white)),
            preferredSize: null),
        title: Text(
          survey.name,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
