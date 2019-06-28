import 'dart:convert';
import 'dart:io';

import 'package:es_control_app/constants.dart';
import 'package:es_control_app/preferences.dart';
import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_selection_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_question_user_model.dart';
import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/model/survey_response_section_model.dart';
import 'package:es_control_app/model/survey_section_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/rest/model/survey_response_rest_model.dart';
import 'package:es_control_app/rest/model/survey_rest_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

import '../survey_state.dart';

const oauthErrors = [
  "invalid_request",
  "invalid_token",
  "invalid_grant",
  "invalid_request",
  "invalid_client",
  "unauthorized_client",
  "unsupported_grant_type",
  "invalid_scope"
];

class RestApi {
  /* Retrieves the surveys from the server and stores this in database.
  The Survey table is cleaned up before storing the retrieved survey.
   */
  Future<int> getSurveysFromServerAndStoreInDB() async {
    try {
//      cleanUpDatabase();
      String credentials = await Preferences.readCredentials();

      oauth2.Client cl = oauth2.Client(oauth2.Credentials.fromJson(credentials),
          identifier: "escontrol", secret: "escontrol");

      var response = await cl.get(Constants.getAllSurveys);
      List<SurveyRestModel> surveyPojos = parseSurveys(response.body);
      if (surveyPojos == null || surveyPojos.length == 0) {
        return 0;
      }
      String username = await Preferences.readUsername();
      await cleanUpSurveyUserForUsername(username);

      if (surveyPojos != null) {
        for (SurveyRestModel surveyPojo in surveyPojos) {
          Survey survey = surveyPojo.survey;
          await manageSurvey(survey);

          List<SurveyQuestionUser> surveyQuestionUsers =
              surveyPojo.surveyQuestionUsers;
          await manageSurveyQuestionUsers(survey.id, surveyQuestionUsers);

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

        var response = await cl.get(Constants.getAllActiveSurveyResponseUuIds);
        List<String> surveyResponseUuIds =
            List<String>.from(json.decode(response.body));
        await DBProvider.db.removeInactiveSurveyResponses(surveyResponseUuIds);

        await DBProvider.db.removeSyncedSurveyResponseAnswers();

        response = await cl.get(Constants.getAllSurveyResponses);
        List<SurveyResponseRestModel> surveyResponses =
            await parseSurveyResponses(response.body);
        await manageSurveyResponses(surveyResponses);

        return surveyPojos.length;
      }
    } on oauth2.AuthorizationException catch (e) {
      debugPrint(e.toString());
      if (oauthErrors.contains(e.error)) {
        return -2;
      }
    }
    return -1;
  }

  List<SurveyRestModel> parseSurveys(String responseBody) {
    var decode = json.decode(responseBody);
    print(decode);
    return decode
        .map<SurveyRestModel>((value) => SurveyRestModel.fromMap(value))
        .toList();
  }

  Future<List<SurveyResponseRestModel>> parseSurveyResponses(
      String responseBody) async {
    var decode = json.decode(responseBody);
    return decode
        .map<SurveyResponseRestModel>(
            (value) => SurveyResponseRestModel.fromMap(value))
        .toList();
  }

  manageSurveyResponses(List<SurveyResponseRestModel> surveyResponses) async {
    if (surveyResponses != null) {
//      debugPrint("surveyResponses $surveyResponses");
      for (SurveyResponseRestModel surveyResponseRestModel in surveyResponses) {
        SurveyResponse surveyResponse = surveyResponseRestModel.surveyResponse;

        SurveyResponse existingSurveyResponse = await DBProvider.db
            .getSurveyResponseByUniqueId(surveyResponse.uniqueId);
        if (existingSurveyResponse == null) {
          await DBProvider.db.createSurveyResponse(surveyResponse);
        } else {
          await DBProvider.db.updateSurveyResponse(surveyResponse);
        }

        List<SurveyResponseSection> surveyResponseSections =
            surveyResponseRestModel.surveyResponseSections;
        if (surveyResponseSections != null) {
          for (SurveyResponseSection surveyResponseSection
              in surveyResponseSections) {
            SurveyResponseSection existingSurveyResponseSection =
                await DBProvider.db
                    .getSurveyResponseSectionByResponseAndSection(
                        surveyResponseSection.surveyResponseUniqueId,
                        surveyResponseSection.surveySectionId);
            if (existingSurveyResponseSection == null) {
              await DBProvider.db
                  .createSurveyResponseSection(surveyResponseSection);
            } else {
              await DBProvider.db
                  .updateSurveyResponseSection(surveyResponseSection);
            }
          }
        }

        List<SurveyResponseAnswer> surveyResponseAnswers =
            surveyResponseRestModel.surveyResponseAnswers;
        if (surveyResponseAnswers != null) {
          for (SurveyResponseAnswer surveyResponseAnswer
              in surveyResponseAnswers) {
            SurveyResponseAnswer existingSurveyResponseAnswer =
                await DBProvider.db.getSurveyResponseAnswerByUniqueId(
                    surveyResponseAnswer.uniqueId);
            if (existingSurveyResponseAnswer == null) {
              await DBProvider.db
                  .createSurveyResponseAnswer(surveyResponseAnswer);
            } else {
              String state = existingSurveyResponseAnswer.state;
              if (state == SurveyState.synced) {
                await DBProvider.db
                    .updateSurveyResponseAnswer(surveyResponseAnswer);
              }
            }
          }
        }
      }
    }
  }

  cleanUpSurveyUserForUsername(String username) async{
    await DBProvider.db.cleanUpSurveyUserForUsername(username);
  }

  manageSurvey(Survey survey) async {
    Survey existingSurvey = await DBProvider.db.getSurvey(survey.id);
    if (existingSurvey == null) {
      await DBProvider.db.createSurvey(survey);
    } else {
      await DBProvider.db.updateSurvey(survey);
    }
    String username = await Preferences.readUsername();
    await DBProvider.db.createSurveyUser(survey.id,username);
  }

  manageSurveyQuestionUsers(int surveyId,
      List<SurveyQuestionUser> surveyQuestionUsers) async {
    await DBProvider.db.deleteSurveyQuestionUserForSurvey(surveyId);
    if (surveyQuestionUsers != null) {
      for (SurveyQuestionUser surveyQuestionUser in surveyQuestionUsers) {
        SurveyQuestionUser existingSurveyQuestionUser =
            await DBProvider.db.getSurveyQuestionUser(surveyQuestionUser.id);
        if (existingSurveyQuestionUser == null) {
          await DBProvider.db.createSurveyQuestionUser(surveyQuestionUser);
        } else {
          await DBProvider.db.updateSurveyQuestionUser(surveyQuestionUser);
        }
      }
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
          await DBProvider.db
              .getSurveyQuestionAnswerChoice(surveyQuestionAnswerChoice.id);
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
    List<SurveyResponseAnswer> surveyResponseAnswers = await DBProvider.db
        .getAllSurveyResponseAnswers(surveyResponse.uniqueId);
    List<SurveyResponseSection> surveyResponseSections = await DBProvider.db
        .getAllSectionsForSurveyResponse(surveyResponse.uniqueId);
    SurveyResponseRestModel surveyResponsePojo = SurveyResponseRestModel(
        surveyResponse: surveyResponse,
        surveyResponseAnswers: surveyResponseAnswers,
        surveyResponseSections: surveyResponseSections);

    String username = await Preferences.readUsername();
    surveyResponse.username = username;
    String credentials = await Preferences.readCredentials();
    oauth2.Client cl = oauth2.Client(oauth2.Credentials.fromJson(credentials),
        identifier: "escontrol", secret: "escontrol");
    String surveyResponseJson =
        SurveyResponseRestModel.clientToJson(surveyResponsePojo);
    try {
      Response response = await cl.post(Constants.uploadAllSurveys,
          body: surveyResponseJson,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          encoding: Encoding.getByName("utf-8"));
      await DBProvider.db
          .getAllSectionsForSurveyResponse(surveyResponse.uniqueId);
      var statusCode = response.statusCode;
      await DBProvider.db
          .updateAllSurveyResponseAnswerAsSynced(surveyResponse.uniqueId);

      return statusCode;
    } on oauth2.AuthorizationException catch (e) {
      debugPrint(e.toString());
      if (oauthErrors.contains(e.error)) {
        return -2;
      }
    } catch (e) {
      return HttpStatus.networkConnectTimeoutError;
    }
    return HttpStatus.ok;
  }

  void cleanUpDatabase() async {
    await DBProvider.db.deleteAll();
  }
}
