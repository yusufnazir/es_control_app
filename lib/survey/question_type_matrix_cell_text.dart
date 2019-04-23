import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:flutter/material.dart';

class MatrixCellText extends StatefulWidget {
  final SurveyQuestion surveyQuestion;
  final SurveyResponse surveyResponse;
  final SurveyQuestionAnswerChoice surveyQuestionAnswerChoiceRow;
  final SurveyQuestionAnswerChoice surveyQuestionAnswerChoiceColumn;

  MatrixCellText(
      this.surveyResponse,
      this.surveyQuestion,
      this.surveyQuestionAnswerChoiceRow,
      this.surveyQuestionAnswerChoiceColumn);

  @override
  State<StatefulWidget> createState() {
    return MatrixCellTextState();
  }
}

class MatrixCellTextState extends State<MatrixCellText> {
  SurveyResponseAnswer surveyResponseAnswer;
  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool focussed = false;
  String oldValue = "";

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        focussed = true;
      }
      if (!focusNode.hasFocus && focussed) {
        _updateText(textEditingController.text);
      }
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildSingleLayout();
  }

  buildSingleLayout() {
    retrieveSurveyResponseAnswerChoice() async {
      surveyResponseAnswer = await DBProvider.db
          .getSurveyResponseAnswerChoiceForMatrixCellTextByResponseAndQuestion(
              widget.surveyResponse.uniqueId,
              widget.surveyQuestion.id,
              widget.surveyQuestionAnswerChoiceRow.id,
              widget.surveyQuestionAnswerChoiceColumn.id);
      if (surveyResponseAnswer != null) {
        oldValue = surveyResponseAnswer.responseText;
        textEditingController.text = oldValue;
      }
    }

    FutureBuilder futureBuilder = FutureBuilder(
        future: retrieveSurveyResponseAnswerChoice(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return TextField(
            focusNode: focusNode,
            controller: textEditingController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
          );
        });

    return futureBuilder;
  }

  _updateText(String value) {
    focussed = false;
    if (oldValue.compareTo(value) != 0) {
      oldValue = value;
      DBProvider.db.updateSurveyResponseAnswerChoiceForMatrixCellText(
          widget.surveyResponse.uniqueId,
          widget.surveyQuestion.id,
          oldValue,
          widget.surveyQuestionAnswerChoiceRow.id,
          widget.surveyQuestionAnswerChoiceColumn.id);
    }
  }
}
