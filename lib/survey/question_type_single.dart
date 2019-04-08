import 'dart:async';

import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/widgets/question_card_header.dart';
import 'package:es_control_app/widgets/sized_circular_progress_bar.dart';
import 'package:flutter/material.dart';

class QuestionTypeSingle extends StatefulWidget {
  final SurveyQuestion surveyQuestion;
  final StreamController<Map<int, bool>> streamController;

  QuestionTypeSingle(this.surveyQuestion, this.streamController);

  @override
  State<StatefulWidget> createState() {
    return QuestionTypeSingleState();
  }
}

class QuestionTypeSingleState extends State<QuestionTypeSingle> {

  bool visible = false;

  @override
  void initState() {
    super.initState();
    widget.streamController.stream.listen((data) {
      setState(() {
        if (data.containsKey(widget.surveyQuestion.id)) {
          visible = data[widget.surveyQuestion.id];
        }
      });
    }, onDone: () {
      print("Task Done");
    }, onError: (error) {
      print("Some Error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildSingleLayout();
  }

  buildSingleLayout() {
    checkIfQuestionIsDependant() async {
      bool isDependant = await DBProvider.db
          .isSurveyQuestionDependant(widget.surveyQuestion.id);
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
                        CardHeader(widget.surveyQuestion.question),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
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
}
