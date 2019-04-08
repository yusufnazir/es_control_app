import 'package:intl/intl.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';

DateTime getDateTimeFromJson(String dateTime){
  if(dateTime==null){
    return null;
  }
  return DateFormat('yyyy-MM-dd – kk:mm').parse(dateTime);
}

int getSurveyIdFromJson(Map<String, dynamic> json){
  Survey survey = Survey.fromJsonMap(json);
  if(survey==null){
    return null;
  }
  return survey.id;
}

int getGroupIdFromJson(Map<String, dynamic> json){
  SurveyGroup surveyGroup = SurveyGroup.fromJsonMap(json);
  if(surveyGroup==null){
    return null;
  }
  return surveyGroup.id;
}

int getSurveyQuestionIdFromJson(Map<String, dynamic> json){
  SurveyQuestion surveyQuestion = SurveyQuestion.fromJsonMap(json);
  if(surveyQuestion==null){
    return null;
  }
  return surveyQuestion.id;
}

int getSurveyQuestionAnswerChoiceIdFromJson(Map<String, dynamic> json){
  SurveyQuestionAnswerChoice surveyQuestionAnswerChoice = SurveyQuestionAnswerChoice.fromJsonMap(json);
  if(surveyQuestionAnswerChoice==null){
    return null;
  }
  return surveyQuestionAnswerChoice.id;
}