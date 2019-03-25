import 'dart:convert';

import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/pojo/survey_pojo.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RestApi {
  /* Retrieves the surveys from the server and stores this in database.
  The Survey table is cleaned up before storing the retrieved survey.
   */
  getSurveysFromServerAndStoreInDB() async {
    var response = await http
        .get("http://192.168.0.105:9300/escontrol/rest/api/v1/surveys/");
//      debugPrint(response.body);
    List<SurveyPojo> surveyPojos = parseSurveys(response.body);
    if (surveyPojos != null) {
      for (SurveyPojo surveyPojo in surveyPojos) {
//          debugPrint(surveyPojo.toString());

        Survey survey = surveyPojo.survey;
        await manageSurvey(survey);

        List<SurveyGroup> surveyGroups = surveyPojo.surveyGroups;
        manageSurveyGroups(surveyGroups);

        List<SurveyQuestion> surveyQuestions = surveyPojo.surveyQuestions;
        manageSurveyQuestions(surveyQuestions);
      }
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
    debugPrint("Does survey exist ${existingSurvey != null}");
    if (existingSurvey == null) {
      await DBProvider.db.createSurvey(survey);
    } else {
      await DBProvider.db.updateSurvey(survey);
    }
  }

  manageSurveyGroups(List<SurveyGroup> surveyGroups) {
    if (surveyGroups != null) {
      for (SurveyGroup surveyGroup in surveyGroups) {
        Future<SurveyGroup> existingSurveyGroup =
            DBProvider.db.getSurveyGroup(surveyGroup.id);
        if (existingSurveyGroup == null) {
          DBProvider.db.createSurveyGroup(surveyGroup);
        } else {
          DBProvider.db.updateSurveyGroup(surveyGroup);
        }
      }
    }
  }

  manageSurveyQuestions(List<SurveyQuestion> surveyQuestions) {
    if (surveyQuestions != null) {
      for (SurveyQuestion surveyQuestion in surveyQuestions) {
        Future<SurveyQuestion> existingSurveyQuestion =
            DBProvider.db.getSurveyQuestion(surveyQuestion.id);
        if (existingSurveyQuestion == null) {
          DBProvider.db.createSurveyQuestion(surveyQuestion);
        } else {
          DBProvider.db.updateSurveyQuestion(surveyQuestion);
        }
      }
    }
  }
}
