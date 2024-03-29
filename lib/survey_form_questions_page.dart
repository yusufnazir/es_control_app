import 'package:collection/collection.dart';
import 'package:es_control_app/constants.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/model/survey_section_model.dart';
import 'package:es_control_app/survey/question_generator.dart';
import 'package:es_control_app/util/question_validator.dart';
import 'package:es_control_app/widgets/page_viewer_navigation_bar.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preload_page_view/preload_page_view.dart';

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

class SurveyFormQuestionsPageState extends State<SurveyFormQuestionsPage> with RouteAware{
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  List<SurveyQuestion> surveyQuestions = List<SurveyQuestion>();
  List<SurveySection> surveySections = List<SurveySection>();
  Map<int, List<SurveyQuestion>> questionsBySectionMap;
  var drawerQuestionListing;
  int requiredQuestionId;
  SurveyQuestion surveyQuestionRequired;
  bool prevVisible = true;
  bool nextVisible = true;
  int surveySectionsCount = 0;

  SurveyFormQuestionsPageState();

  final _preLoadController = PreloadPageController();
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  @override
  void initState() {
    super.initState();
    this.surveyQuestionRequired = widget.surveyQuestionRequired;
    getSurveyQuestions();
  }

  @override
  void dispose() {
    RouteObserver().unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouteObserver().subscribe(this, ModalRoute.of(context));
  }

  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
//    debugPrint("didPopNext ${runtimeType}");
  }

  // Called when the current route has been pushed.
  void didPush() {
    FocusScope.of(context).requestFocus(new FocusNode());
//    debugPrint("didPush ${runtimeType}");
  }

  // Called when the current route has been popped off.
  void didPop() {
//    debugPrint("didPop ${runtimeType}");
  }

  // Called when a new route has been pushed, and the current route is no longer visible.
  void didPushNext() {
//    debugPrint("didPushNext ${runtimeType}");
  }

  @override
  Widget build(BuildContext context) {
//    debugPrint("building layout");
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
                itemCount: surveySections.length,
                itemBuilder: (BuildContext context, int position) {
                  SurveySection surveySection =
                      surveySections == null ? null : surveySections[position];
                  if (position == 0) {
                    prevVisible = false;
                  } else {
                    prevVisible = true;
                  }
                  return QuestionGeneratorWidget(
                      widget.surveyResponse,
                      questionsBySectionMap[
                          surveySection == null ? null : surveySection.id],
                      surveySections[position],
                      requiredQuestionId);
                },
              ),
            ),
            PageViewerNavigationBar(
              nextHandler: () {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                _preLoadController.nextPage(
                    duration: _kDuration, curve: _kCurve);
                requiredQuestionId = null;
              },
              previousHandler: () {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                _preLoadController.previousPage(
                    duration: _kDuration, curve: _kCurve);
                requiredQuestionId = null;
              },
              preloadPageController: _preLoadController,
              totalPages: surveySections.length,
            ),
          ],
        ));
  }

  getSurveyQuestions() async {
    List<SurveyQuestion> questions =
        await DBProvider.db.getAllSurveyQuestionsForSurvey(widget.survey.id);
    questionsBySectionMap = groupBy(
        questions, (SurveyQuestion surveyQuestion) => surveyQuestion.sectionId);
    List<int> sectionIds = questionsBySectionMap.keys.toList();

    for (int sectionId in sectionIds) {
      SurveySection surveySection =
          await DBProvider.db.getSurveySection(sectionId);
      surveySections.add(surveySection);
    }

    surveySectionsCount = surveySections.length;
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

    navigateToSelectedQuestion(SurveySection surveySection) {
      requiredQuestionId = null;
      int indexOf = surveySections.indexOf(surveySection);
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
      for (SurveySection surveySection in surveySections) {
        Color value = widget.map[surveySection.id] == null
            ? Theme.of(context).accentColor
            : widget.map[surveySection.id];
        Ink ink = Ink(
          color: value,
          child: ListTile(
            onTap: () {
              navigateToSelectedQuestion(surveySection);
              value = Theme.of(this.context).primaryColorLight;
//              value = Colors.blue;
              resetColors();
              setState(() {
                widget.map[surveySection.id] = value;
              });
            },
            title: new Text(
              surveySection.name,
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

  void validateResponseAnswers(BuildContext context) async {
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
      int sectionId = surveyQuestionRequired.sectionId;
      SurveySection surveySection = surveySections.firstWhere(
          (SurveySection surveySection) => surveySection.id == sectionId);
      int indexOf = surveySections.indexOf(surveySection);
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
        boxShadows: <BoxShadow>[
          BoxShadow(
            color: Colors.red[800],
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0,
          )
        ],
      )..show(context);
      surveyQuestionRequired = null;
    } else {
      Flushbar(
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        isDismissible: true,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        title: "Nothing to validate.",
        message: "All required questions have been filled.",
        backgroundGradient: LinearGradient(
          colors: [Constants.primaryColorLight, Constants.primaryColor],
        ),
        boxShadows: <BoxShadow>[
          BoxShadow(
            color: Colors.green[800],
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0,
          )
        ],
      )..show(context);
//      final snackBar = SnackBar(
//        content: Text('All required questions have been filled.'),
//      );
//      // Find the Scaffold in the Widget tree and use it to show a SnackBar!
//      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }
}
