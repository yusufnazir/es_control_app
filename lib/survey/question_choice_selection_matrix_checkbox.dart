import 'dart:async';

import 'package:es_control_app/constants.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_selection_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:flutter/material.dart';

class ChoiceSelectionCheckbox extends StatefulWidget {
  final SurveyResponse surveyResponse;
  final SurveyQuestion surveyQuestion;
  final SurveyQuestionAnswerChoice surveyQuestionAnswerChoiceRow;
  final SurveyQuestionAnswerChoice surveyQuestionAnswerChoiceColumn;
  final SurveyQuestionAnswerChoiceSelection surveyQuestionAnswerChoiceSelection;
  final StreamController<bool> streamController;

  ChoiceSelectionCheckbox(
      this.surveyResponse,
      this.surveyQuestion,
      this.surveyQuestionAnswerChoiceRow,
      this.surveyQuestionAnswerChoiceColumn,
      this.surveyQuestionAnswerChoiceSelection,
      this.streamController);

  @override
  State<StatefulWidget> createState() {
    return ChoiceSelectionCheckboxState();
  }
}

class ChoiceSelectionCheckboxState extends State<ChoiceSelectionCheckbox> {
  bool checked;

  @override
  void initState() {
    checked = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getResponseAnswerChoiceSelection() async {
      SurveyResponseAnswer surveyResponseAnswer = await DBProvider.db
          .getSurveyResponseAnswerChoiceForMatrixCellChoiceByResponseAndQuestion(
              widget.surveyResponse.uniqueId,
              widget.surveyQuestion.id,
              widget.surveyQuestionAnswerChoiceRow.id,
              widget.surveyQuestionAnswerChoiceColumn.id,
              widget.surveyQuestionAnswerChoiceSelection.id);
      return surveyResponseAnswer;
    }

    return FutureBuilder(
        future: getResponseAnswerChoiceSelection(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            SurveyResponseAnswer surveyResponseAnswer = snapshot.data;
            if (surveyResponseAnswer != null) {
              checked = surveyResponseAnswer.selected;
            }
          }

          return Flexible(
              child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                  child: Checkbox(
                checkColor: Constants.accentColor,
                value: checked,
                onChanged: (bool value) {
                  _doForOnChange(value);
                },
              )),
              Flexible(
                child: Text(
                  widget.surveyQuestionAnswerChoiceSelection.label,softWrap: false,
                ),
              )
            ],
          ));
//          } else {
//            return SizedCircularProgressBar(
//              height: 25,
//              width: 25,
//            );
//          }
        });
  }

  _doForOnChange(bool value) async {
    await DBProvider.db.updateSurveyResponseAnswerChoiceForMatrixCellChoice(
        widget.surveyResponse.uniqueId,
        widget.surveyQuestion.id,
        value,
        widget.surveyQuestionAnswerChoiceRow.id,
        widget.surveyQuestionAnswerChoiceColumn.id,
        widget.surveyQuestionAnswerChoiceSelection.id,
        widget.surveyQuestionAnswerChoiceColumn.matrixColumnType);
    widget.streamController.add(value);
//    setState(() {
//      checked = value;
//    });
  }
}
