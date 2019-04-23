import 'dart:async';

import 'package:es_control_app/constants.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/streamcontrollerbeans/stream_controller_bean_choice.dart';
import 'package:es_control_app/survey/choice_checkbox_list_tile.dart';
import 'package:es_control_app/widgets/question_card_header.dart';
import 'package:es_control_app/widgets/sized_circular_progress_bar.dart';
import 'package:flutter/material.dart';

class QuestionTypeChoice extends StatefulWidget {
  final SurveyResponse surveyResponse;
  final SurveyQuestion surveyQuestion;
  final StreamController<StreamControllerBeanChoice> streamController;
  final int requiredQuestionId;

  QuestionTypeChoice(
      this.surveyResponse, this.surveyQuestion, this.streamController,this.requiredQuestionId);

  @override
  State<StatefulWidget> createState() {
    return QuestionTypeChoiceState();
  }
}

class QuestionTypeChoiceState extends State<QuestionTypeChoice> {
  List commentWidgets;

  @override
  void initState() {
    super.initState();
    commentWidgets = List<ChoiceCheckboxListTile>();
  }

  @override
  Widget build(BuildContext context) {
    return buildChoicesLayout();
  }

  FutureBuilder buildChoicesLayout() {
    List<SurveyQuestionAnswerChoice> choices =
        List<SurveyQuestionAnswerChoice>();

    loadChoices() async {
      choices = await DBProvider.db
          .getSurveyQuestionAnswerChoiceByQuestion(widget.surveyQuestion.id);
      commentWidgets.clear();
      for (SurveyQuestionAnswerChoice choice in choices) {
        commentWidgets.add(ChoiceCheckboxListTile(widget.surveyResponse,
            widget.surveyQuestion, choice, widget.streamController));
      }
      return commentWidgets;
    }

    FutureBuilder futureBuilder = FutureBuilder(
        future: loadChoices(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Padding(
                  padding: EdgeInsets.only(right: 8.0, left: 8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Constants.borderRadius)),
                    child: Column(
                      children: <Widget>[
                        CardHeader(widget.surveyQuestion, false, widget.requiredQuestionId),
                         Column(
                          children: commentWidgets,
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
        });
    return futureBuilder;
  }
}
