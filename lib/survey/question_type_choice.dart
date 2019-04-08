import 'dart:async';

import 'package:es_control_app/constants.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/widgets/question_card_header.dart';
import 'package:es_control_app/widgets/sized_circular_progress_bar.dart';
import 'package:flutter/material.dart';

class QuestionTypeChoice extends StatefulWidget {
  final SurveyQuestion surveyQuestion;
  final StreamController<Map<int,bool>> streamController;

  QuestionTypeChoice(this.surveyQuestion, this.streamController);

  @override
  State<StatefulWidget> createState() {
    return QuestionTypeChoiceState();
  }
}

class QuestionTypeChoiceState extends State<QuestionTypeChoice> {

  Map<SurveyQuestionAnswerChoice, bool> choicesSelected = {};

  @override
  Widget build(BuildContext context) {
    return buildChoicesLayout();
  }

  FutureBuilder buildChoicesLayout() {
    List commentWidgets = List<CheckboxListTile>();
    List<SurveyQuestionAnswerChoice> choices =
        List<SurveyQuestionAnswerChoice>();

    Widget checkboxLisTile(SurveyQuestionAnswerChoice choice, String checkBoxTitle) {
      bool value = choicesSelected[choice] == null
          ? false
          : choicesSelected[choice];
      return CheckboxListTile(
        key: Key(choice.toString()),
        value: value,
        title: Text(checkBoxTitle),
        onChanged: (bool value) {
          resetChoicesSelection();
          if(choice.makeSelectedQuestionRequired!=null) {
            widget.streamController.add({choice.makeSelectedQuestionRequired:value});
          }
          setState(() {
            choicesSelected[choice] = value;
          });
        },
      );
    }

    loadChoices() async {
      choices = await DBProvider.db
          .getSurveyQuestionAnswerChoiceByQuestion(widget.surveyQuestion.id);
      for (SurveyQuestionAnswerChoice choice in choices) {
        commentWidgets.add(checkboxLisTile(choice, choice.label));
      }
      return commentWidgets;
    }

    FutureBuilder futureBuilder = FutureBuilder(
        future: loadChoices(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List<CheckboxListTile> commentWidgets = snapshot.data;
            return Padding(
                padding: EdgeInsets.only(right: 8.0, left: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Constants.borderRadius)),
                  child: Column(
                    children: <Widget>[
                      CardHeader(widget.surveyQuestion.question),
                      Column(
                        children: commentWidgets,
                      )
                    ],
                  ),
                ));
          } else {
            return SizedCircularProgressBar(
              height: 25,
              width: 25,
            );
          }
        });
    return futureBuilder;
  }

  void resetChoicesSelection() {
    if (!widget.surveyQuestion.multipleSelection) {
      choicesSelected.forEach((key, value) {
        choicesSelected[key] = false;
        if(key.makeSelectedQuestionRequired!=null){
          widget.streamController.add({key.makeSelectedQuestionRequired:false});
        }
      });
    }
  }
}
