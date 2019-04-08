import 'dart:async';

import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/survey/question_widget.dart';
import 'package:flutter/material.dart';

class QuestionGeneratorWidget extends StatefulWidget {
  final List<SurveyQuestion> surveyQuestions;
  final SurveyGroup surveyGroup;
  final StreamController<Map<int,bool>> streamController;

  QuestionGeneratorWidget(this.surveyQuestions, this.surveyGroup, this.streamController);

  @override
  State<StatefulWidget> createState() {
    return QuestionGeneratorWidgetState();
  }
}

class QuestionGeneratorWidgetState extends State<QuestionGeneratorWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _showGroupNameLayout(),
          Column(
            children: widget.surveyQuestions
                .map((item) => new QuestionWidget(item,widget.streamController))
                .toList(),
          ),
        ],
      ), //      body: SizedBox(
    );
  }

  Card _showGroupNameLayout() {
    return Card(
      shape: BeveledRectangleBorder(),
      color: Theme.of(context).primaryColorLight,
      child: ListTile(
            title: Text(widget.surveyGroup.name),
          )
    );
  }
}
