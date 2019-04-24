import 'dart:convert';

import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_selection_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/pojo/survey_pojo.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/repository/survey_group_repository.dart';
import 'package:es_control_app/repository/survey_question_answer_choice_repository.dart';
import 'package:es_control_app/repository/survey_question_answer_choice_selection_repository.dart';
import 'package:es_control_app/repository/survey_question_repository.dart';
import 'package:es_control_app/repository/survey_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RestApi {
  /* Retrieves the surveys from the server and stores this in database.
  The Survey table is cleaned up before storing the retrieved survey.
   */
  getSurveysFromServerAndStoreInDB() async {
    try {
      cleanUpDatabase();
      var response = await http
          .get("http://192.168.0.105:9300/escontrol/rest/api/v1/surveys/");
//    .get("http://10.10.10.100:9300/escontrol/rest/api/v1/surveys/");
//          .get("http://192.168.1.9:9300/escontrol/rest/api/v1/surveys/");
//      debugPrint(response.body);
      List<SurveyPojo> surveyPojos = parseSurveys(response.body);
      if (surveyPojos != null) {
        for (SurveyPojo surveyPojo in surveyPojos) {
          Survey survey = surveyPojo.survey;
          await manageSurvey(survey);

          List<SurveyGroup> surveyGroups = surveyPojo.surveyGroups;
//          debugPrint("surveyGroups $surveyGroups");
          await manageSurveyGroups(surveyGroups);

          List<SurveyQuestion> surveyQuestions = surveyPojo.surveyQuestions;
          await manageSurveyQuestions(surveyQuestions);

          List<SurveyQuestionAnswerChoice> surveyQuestionAnswerChoices =
              surveyPojo.surveyQuestionAnswerChoices;
          await manageSurveyQuestionAnswerChoices(surveyQuestionAnswerChoices);

          List<SurveyQuestionAnswerChoiceSelection> surveyQuestionAnswerChoiceSelections =
              surveyPojo.surveyQuestionAnswerChoiceSelections;
          await manageSurveyQuestionAnswerChoiceSelections(surveyQuestionAnswerChoiceSelections);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<SurveyPojo> parseSurveys(String responseBody) {
    var decode = json.decode(responseBody);
//    Survey survey = decode["survey"];
//    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
//    var json = json["surveyGroups"];
    return decode
        .map<SurveyPojo>((value) => SurveyPojo.fromMap(value))
        .toList();
  }

  manageSurvey(Survey survey) async {
    Survey existingSurvey = await DBProvider.db.getSurvey(survey.id);
    if (existingSurvey == null) {
      await DBProvider.db.createSurvey(survey);
    } else {
      await DBProvider.db.updateSurvey(survey);
    }
  }

  manageSurveyGroups(List<SurveyGroup> surveyGroups) async {
    if (surveyGroups != null) {
      for (SurveyGroup surveyGroup in surveyGroups) {
        SurveyGroup existingSurveyGroup =
            await DBProvider.db.getSurveyGroup(surveyGroup.id);
        if (existingSurveyGroup == null) {
          await DBProvider.db.createSurveyGroup(surveyGroup);
        } else {
          await DBProvider.db.updateSurveyGroup(surveyGroup);
        }
      }
    }
  }

  manageSurveyQuestions(List<SurveyQuestion> surveyQuestions) async {
    if (surveyQuestions != null) {
      for (SurveyQuestion surveyQuestion in surveyQuestions) {
        SurveyQuestion existingSurveyQuestion =
            await DBProvider.db.getSurveyQuestion(surveyQuestion.id);
        if (existingSurveyQuestion == null) {
          await DBProvider.db.createSurveyQuestion(surveyQuestion);
        } else {
          await DBProvider.db.updateSurveyQuestion(surveyQuestion);
        }
      }
    }
  }

  manageSurveyQuestionAnswerChoices(
      List<SurveyQuestionAnswerChoice> surveyQuestionAnswerChoices) async {
    if (surveyQuestionAnswerChoices != null) {
      for (SurveyQuestionAnswerChoice surveyQuestionAnswerChoice
          in surveyQuestionAnswerChoices) {
        SurveyQuestionAnswerChoice existingSurveyQuestionAnswerChoice =
            await DBProvider.db
                .getSurveyQuestionAnswerChoice(surveyQuestionAnswerChoice.id);
        if (existingSurveyQuestionAnswerChoice == null) {
          await DBProvider.db
              .createSurveyQuestionAnswerChoice(surveyQuestionAnswerChoice);
        } else {
          await DBProvider.db
              .updateSurveyQuestionAnswerChoice(surveyQuestionAnswerChoice);
        }
      }
    }
  }

  manageSurveyQuestionAnswerChoiceSelections(
      List<SurveyQuestionAnswerChoiceSelection>
          surveyQuestionAnswerChoiceSelections) async {
    if (surveyQuestionAnswerChoiceSelections != null) {
      for (SurveyQuestionAnswerChoiceSelection surveyQuestionAnswerChoiceSelection
          in surveyQuestionAnswerChoiceSelections) {
        SurveyQuestionAnswerChoiceSelection
            existingSurveyQuestionAnswerChoiceSelection = await DBProvider.db
                .getSurveyQuestionAnswerChoiceSelection(
                    surveyQuestionAnswerChoiceSelection.id);
        if (existingSurveyQuestionAnswerChoiceSelection == null) {
          await DBProvider.db.createSurveyQuestionAnswerChoiceSelection(
              surveyQuestionAnswerChoiceSelection);
        } else {
          await DBProvider.db.updateSurveyQuestionAnswerChoiceSelection(
              surveyQuestionAnswerChoiceSelection);
        }
      }
    }
  }

  void cleanUpDatabase() async{
    await DBProvider.db.deleteAll();
  }
}
