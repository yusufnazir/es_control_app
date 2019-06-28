import 'dart:async';

import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/streamcontrollerbeans/stream_controller_bean_choice.dart';
import 'package:es_control_app/widgets/question_card_header.dart';
import 'package:es_control_app/widgets/sized_circular_progress_bar.dart';
import 'package:flutter/material.dart';

class QuestionTypeSingle extends StatefulWidget {
  final SurveyQuestion surveyQuestion;
  final SurveyResponse surveyResponse;
  final StreamController<StreamControllerBeanChoice>
      streamControllerMakeQuestionRequired;
  final StreamController<StreamControllerBeanChoice>
      streamControllerMakeQuestionByGroupRequired;
  final int requiredQuestionId;

  QuestionTypeSingle(
      {this.surveyResponse,
      this.surveyQuestion,
      this.streamControllerMakeQuestionRequired,
      this.streamControllerMakeQuestionByGroupRequired,
      this.requiredQuestionId});

  @override
  State<StatefulWidget> createState() {
    return QuestionTypeSingleState();
  }
}

class QuestionTypeSingleState extends State<QuestionTypeSingle> {
  bool visible = false;
  SurveyResponseAnswer surveyResponseAnswer;
  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool focussed = false;
  String oldValue = "";

  @override
  void initState() {
    super.initState();
    widget.streamControllerMakeQuestionRequired.stream.listen(
      (data) {
        if (data.makeSelectedQuestionRequired == null) {
          if (this.mounted) {
            setState(() {
              visible = false;
            });
          }
        } else if (data.makeSelectedQuestionRequired ==
            widget.surveyQuestion.id) {
          if (this.mounted) {
            setState(() {
              visible = data.value;
            });
          }
        }
      },
    );

    widget.streamControllerMakeQuestionByGroupRequired.stream.listen(
      (data) {
        if (data.makeSelectedQuestionByGroupRequired == null) {
          if (this.mounted) {
            setState(() {
              visible = false;
            });
          }
        } else if (widget.surveyQuestion.groupId != null &&
            data.makeSelectedQuestionByGroupRequired ==
                widget.surveyQuestion.groupId) {
          if (this.mounted) {
            setState(() {
              visible = data.value;
            });
          }
        }
      },
    );

    focusNode.addListener(() {
      debugPrint("listener triggered");
      if (focusNode.hasFocus) {
        debugPrint("has focus");
        focussed = true;
      }
      debugPrint("focus? ${focusNode.hasFocus} focuessed? $focussed");
      if (!focusNode.hasFocus && focussed) {
        debugPrint("text? ${textEditingController.text}");
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
//    debugPrint("requiredQuestionId ${widget.requiredQuestionId}");
    checkIfQuestionIsDependant() async {
      surveyResponseAnswer = await DBProvider.db
          .getSurveyResponseAnswerForSingleTextByResponseAndQuestion(
              widget.surveyResponse == null
                  ? null
                  : widget.surveyResponse.uniqueId,
              widget.surveyQuestion.id);
      if (surveyResponseAnswer != null) {
        oldValue = surveyResponseAnswer.responseText;
        textEditingController.text = surveyResponseAnswer.responseText;
      }
      bool isDependant = await DBProvider.db
          .isSurveyQuestionDependant(widget.surveyQuestion.id);
      if (widget.surveyQuestion.groupId != null) {
        isDependant = true;
      }
      return isDependant;
    }

    FutureBuilder futureBuilder = FutureBuilder(
        future: checkIfQuestionIsDependant(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            bool isDependant = snapshot.data;
            if (!isDependant) {
              visible = true;
            }
            Visibility visibility = Visibility(
              child: Padding(
                  padding: EdgeInsets.only(right: 8.0, left: 8.0),
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        CardHeader(widget.surveyQuestion, false,
                            widget.requiredQuestionId),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextField(
                            focusNode: focusNode,
                            controller: textEditingController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            maxLength: null,
                          ),
                        )
                      ],
                    ),
                  )),
              visible: visible,
              maintainState: true,
            );
            return visibility;
          } else {
            return SizedCircularProgressBar(
              height: 25,
              width: 25,
            );
          }
        });

    return futureBuilder;
  }

  _updateText(String value) {
    focussed = false;
    if (oldValue.compareTo(value) != 0) {
      oldValue = value;
      DBProvider.db.updateSurveyResponseAnswerForSingleText(
          widget.surveyResponse.uniqueId, widget.surveyQuestion.id, value);
    }
  }
}
