import 'dart:convert';
import 'dart:io';

import 'package:es_control_app/constants.dart';
import 'package:es_control_app/file_storage.dart';
import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_section_model.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_selection_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/pojo/survey_pojo.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

class RestApi {
  /* Retrieves the surveys from the server and stores this in database.
  The Survey table is cleaned up before storing the retrieved survey.
   */
  getSurveysFromServerAndStoreInDB() async {
    try {
      cleanUpDatabase();
      String credentials = await FileStorage.readCredentials();
      oauth2.Client cl = oauth2.Client(oauth2.Credentials.fromJson(credentials),
          identifier: "escontrol", secret: "escontrol");

      var response = await cl.get(Constants.getAllSurveys);
//    .get("http://10.10.10.100:9300/escontrol/rest/api/v1/surveys/");
//          .get("http://192.168.1.9:9300/escontrol/rest/api/v1/surveys/");
//      debugPrint(response.body);
      List<SurveyPojo> surveyPojos = parseSurveys(response.body);
      if (surveyPojos != null) {
        for (SurveyPojo surveyPojo in surveyPojos) {
          Survey survey = surveyPojo.survey;
          await manageSurvey(survey);

          List<SurveySection> surveySections = surveyPojo.surveySections;
          await manageSurveySections(surveySections);

          List<SurveyGroup> surveyGroups = surveyPojo.surveyGroups;
          await manageSurveyGroups(surveyGroups);

          List<SurveyQuestion> surveyQuestions = surveyPojo.surveyQuestions;
          await manageSurveyQuestions(surveyQuestions);

          List<SurveyQuestionAnswerChoice> surveyQuestionAnswerChoices =
              surveyPojo.surveyQuestionAnswerChoices;
          await manageSurveyQuestionAnswerChoices(surveyQuestionAnswerChoices);

          List<SurveyQuestionAnswerChoiceSelection>
              surveyQuestionAnswerChoiceSelections =
              surveyPojo.surveyQuestionAnswerChoiceSelections;
          await manageSurveyQuestionAnswerChoiceSelections(
              surveyQuestionAnswerChoiceSelections);
        }

//        var response = await cl.get(Constants.getAllSurveyResponses);
//        List<SurveyResponse> surveyResponses = parseSurveyResponses(response.body);
//        manageSurveyResponses(surveyResponses);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<SurveyPojo> parseSurveys(String responseBody) {
    var decode = json.decode(responseBody);
    return decode
        .map<SurveyPojo>((value) => SurveyPojo.fromMap(value))
        .toList();
  }

  List<SurveyResponse> parseSurveyResponses(String responseBody) {
    var decode = json.decode(responseBody);
    return decode
        .map<SurveyResponse>((value) => SurveyResponse.fromJsonMap(value))
        .toList();
  }

  manageSurveyResponses(List<SurveyResponse> surveyResponses) async {
    if (surveyResponses != null) {
      for (SurveyResponse surveyResponse in surveyResponses) {
        SurveyResponse existingSurveyResponse =
        await DBProvider.db.getSurveyResponseByUniqueId(surveyResponse.uniqueId);
        if (existingSurveyResponse == null) {
          await DBProvider.db.createSurveyResponse(surveyResponse);
        } else {
          await DBProvider.db.updateSurveyResponse(surveyResponse);
        }
      }
    }
  }

  manageSurvey(Survey survey) async {
    Survey existingSurvey = await DBProvider.db.getSurvey(survey.id);
    if (existingSurvey == null) {
      await DBProvider.db.createSurvey(survey);
    } else {
      await DBProvider.db.updateSurvey(survey);
    }
  }

  manageSurveySections(List<SurveySection> surveySections) async {
    if (surveySections != null) {
      for (SurveySection surveySection in surveySections) {
        SurveySection existingSurveySection =
            await DBProvider.db.getSurveySection(surveySection.id);
        if (existingSurveySection == null) {
          await DBProvider.db.createSurveySection(surveySection);
        } else {
          await DBProvider.db.updateSurveySection(surveySection);
        }
      }
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
          SurveyQuestionAnswerChoice questionAnswerChoice = await DBProvider.db.getSurveyQuestionAnswerChoice(surveyQuestionAnswerChoice.id);
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

 Future<int> uploadSurveyResponse(String surveyResponseUniqueId) async {
    SurveyResponse surveyResponse =
        await DBProvider.db.getSurveyResponseByUniqueId(surveyResponseUniqueId);
    String username = await FileStorage.readUsername();
    surveyResponse.username = username;
    String credentials = await FileStorage.readCredentials();
    oauth2.Client cl = oauth2.Client(oauth2.Credentials.fromJson(credentials),
        identifier: "escontrol", secret: "escontrol");
    String surveyResponseJson = SurveyResponse.clientToJson(surveyResponse);
    try {
      Response response = await cl.post(
          Constants.host + "rest/api/v1/surveyResponse/create",
          body: surveyResponseJson,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          encoding: Encoding.getByName("utf-8"));
      return response.statusCode;
    }catch(e){
      return HttpStatus.networkConnectTimeoutError;
    }
  }

  void cleanUpDatabase() async {
    await DBProvider.db.deleteAll();
  }
}
