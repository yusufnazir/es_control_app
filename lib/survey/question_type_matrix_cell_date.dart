import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/util/matrix_column_types.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class MatrixCellDate extends StatefulWidget {
  final SurveyQuestion surveyQuestion;
  final SurveyResponse surveyResponse;
  final SurveyQuestionAnswerChoice surveyQuestionAnswerChoiceRow;
  final SurveyQuestionAnswerChoice surveyQuestionAnswerChoiceColumn;

  MatrixCellDate(
      this.surveyResponse,
      this.surveyQuestion,
      this.surveyQuestionAnswerChoiceRow,
      this.surveyQuestionAnswerChoiceColumn);

  @override
  State<StatefulWidget> createState() {
    return MatrixCellDateState();
  }
}

class MatrixCellDateState extends State<MatrixCellDate> {
  SurveyResponseAnswer surveyResponseAnswer;
  bool focussed = false;
  String oldValue = "";
  GlobalKey _globalKey = GlobalKey();

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2030));
    if (picked != null)
      _updateText(DateFormat(Constants.dateFormat).format(picked));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
      }
    }

    FutureBuilder futureBuilder = FutureBuilder(
        future: retrieveSurveyResponseAnswerChoice(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                  child: InkWell(
                onTap: _selectDate,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                        child: IconButton(
                            icon: Icon(Icons.calendar_today), onPressed: null)),
                    Flexible(
                      child: Text(
                        oldValue,
                        softWrap: false,
                      ),
                    )
                  ],
                ),
              ))
            ],
          );

//          return Flexible(
//              key: _globalKey,
//              child:
//              InkWell(
//            onTap: _selectDate,
//            child:
//            Container(
//              child: new Center(
//                child: new Row(
//                  children: <Widget>[
//                    IconButton(icon: Icon(Icons.calendar_today) , onPressed: null),
//                    new Text(oldValue),
//                  ],
//                ),
//              ),
//            ),
//          )
//          ) ;
        });

    return futureBuilder;
  }

  _updateText(String value) async{
//    debugPrint("value $value oldvalue $oldValue");
    focussed = false;
    await DBProvider.db.updateSurveyResponseAnswerChoiceForMatrixCellText(
        widget.surveyResponse.uniqueId,
        widget.surveyQuestion.id,
        value,
        widget.surveyQuestionAnswerChoiceRow.id,
        widget.surveyQuestionAnswerChoiceColumn.id,
        date_);
    setState(() {
      oldValue = value;
    });
  }
}
