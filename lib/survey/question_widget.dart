import 'dart:async';

import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/streamcontrollerbeans/stream_controller_bean_choice.dart';
import 'package:es_control_app/util/question_types.dart';
import 'package:flutter/material.dart';

import 'question_type_choice.dart';
import 'question_type_matrix.dart';
import 'question_type_single.dart';

class QuestionWidget extends StatefulWidget {
  final SurveyQuestion surveyQuestion;
  final SurveyResponse surveyResponse;
  final StreamController<StreamControllerBeanChoice> streamController;
  final int requiredQuestionId;

  QuestionWidget(
      this.surveyResponse, this.surveyQuestion, this.streamController,this.requiredQuestionId);

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
      case question_type_single:
        return QuestionTypeSingle(widget.surveyResponse, widget.surveyQuestion,
            widget.streamController, widget.requiredQuestionId);
      case question_type_choices:
        return QuestionTypeChoice(widget.surveyResponse, widget.surveyQuestion,
            widget.streamController, widget.requiredQuestionId);
      case question_type_matrix:
        return QuestionTypeMatrix(widget.surveyResponse, widget.surveyQuestion, widget.requiredQuestionId);
      default:
        return QuestionTypeSingle(widget.surveyResponse, widget.surveyQuestion,
            widget.streamController, widget.requiredQuestionId);
    }
  }
}
