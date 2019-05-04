import 'dart:async';

import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/streamcontrollerbeans/stream_controller_bean_choice.dart';
import 'package:flutter/material.dart';

class ChoiceCheckboxListTile extends StatefulWidget {
  final SurveyResponse surveyResponse;
  final SurveyQuestion surveyQuestion;
  final SurveyQuestionAnswerChoice surveyQuestionAnswerChoice;
  final StreamController<StreamControllerBeanChoice> streamController;

  ChoiceCheckboxListTile(this.surveyResponse, this.surveyQuestion,
      this.surveyQuestionAnswerChoice, this.streamController);

  @override
  State<StatefulWidget> createState() {
    return ChoiceCheckboxListTileState();
  }
}

class ChoiceCheckboxListTileState extends State<ChoiceCheckboxListTile> {
  bool selected;
  bool isOtherFieldVisible;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selected = false;
    isOtherFieldVisible = false;
    widget.streamController.stream.listen((onData) {
      int surveyQuestionAnswerChoiceId = onData.choiceId;
      int surveyQuestionId = onData.surveyQuestionId;
      if (surveyQuestionId==widget.surveyQuestion.id && !widget.surveyQuestion.multipleSelection &&
          widget.surveyQuestionAnswerChoice.id !=
              surveyQuestionAnswerChoiceId) {
        if (this.mounted) {
          if(widget.surveyQuestionAnswerChoice.isOther){
            isOtherFieldVisible = false;
          }
          setState(() {
            selected = false;
//            debugPrint("selected $selected surveyQuestionAnswerChoice ${widget.surveyQuestionAnswerChoice.label}");
          });
        }
      }
    });
    getSelectedValue();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CheckboxListTile(
          value: selected,
          title: Text(widget.surveyQuestionAnswerChoice.label),
          onChanged: (bool value) {
            _onChange(value);
          },
        ),
        Visibility(
          visible: isOtherFieldVisible,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.multiline,
              controller: textEditingController,
              decoration: InputDecoration(
                  labelText: 'Other',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  )),
            ),
          ),
        )
      ],
    );
  }

  void getSelectedValue() async {
    SurveyResponseAnswer surveyResponseAnswer = await DBProvider.db
        .getSurveyResponseAnswerForChoiceByResponseAndQuestion(
            widget.surveyResponse.uniqueId,
            widget.surveyQuestion.id,
            widget.surveyQuestionAnswerChoice.id);

    if (surveyResponseAnswer != null) {
      if (this.mounted) {
        if(widget.surveyQuestionAnswerChoice.isOther){
          isOtherFieldVisible = surveyResponseAnswer.selected;
        }
        setState(() {
          selected = surveyResponseAnswer.selected;
        });
      }

      int makeSelectedQuestionRequired =
          widget.surveyQuestionAnswerChoice.makeSelectedQuestionRequired;
      if (makeSelectedQuestionRequired != null && !widget.streamController.isClosed) {
//        debugPrint("trigger stream controller ${widget.surveyQuestionAnswerChoice.label} makeselectedquestion ${widget.surveyQuestionAnswerChoice.makeSelectedQuestionRequired}");
        widget.streamController.add(
          StreamControllerBeanChoice(
              choiceId: widget.surveyQuestionAnswerChoice.id,
              makeSelectedQuestionRequired:
              widget.surveyQuestionAnswerChoice.makeSelectedQuestionRequired,
              value: selected,surveyQuestionId: widget.surveyQuestion.id),
        );
      }
    }

  }

  void _onChange(bool value) async {
    await DBProvider.db.updateSurveyResponseAnswerForChoice(
        widget.surveyResponse.uniqueId,
        widget.surveyQuestion.id,
        widget.surveyQuestionAnswerChoice.id,
        value,
        widget.surveyQuestion.multipleSelection);
    widget.streamController.add(
      StreamControllerBeanChoice(
          choiceId: widget.surveyQuestionAnswerChoice.id,
          makeSelectedQuestionRequired:
              widget.surveyQuestionAnswerChoice.makeSelectedQuestionRequired,
          value: value,surveyQuestionId: widget.surveyQuestion.id),
    );
    if (this.mounted) {
//      debugPrint("isOther ${widget.surveyQuestionAnswerChoice.isOther}");
      if(widget.surveyQuestionAnswerChoice.isOther){
        isOtherFieldVisible = value;
      }
      setState(() {
        selected = value;
      });
    }
  }
}
