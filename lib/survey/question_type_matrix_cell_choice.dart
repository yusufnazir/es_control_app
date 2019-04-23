import 'dart:async';

import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_selection_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/survey/question_choice_selection_matrix_checkbox.dart';
import 'package:es_control_app/util/matrix_column_types.dart';
import 'package:es_control_app/widgets/sized_circular_progress_bar.dart';
import 'package:flutter/material.dart';

class MatrixCellChoice extends StatefulWidget {
  final SurveyQuestion surveyQuestion;
  final SurveyResponse surveyResponse;
  final SurveyQuestionAnswerChoice surveyQuestionAnswerChoiceRow;
  final SurveyQuestionAnswerChoice surveyQuestionAnswerChoiceColumn;

  MatrixCellChoice(
      this.surveyResponse,
      this.surveyQuestion,
      this.surveyQuestionAnswerChoiceRow,
      this.surveyQuestionAnswerChoiceColumn);

  @override
  State<StatefulWidget> createState() {
    return MatrixCellChoiceState();
  }
}

class MatrixCellChoiceState extends State<MatrixCellChoice> {
  StreamController<bool> streamController = new StreamController.broadcast();

  List<SurveyQuestionAnswerChoiceSelection>
      surveyQuestionAnswerChoiceSelections;
  Map<int, ChoiceSelectionCheckbox> checkBoxes;
  bool selected = false;

  @override
  void initState() {
    super.initState();
    checkBoxes = Map();
    if (widget.surveyQuestionAnswerChoiceColumn.matrixColumnType ==
        single_composite_selection) {
      streamController.stream.listen((data) {
        setState(() {
          checkBoxes.clear();
        });
      });
    }
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildSingleLayout();
  }

  buildSingleLayout() {
    retrieveSurveyResponseAnswerChoice() async {
      surveyQuestionAnswerChoiceSelections = await DBProvider.db
          .getSurveyQuestionAnswerChoiceSelections(
              widget.surveyQuestionAnswerChoiceColumn.id);
      return surveyQuestionAnswerChoiceSelections;
    }

    FutureBuilder futureBuilder = FutureBuilder(
        future: retrieveSurveyResponseAnswerChoice(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            checkBoxes.clear();
            for (SurveyQuestionAnswerChoiceSelection surveyQuestionAnswerChoiceSelection
                in surveyQuestionAnswerChoiceSelections) {
              checkBoxes.putIfAbsent(
                  surveyQuestionAnswerChoiceSelection.id,
                  () => ChoiceSelectionCheckbox(
                      widget.surveyResponse,
                      widget.surveyQuestion,
                      widget.surveyQuestionAnswerChoiceRow,
                      widget.surveyQuestionAnswerChoiceColumn,
                      surveyQuestionAnswerChoiceSelection,
                      streamController));
            }
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: checkBoxes.values.toList(),
              ),
            );
          } else {
            return Column(
              children: <Widget>[
                SizedCircularProgressBar(
                  height: 25,
                  width: 25,
                )
              ],
            );
          }
        });

    return futureBuilder;
  }
}
