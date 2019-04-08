import 'dart:async';

import 'package:es_control_app/model/survey_question_model.dart';
import 'package:flutter/material.dart';

import 'question_type_choice.dart';
import 'question_type_matrix.dart';
import 'question_type_single.dart';

class QuestionWidget extends StatefulWidget {
  final SurveyQuestion surveyQuestion;
  final StreamController<Map<int,bool>> streamController;

  QuestionWidget(this.surveyQuestion,this.streamController);

  @override
  State<StatefulWidget> createState() {
    return QuestionWidgetState();
  }
}

class QuestionWidgetState extends State<QuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return _parseQuestion();
  }

  Widget _parseQuestion() {
    String questionType = widget.surveyQuestion.questionType;
    switch (questionType) {
      case "SINGLE":
        return QuestionTypeSingle(widget.surveyQuestion,widget.streamController);
      case "CHOICES":
        return QuestionTypeChoice(widget.surveyQuestion,widget.streamController);
      case "MATRIX":
        return QuestionTypeMatrix(widget.surveyQuestion);
      default:
        return QuestionTypeSingle(widget.surveyQuestion,widget.streamController);
    }
  }
}
