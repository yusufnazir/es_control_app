import 'dart:convert';

import 'package:es_control_app/model/survey_section_model.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_selection_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';

SurveyPojo clientFromJson(String str) {
  final jsonData = json.decode(str);
  return SurveyPojo.fromMap(jsonData);
}

String clientToJson(SurveyPojo data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class SurveyPojo {
  Survey survey;
  List<SurveySection> surveySections;
  List<SurveyQuestion> surveyQuestions;
  List<SurveyQuestionAnswerChoice> surveyQuestionAnswerChoices;
  List<SurveyQuestionAnswerChoiceSelection>
      surveyQuestionAnswerChoiceSelections;

  SurveyPojo({
    this.survey,
    this.surveySections,
    this.surveyQuestions,
    this.surveyQuestionAnswerChoices,
    this.surveyQuestionAnswerChoiceSelections,
  });

  factory SurveyPojo.fromMap(Map<String, dynamic> json) => new SurveyPojo(
        survey: Survey.fromJsonMap(json["survey"]),
        surveySections: json["surveySections"]
            .map<SurveySection>((value) => SurveySection.fromJsonMap(value)).toList(),
        surveyQuestions: json["surveyQuestions"]
            .map<SurveyQuestion>((value) => SurveyQuestion.fromJsonMap(value))
            .toList(),
        surveyQuestionAnswerChoices: json["surveyQuestionAnswerChoices"]
            .map<SurveyQuestionAnswerChoice>((value) => SurveyQuestionAnswerChoice.fromJsonMap(value))
            .toList(),
        surveyQuestionAnswerChoiceSelections: json[
                "surveyQuestionAnswerChoiceSelections"]
            .map<SurveyQuestionAnswerChoiceSelection>((value) => SurveyQuestionAnswerChoiceSelection.fromJsonMap(value))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        "survey": survey,
        "surveySections": surveySections,
        "surveyQuestions": surveyQuestions,
        "surveyQuestionAnswerChoices": surveyQuestionAnswerChoices,
        "surveyQuestionAnswerChoiceSelections":
            surveyQuestionAnswerChoiceSelections,
      };
}
