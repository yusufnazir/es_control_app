import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/widgets/sized_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:es_control_app/widgets/question_card_header.dart';

class QuestionTypeMatrix extends StatefulWidget {
  final SurveyQuestion surveyQuestion;

  QuestionTypeMatrix(this.surveyQuestion);

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

          List tableRows = List<TableRow>();
          Table table = Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FixedColumnWidth(50.0),
            },
            children: tableRows,
          );
          List headerCells = List<TableCell>();
          for (SurveyQuestionAnswerChoice column in columns) {
            headerCells.add(TableCell(child: Text(column.label)));
          }
          TableRow header = TableRow(children: headerCells);
          tableRows.add(header);

          for (SurveyQuestionAnswerChoice row in rows) {
            List rowCells = List<TableCell>();
            for (SurveyQuestionAnswerChoice column in columns) {
              if (column.index == 0) {
                rowCells.add(TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text(row.label),
                ));
              } else {
                rowCells.add(TableCell(
                    child: Padding(
                        padding: EdgeInsets.all(8.0), child: TextField())));
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
                children: <Widget>[
                  CardHeader(widget.surveyQuestion.question),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: table,
                  )
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
}
