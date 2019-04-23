import 'dart:async';

import 'package:es_control_app/constants.dart';
import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_group_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/streamcontrollerbeans/stream_controller_bean_choice.dart';
import 'package:es_control_app/survey/question_widget.dart';
import 'package:flutter/material.dart';

class QuestionGeneratorWidget extends StatefulWidget {
  final List<SurveyQuestion> surveyQuestions;
  final SurveyResponse surveyResponse;
  final SurveyGroup surveyGroup;
  final int requiredQuestionId;

  QuestionGeneratorWidget(
      this.surveyResponse, this.surveyQuestions, this.surveyGroup, this.requiredQuestionId);

  @override
  State<StatefulWidget> createState() {
    return QuestionGeneratorWidgetState();
  }
}

class QuestionGeneratorWidgetState extends State<QuestionGeneratorWidget> {
  bool groupSelected;

  StreamController<StreamControllerBeanChoice> streamController =
      new StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    groupSelected =false;
    getSurveyGroupApplicability();
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  getSurveyGroupApplicability() async {

    SurveyResponseGroup surveyResponseGroup = await DBProvider.db
        .getSurveyResponseGroupByResponseAndGroup(
        widget.surveyResponse.uniqueId, widget.surveyGroup.id);
    if (surveyResponseGroup != null) {
      if (this.mounted) {
        setState(() {
          debugPrint("getSurveyGroupApplicability");
          groupSelected = surveyResponseGroup.applicable;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _showGroupNameLayout(),
          AbsorbPointer(
            absorbing: groupSelected,
            child: Column(
              children: widget.surveyQuestions
                  .map((item) => new QuestionWidget(
                      widget.surveyResponse, item, streamController, widget.requiredQuestionId))
                  .toList(),
            ),
          ),
        ],
      ), //      body: SizedBox(
    );
  }

  Card _showGroupNameLayout() {
    bool enableApplicability = widget.surveyGroup.enableApplicability;
    if (enableApplicability == null) {
      enableApplicability = false;
    }
    debugPrint("surveyGroup ${widget.surveyGroup}");
    return Card(
        shape: BeveledRectangleBorder(),
        color: Theme.of(context).primaryColorLight,
        child: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: 8.0, left: 8.0, bottom: 16.0, top: 16.0),
                    child: Text(
                      widget.surveyGroup.name,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Visibility(
                child: Flexible(
                    fit: FlexFit.tight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Checkbox(
                          activeColor: Colors.white,
                          checkColor: Constants.accentColor,
                          value: groupSelected,
                          onChanged: (bool value) {
                            _onGroupHeaderSelected(value);
                          },
                        ),
                        Text(
                          "NA",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    )),
                visible: enableApplicability,
              ),
            ],
          ),
        )
//        ListTile(
//          title: Text(widget.surveyGroup.name),
//        )
        );
  }

  _onGroupHeaderSelected(bool value) async {
    await DBProvider.db.updateSurveyResponseGroup(
        widget.surveyResponse.uniqueId, widget.surveyGroup.id, value);
    setState(() {
      groupSelected = value;
    });
  }
}
