import 'dart:async';

import 'package:collection/collection.dart';
import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/survey/question_generator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'model/survey_response_model.dart';
import 'model/survey_question_model.dart';
import 'repository/db_provider.dart';

class SurveyFormQuestionsPage extends StatefulWidget {
  final Survey survey;
  final SurveyResponse surveyResponse;
  final Map<int, Color> map = {};

  SurveyFormQuestionsPage(this.survey, this.surveyResponse);

  @override
  State<StatefulWidget> createState() {
    return SurveyFormQuestionsPageState();
  }
}

class SurveyFormQuestionsPageState extends State<SurveyFormQuestionsPage> {
  List<SurveyQuestion>  surveyQuestions = List<SurveyQuestion>();
  List<SurveyGroup> surveyGroups = List<SurveyGroup>();
  Map<int, List<SurveyQuestion>> questionGroups;
  var drawerQuestionListing;

  SurveyFormQuestionsPageState();

  final _controller = new PageController();
  final _preLoadController = PreloadPageController();
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;
  StreamController<Map<int,bool>> streamController = new StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    getSurveyQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        endDrawer: Drawer(
            child: ListView(
          dragStartBehavior: DragStartBehavior.down,
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              child: DrawerHeader(
                child: Text(widget.survey.name),
                decoration: BoxDecoration(color: Theme.of(context).primaryColorLight),
              ),
              height: 100.0,
            ),
            createDrawerList(),
          ],
        )),
        appBar: AppBar(
          title: Text(widget.surveyResponse.formName),
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              child: PreloadPageView.builder(
                controller: _preLoadController,
                preloadPagesCount: 3,
                itemCount: surveyGroups.length,
                itemBuilder: (BuildContext context, int position) {
                  SurveyGroup surveyGroup = surveyGroups[position];
                  return QuestionGeneratorWidget(
                      questionGroups[surveyGroup.id], surveyGroups[position],streamController);
                },
              ),
            ),
            Container(
              color: Theme.of(context).primaryColorLight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                    child: Text('Prev'),
                    onPressed: () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      _preLoadController.previousPage(
                          duration: _kDuration, curve: _kCurve);
                    },
                  ),
                  FlatButton(
                    child: Text('Next'),
                    onPressed: () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      _preLoadController.nextPage(
                          duration: _kDuration, curve: _kCurve);
                    },
                  )
                ],
              ),
            )
          ],
        ));
  }

  getSurveyQuestions() async {
    List<SurveyQuestion> questions =
    await DBProvider.db.getAllSurveyQuestionsForSurvey(widget.survey.id);
    questionGroups = groupBy(
        questions, (SurveyQuestion surveyQuestion) => surveyQuestion.groupId);
    List<int> groupIds = questionGroups.keys.toList();

    for (int groupId in groupIds) {
      SurveyGroup surveyGroup = await DBProvider.db.getSurveyGroup(groupId);
      surveyGroups.add(surveyGroup);
    }
    surveyQuestions.addAll(questions);
    setState(() {
      debugPrint("getSurveyQuestions");
    });
    return questions;
  }

  FutureBuilder createDrawerList() {
    List widgets = List<Ink>();

    navigateToSelectedQuestion(SurveyGroup surveyGroup) {
      int indexOf = surveyGroups.indexOf(surveyGroup);
      _preLoadController.jumpToPage(indexOf);
      Navigator.pop(context);
    }

    void resetColors() {
      widget.map.forEach((key, value) {
        widget.map[key] = Theme.of(context).accentColor;
      });
    }

    FutureBuilder futureBuilder =
        FutureBuilder(builder: (BuildContext context, AsyncSnapshot snapshot) {
      for (SurveyGroup surveyGroup in surveyGroups) {
        Color value = widget.map[surveyGroup.id] == null
            ? Theme.of(context).accentColor
            : widget.map[surveyGroup.id];
        Ink ink = Ink(
          color: value,
          child: ListTile(
            onTap: () {
              navigateToSelectedQuestion(surveyGroup);
              value = Theme.of(this.context).primaryColorLight;
//              value = Colors.blue;
              debugPrint("Resetting colors");
              resetColors();
              setState(() {
                widget.map[surveyGroup.id] = value;
                debugPrint("set color to green");
              });
            },
            title: new Text(
              surveyGroup.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
        widgets.add(ink);
      }

      return Column(
        children: widgets,
      );
    });
    return futureBuilder;
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }
}
