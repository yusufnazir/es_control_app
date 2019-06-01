import 'dart:async';

import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/streamcontrollerbeans/stream_controller_bean_choice.dart';
import 'package:es_control_app/survey/question_type_area_feet_inch.dart';
import 'package:es_control_app/survey/question_type_date.dart';
import 'package:es_control_app/survey/question_type_length_feet_inch.dart';
import 'package:es_control_app/util/question_types.dart';
import 'package:flutter/material.dart';

import 'question_type_choice.dart';
import 'question_type_matrix.dart';
import 'question_type_single.dart';

class QuestionWidget extends StatefulWidget {
  final SurveyQuestion surveyQuestion;
  final SurveyResponse surveyResponse;
  final StreamController<StreamControllerBeanChoice>
      streamControllerMakeQuestionRequired;
  final StreamController<StreamControllerBeanChoice>
      streamControllerMakeQuestionByGroupRequired;
  final int requiredQuestionId;

  QuestionWidget(
      {this.surveyResponse,
      this.surveyQuestion,
      this.streamControllerMakeQuestionRequired,
      this.streamControllerMakeQuestionByGroupRequired,
      this.requiredQuestionId});

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
        return QuestionTypeSingle(
            surveyResponse: widget.surveyResponse,
            surveyQuestion: widget.surveyQuestion,
            streamControllerMakeQuestionRequired:
                widget.streamControllerMakeQuestionRequired,
            streamControllerMakeQuestionByGroupRequired:
                widget.streamControllerMakeQuestionByGroupRequired,
            requiredQuestionId: widget.requiredQuestionId);
      case question_type_date:
        debugPrint("Question Type Date");
        return QuestionTypeDate(
            surveyResponse: widget.surveyResponse,
            surveyQuestion: widget.surveyQuestion,
            streamControllerMakeQuestionRequired:
            widget.streamControllerMakeQuestionRequired,
            streamControllerMakeQuestionByGroupRequired:
            widget.streamControllerMakeQuestionByGroupRequired,
            requiredQuestionId: widget.requiredQuestionId);
      case question_type_length_ft_inch:
        return QuestionTypeLengthFeetInch(
            surveyResponse: widget.surveyResponse,
            surveyQuestion: widget.surveyQuestion,
            streamControllerMakeQuestionRequired:
            widget.streamControllerMakeQuestionRequired,
            streamControllerMakeQuestionByGroupRequired:
            widget.streamControllerMakeQuestionByGroupRequired,
            requiredQuestionId: widget.requiredQuestionId);
      case question_type_area_ft_inch:
        return QuestionTypeAreaFtInch(
            surveyResponse: widget.surveyResponse,
            surveyQuestion: widget.surveyQuestion,
            streamControllerMakeQuestionRequired:
                widget.streamControllerMakeQuestionRequired,
            streamControllerMakeQuestionByGroupRequired:
                widget.streamControllerMakeQuestionByGroupRequired,
            requiredQuestionId: widget.requiredQuestionId);
      case question_type_choices:
        return QuestionTypeChoice(
            surveyResponse: widget.surveyResponse,
            surveyQuestion: widget.surveyQuestion,
            streamControllerMakeQuestionRequired:
                widget.streamControllerMakeQuestionRequired,
            streamControllerMakeQuestionByGroupRequired:
                widget.streamControllerMakeQuestionByGroupRequired,
            requiredQuestionId: widget.requiredQuestionId);
      case question_type_matrix:
        return QuestionTypeMatrix(widget.surveyResponse, widget.surveyQuestion,
            widget.requiredQuestionId);
      default:
        return QuestionTypeSingle(
            surveyResponse: widget.surveyResponse,
            surveyQuestion: widget.surveyQuestion,
            streamControllerMakeQuestionRequired:
                widget.streamControllerMakeQuestionRequired,
            streamControllerMakeQuestionByGroupRequired:
                widget.streamControllerMakeQuestionByGroupRequired,
            requiredQuestionId: widget.requiredQuestionId);
    }
  }
}
