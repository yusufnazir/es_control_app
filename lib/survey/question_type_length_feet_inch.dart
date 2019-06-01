import 'dart:async';

import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/streamcontrollerbeans/stream_controller_bean_choice.dart';
import 'package:es_control_app/widgets/question_card_header.dart';
import 'package:es_control_app/widgets/sized_circular_progress_bar.dart';
import 'package:flutter/material.dart';

const double _width = 75;

class QuestionTypeLengthFeetInch extends StatefulWidget {
  final SurveyQuestion surveyQuestion;
  final SurveyResponse surveyResponse;
  final StreamController<StreamControllerBeanChoice>
      streamControllerMakeQuestionRequired;
  final StreamController<StreamControllerBeanChoice>
      streamControllerMakeQuestionByGroupRequired;
  final int requiredQuestionId;

  QuestionTypeLengthFeetInch(
      {this.surveyResponse,
      this.surveyQuestion,
      this.streamControllerMakeQuestionRequired,
      this.streamControllerMakeQuestionByGroupRequired,
      this.requiredQuestionId});

  @override
  State<StatefulWidget> createState() {
    return QuestionTypeLengthFeetInchState();
  }
}

class QuestionTypeLengthFeetInchState extends State<QuestionTypeLengthFeetInch> {
  bool visible = false;
  SurveyResponseAnswer surveyResponseAnswer;
  TextEditingController lengthFeetTextEditingController =
      TextEditingController();
  TextEditingController lengthInchTextEditingController =
      TextEditingController();
  FocusNode lengthFeetFocusNode = FocusNode();
  FocusNode lengthInchFocusNode = FocusNode();

  bool focussed = false;
  String oldLengthFeetValue = "";
  String oldLengthInchValue = "";

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

    lengthFeetFocusNode.addListener(() {
      if (lengthFeetFocusNode.hasFocus) {
        focussed = true;
      }
      if (!lengthFeetFocusNode.hasFocus && focussed) {
        _updateText(
          lengthFeetTextEditingController.text,
          lengthInchTextEditingController.text,
        );
      }
    });

    lengthInchFocusNode.addListener(() {
      if (lengthInchFocusNode.hasFocus) {
        focussed = true;
      }
      if (!lengthInchFocusNode.hasFocus && focussed) {
        _updateText(
          lengthFeetTextEditingController.text,
          lengthInchTextEditingController.text,
        );
      }
    });
  }

  @override
  void dispose() {
    lengthFeetTextEditingController.dispose();
    lengthInchTextEditingController.dispose();
    lengthFeetFocusNode.dispose();
    lengthInchFocusNode.dispose();
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
        String decimalValue = surveyResponseAnswer.responseText;
        List<String> splitValues = decimalValue.split(":");
        lengthFeetTextEditingController.text = splitValues[0];
        lengthInchTextEditingController.text = splitValues[1];
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    width: _width,
                                    child: TextField(
                                      textAlign: TextAlign.end,
                                      focusNode: lengthFeetFocusNode,
                                      controller:
                                          lengthFeetTextEditingController,
                                      keyboardType: TextInputType.number,
                                      maxLines: null,
                                      maxLength: null,
                                    ),
                                  ),
                                  Text(
                                    "ft",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    width: _width,
                                    child: TextField(
                                      textAlign: TextAlign.end,
                                      focusNode: lengthInchFocusNode,
                                      controller:
                                          lengthInchTextEditingController,
                                      keyboardType: TextInputType.number,
                                      maxLines: null,
                                      maxLength: null,
                                    ),
                                  ),
                                  Text(
                                    "in",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
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

  String getDecimalValue(String lengthFeet, lengthInch) {
    return lengthFeet + ":" + lengthInch;
  }

  _updateText(String lengthFeet, lengthInch) {
    focussed = false;
    String decimalValue = getDecimalValue(lengthFeet, lengthInch);

    if (oldLengthFeetValue.compareTo(lengthFeet) != 0) {
      oldLengthFeetValue = lengthFeet;
      DBProvider.db.updateSurveyResponseAnswerForSingleText(
          widget.surveyResponse.uniqueId,
          widget.surveyQuestion.id,
          decimalValue);
    } else if (oldLengthInchValue.compareTo(lengthInch) != 0) {
      oldLengthInchValue = lengthInch;
      DBProvider.db.updateSurveyResponseAnswerForSingleText(
          widget.surveyResponse.uniqueId,
          widget.surveyQuestion.id,
          decimalValue);
    }
  }
}
