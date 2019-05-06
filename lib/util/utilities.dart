import 'package:es_control_app/constants.dart';
import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_section_model.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_selection_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Utilities {
  static DateTime getDateTimeFromJson(String dateTime) {
    if (dateTime == null) {
      return null;
    }
    return DateFormat(Constants.dateFormat).parse(dateTime);
  }

  static int getSurveyIdFromJson(Map<String, dynamic> json) {
    Survey survey = Survey.fromJsonMap(json);
    if (survey == null) {
      return null;
    }
    return survey.id;
  }

  static int getSectionIdFromJson(Map<String, dynamic> json) {
    SurveySection surveySection = SurveySection.fromJsonMap(json);
    if (surveySection == null) {
      return null;
    }
    return surveySection.id;
  }

  static int getGroupIdFromJson(Map<String, dynamic> json) {
    SurveyGroup surveyGroup = SurveyGroup.fromJsonMap(json);
    if (surveyGroup == null) {
      return null;
    }
    return surveyGroup.id;
  }

  static int getSurveyQuestionIdFromJson(Map<String, dynamic> json) {
    SurveyQuestion surveyQuestion = SurveyQuestion.fromJsonMap(json);
    if (surveyQuestion == null) {
      return null;
    }
    return surveyQuestion.id;
  }

  static int getSurveyQuestionAnswerChoiceIdFromJson(Map<String, dynamic> json) {
    SurveyQuestionAnswerChoice surveyQuestionAnswerChoice =
        SurveyQuestionAnswerChoice.fromJsonMap(json);
    if (surveyQuestionAnswerChoice == null) {
      return null;
    }
    return surveyQuestionAnswerChoice.id;
  }

  static int getSurveyResponseAnswerIdFromJson(Map<String, dynamic> json) {
    SurveyResponseAnswer surveyResponseAnswer =
        SurveyResponseAnswer.fromJsonMap(json);
    if (surveyResponseAnswer == null) {
      return null;
    }
    return surveyResponseAnswer.id;
  }

  static String getSurveyResponseUniqueIdFromJson(Map<String, dynamic> json) {
    SurveyResponse surveyResponse =
    SurveyResponse.fromJsonMap(json);
    if (surveyResponse == null) {
      return null;
    }
    return surveyResponse.uniqueId;
  }

  static String getSurveyResponseAnswerUniqueIdFromJson(Map<String, dynamic> json) {
    SurveyResponseAnswer surveyResponseAnswer =
    SurveyResponseAnswer.fromJsonMap(json);
    if (surveyResponseAnswer == null) {
      return null;
    }
    return surveyResponseAnswer.uniqueId;
  }

  static int getSurveyQuestionAnswerChoiceSelectionIdFromJson(Map<String, dynamic> json) {
    SurveyQuestionAnswerChoiceSelection surveyQuestionAnswerChoiceSelection =
    SurveyQuestionAnswerChoiceSelection.fromJsonMap(json);
    if (surveyQuestionAnswerChoiceSelection == null) {
      return null;
    }
    return surveyQuestionAnswerChoiceSelection.id;
  }
}
