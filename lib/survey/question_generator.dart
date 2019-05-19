import 'dart:async';

import 'package:es_control_app/constants.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/model/survey_response_section_model.dart';
import 'package:es_control_app/model/survey_section_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/streamcontrollerbeans/stream_controller_bean_choice.dart';
import 'package:es_control_app/survey/question_widget.dart';
import 'package:flutter/material.dart';

class QuestionGeneratorWidget extends StatefulWidget {
  final List<SurveyQuestion> surveyQuestions;
  final SurveyResponse surveyResponse;
  final SurveySection surveySection;
  final int requiredQuestionId;

  QuestionGeneratorWidget(this.surveyResponse, this.surveyQuestions,
      this.surveySection, this.requiredQuestionId);

  @override
  State<StatefulWidget> createState() {
    return QuestionGeneratorWidgetState();
  }
}

class QuestionGeneratorWidgetState extends State<QuestionGeneratorWidget> {
  bool sectionSelected;
//  bool uploaded;

  StreamController<StreamControllerBeanChoice>
      streamControllerMakeQuestionRequired = new StreamController.broadcast();
  StreamController<StreamControllerBeanChoice>
      streamControllerMakeQuestionByGroupRequired =
      new StreamController.broadcast();

  @override
  void initState() {
    super.initState();
//    uploaded = false;
    sectionSelected = false;
    getSurveySectionApplicability();
//    getSurveyResponseUploaded();
  }

  @override
  void dispose() {
    streamControllerMakeQuestionRequired.close();
    streamControllerMakeQuestionByGroupRequired.close();
    super.dispose();
  }

  getSurveySectionApplicability() async {
    SurveyResponseSection surveyResponseSection = await DBProvider.db
        .getSurveyResponseSectionByResponseAndSection(
            widget.surveyResponse.uniqueId, widget.surveySection.id);
    if (surveyResponseSection != null) {
      if (this.mounted) {
        setState(() {
          sectionSelected = surveyResponseSection.notApplicable;
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
            _showSectionNameLayout(),
            AbsorbPointer(
              absorbing: sectionSelected,
              child: Column(
                children: widget.surveyQuestions
                    .map((item) => new QuestionWidget(
                        surveyResponse: widget.surveyResponse,
                        surveyQuestion: item,
                        streamControllerMakeQuestionRequired:
                            streamControllerMakeQuestionRequired,
                        streamControllerMakeQuestionByGroupRequired:
                            streamControllerMakeQuestionByGroupRequired,
                        requiredQuestionId: widget.requiredQuestionId))
                    .toList(),
              ),
            ),
          ],
      ),
    );
  }

  Card _showSectionNameLayout() {
    bool enableApplicability = widget.surveySection.enableApplicability;
    if (enableApplicability == null) {
      enableApplicability = false;
    }
//    debugPrint("surveySection ${widget.surveySection}");
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
                      widget.surveySection.name,
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
                          value: sectionSelected,
                          onChanged: (bool value) {
                            _onSectionHeaderSelected(value);
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
//          title: Text(widget.surveySection.name),
//        )
        );
  }

  _onSectionHeaderSelected(bool value) async {
    await DBProvider.db.updateSurveyResponseSectionApplicability(
        widget.surveyResponse.uniqueId, widget.surveySection.id, value);
    FocusScope.of(context).requestFocus(FocusNode());
    if(this.mounted) {
      setState(() {
        sectionSelected = value;
      });
    }
  }

//  void getSurveyResponseUploaded() async {
//    SurveyResponse surveyResponse = await DBProvider.db
//        .getSurveyResponseByUniqueId(widget.surveyResponse.uniqueId);
//    if(this.mounted) {
//      setState(() {
//        uploaded = surveyResponse.uploaded;
//      });
//    }
//  }
}
