import 'package:es_control_app/constants.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/survey/question_type_matrix_cell_choice.dart';
import 'package:es_control_app/survey/question_type_matrix_cell_text.dart';
import 'package:es_control_app/util/matrix_column_types.dart';
import 'package:es_control_app/widgets/question_card_header.dart';
import 'package:es_control_app/widgets/sized_circular_progress_bar.dart';
import 'package:flutter/material.dart';

class QuestionTypeMatrix extends StatefulWidget {
  final SurveyQuestion surveyQuestion;
  final SurveyResponse surveyResponse;
  final int requiredQuestionId;

  QuestionTypeMatrix(this.surveyResponse, this.surveyQuestion, this.requiredQuestionId);

  @override
  State<StatefulWidget> createState() {
    return QuestionTypeMatrixState();
  }
}

class QuestionTypeMatrixState extends State<QuestionTypeMatrix> {
  final row = "ROW";
  final column = "COLUMN";

  @override
  Widget build(BuildContext context) {
    return buildTableLayout();
  }

  FutureBuilder buildTableLayout() {
    loadChoices() async {
      List<SurveyQuestionAnswerChoice> choices = await DBProvider.db
          .getSurveyQuestionAnswerChoiceByQuestion(widget.surveyQuestion.id);
      return choices;
    }

    FutureBuilder futureBuilder = FutureBuilder(
      future: loadChoices(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          List<SurveyQuestionAnswerChoice> choices = snapshot.data;

          List<SurveyQuestionAnswerChoice> rows = choices
              .where((surveyQuestionAnswerChoice) =>
                  (surveyQuestionAnswerChoice.axis == row))
              .toList();
          List<SurveyQuestionAnswerChoice> columns = choices
              .where((surveyQuestionAnswerChoice) =>
                  (surveyQuestionAnswerChoice.axis == column))
              .toList();
          Map columnWidths = Map<int, TableColumnWidth>();
          int i = 0;
          columns.forEach((p) {
            if (p.matrixColumnType == single_composite_selection) {
//              columnWidths[i] = FixedColumnWidth(400.0);
              columnWidths[i] = IntrinsicColumnWidth();
            } else {
              columnWidths[i] = FixedColumnWidth(150.0);
            }
            i++;
          });

          List tableRows = List<TableRow>();
          Table table = Table(
//            defaultColumnWidth: FixedColumnWidth(150),
//            columnWidths: const <int, TableColumnWidth>{
//              0: FixedColumnWidth(50.0),
//            },
            columnWidths: columnWidths,
            children: tableRows,
          );
          List headerCells = List<TableCell>();
          for (SurveyQuestionAnswerChoice column in columns) {
            headerCells.add(TableCell(
                child: Text(
              column.label,
              style: TextStyle(fontWeight: FontWeight.bold),
            )));
          }
          TableRow header = TableRow(
              children: headerCells,
              decoration: BoxDecoration(color: Constants.primaryColorLight));
          tableRows.add(header);

          for (SurveyQuestionAnswerChoice row in rows) {
            List rowCells = List<TableCell>();
            for (SurveyQuestionAnswerChoice column in columns) {
              if (column.index == 0) {
                rowCells.add(TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text(
                    row.label,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ));
              } else {
                rowCells.add(_determineMatrixTypeCell(row, column));
              }
            }
            TableRow tableRow = TableRow(
              children: rowCells,
            );
            tableRows.add(tableRow);
          }
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    color: Constants.accentColorLight,
                    child:
                        CardHeader(widget.surveyQuestion, true, widget.requiredQuestionId),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[table],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return SizedCircularProgressBar(
            height: 25,
            width: 25,
          );
        }
      },
    );
    return futureBuilder;
  }

  _determineMatrixTypeCell(
      SurveyQuestionAnswerChoice row, SurveyQuestionAnswerChoice column) {
    switch (column.matrixColumnType) {
      case single_composite_selection:
        return TableCell(
            child: Padding(
                padding: EdgeInsets.all(8.0),
                child: MatrixCellChoice(widget.surveyResponse,
                    widget.surveyQuestion, row, column)));
      case text:
        return TableCell(
            child: Padding(
                padding: EdgeInsets.all(8.0),
                child: MatrixCellText(widget.surveyResponse,
                    widget.surveyQuestion, row, column)));
    }
  }
}
