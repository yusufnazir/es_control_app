import 'package:es_control_app/constants.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/widgets/blinking_button.dart';
import 'package:flutter/material.dart';

class CardHeader extends StatelessWidget {
  final SurveyQuestion surveyQuestion;
  final bool showScroll;
  final int requiredQuestionId;

  CardHeader(this.surveyQuestion, this.showScroll, this.requiredQuestionId);

  @override
  Widget build(BuildContext context) {
    bool visible = false;
    if (surveyQuestion.questionDescription != null &&
        surveyQuestion.questionDescription.trim().isNotEmpty) {
      visible = true;
    }

    getRequiredQuestionColor() {
      if (requiredQuestionId == null ||
          requiredQuestionId != surveyQuestion.id) {
        return Constants.accentColorLight;
      } else {
        return Constants.kShrinePink400;
      }
    }

    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: getRequiredQuestionColor(),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Constants.borderRadius),
                  topRight: Radius.circular(Constants.borderRadius))),
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            surveyQuestion.question,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Visibility(
                        child: BlinkingButton(),
                        visible: showScroll,
                      ),
                    ],
                  ),
                ],
              )),
        ),
        Visibility(
          visible: visible,
          child: Container(
            decoration: BoxDecoration(
              color: Constants.primaryColorLighter,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  surveyQuestion.questionDescription == null
                      ? ""
                      : surveyQuestion.questionDescription,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
