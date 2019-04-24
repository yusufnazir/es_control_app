import 'package:collection/collection.dart';
import 'package:es_control_app/constants.dart';
import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/survey/question_generator.dart';
import 'package:es_control_app/util/question_validator.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:uuid/uuid.dart';

import 'model/survey_question_model.dart';
import 'model/survey_response_model.dart';
import 'repository/db_provider.dart';

class SurveyFormQuestionsPage extends StatefulWidget {
  final Survey survey;
  final SurveyResponse surveyResponse;
  final SurveyQuestion surveyQuestionRequired;
  final Map<int, Color> map = {};

  SurveyFormQuestionsPage(
      {this.survey, this.surveyResponse, this.surveyQuestionRequired});

  @override
  State<StatefulWidget> createState() {
    return SurveyFormQuestionsPageState();
  }
}

class SurveyFormQuestionsPageState extends State<SurveyFormQuestionsPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  List<SurveyQuestion> surveyQuestions = List<SurveyQuestion>();
  List<SurveyGroup> surveyGroups = List<SurveyGroup>();
  Map<int, List<SurveyQuestion>> questionGroups;
  var drawerQuestionListing;
  int requiredQuestionId;
  SurveyQuestion surveyQuestionRequired;

  SurveyFormQuestionsPageState();

  final _controller = new PageController();
  final _preLoadController = PreloadPageController();
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  @override
  void initState() {
    super.initState();
    this.surveyQuestionRequired=widget.surveyQuestionRequired;
    getSurveyQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(
            child: ListView(
          dragStartBehavior: DragStartBehavior.down,
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              child: DrawerHeader(
                child: Text(widget.survey.name),
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColorLight),
              ),
              height: 100.0,
            ),
            createDrawerList(),
          ],
        )),
        appBar: AppBar(
          title: Text(widget.surveyResponse.formName),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.spellcheck),
              onPressed: () {
                validateResponseAnswers(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState.openEndDrawer();
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              child: PreloadPageView.builder(
                controller: _preLoadController,
                preloadPagesCount: 0,
                itemCount: surveyGroups.length,
                itemBuilder: (BuildContext context, int position) {
                  SurveyGroup surveyGroup = surveyGroups[position];
                  return QuestionGeneratorWidget(
                      widget.surveyResponse,
                      questionGroups[surveyGroup.id],
                      surveyGroups[position],
                      requiredQuestionId);
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
                      requiredQuestionId = null;
                    },
                  ),
                  FlatButton(
                    child: Text('Next'),
                    onPressed: () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      _preLoadController.nextPage(
                          duration: _kDuration, curve: _kCurve);
                      requiredQuestionId = null;
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
    setState(() {
      surveyQuestions.addAll(questions);
    });

    if (widget.surveyQuestionRequired != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => validateResponseAnswers(context));
    }

    return questions;
  }

  FutureBuilder createDrawerList() {
    List widgets = List<Ink>();

    navigateToSelectedQuestion(SurveyGroup surveyGroup) {
      requiredQuestionId = null;
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
      widgets.clear();
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
              resetColors();
              setState(() {
                widget.map[surveyGroup.id] = value;
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
    super.dispose();
  }

  void validateResponseAnswers(BuildContext context) async {
    debugPrint("surveyQuestionRequired ${widget.surveyQuestionRequired}");
    FocusScope.of(context).requestFocus(new FocusNode());

//    SurveyQuestion surveyQuestion;
    if (surveyQuestionRequired == null) {
      QuestionValidator questionValidator =
          QuestionValidator(widget.survey.id, widget.surveyResponse.uniqueId);
      await questionValidator.validateQuestions();
      surveyQuestionRequired = questionValidator.surveyQuestion;
    } else {
      surveyQuestionRequired = widget.surveyQuestionRequired;
    }

    if (surveyQuestionRequired != null) {
      setState(() {
        requiredQuestionId = surveyQuestionRequired.id;
      });
      int groupId = surveyQuestionRequired.groupId;
      SurveyGroup surveyGroup = surveyGroups
          .firstWhere((SurveyGroup surveyGroup) => surveyGroup.id == groupId);
      int indexOf = surveyGroups.indexOf(surveyGroup);
      _preLoadController.jumpToPage(indexOf);

      Flushbar(
        duration: Duration(seconds: 4),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        isDismissible: true,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        title: "Required question",
        icon: Icon(
          Icons.info_outline,
          color: Colors.white,
        ),
        message:
            "Please review the following question: ${surveyQuestionRequired.question}",
        backgroundColor: Colors.red,
        boxShadow: BoxShadow(
          color: Colors.red[800],
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        ),
      )..show(context);
      surveyQuestionRequired = null;
    } else {
      Flushbar(duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        isDismissible: true,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        title: "Nothing to validate.",
        message: "All required questions have been filled.",
        backgroundGradient: LinearGradient(
          colors: [
            Constants.primaryColorLight,
            Constants.primaryColor
          ],
        ),
        boxShadow: BoxShadow(
          color: Colors.green[800],
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        ),
      )..show(context);
//      final snackBar = SnackBar(
//        content: Text('All required questions have been filled.'),
//      );
//      // Find the Scaffold in the Widget tree and use it to show a SnackBar!
//      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }
}
