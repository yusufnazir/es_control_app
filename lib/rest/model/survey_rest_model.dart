import 'dart:convert';

import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_selection_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_section_model.dart';

SurveyRestModel clientFromJson(String str) {
  final jsonData = json.decode(str);
  return SurveyRestModel.fromMap(jsonData);
}

String clientToJson(SurveyRestModel data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class SurveyRestModel {
  Survey survey;
  List<SurveySection> surveySections;
  List<SurveyGroup> surveyGroups;
  List<SurveyQuestion> surveyQuestions;
  List<SurveyQuestionAnswerChoice> surveyQuestionAnswerChoices;
  List<SurveyQuestionAnswerChoiceSelection>
      surveyQuestionAnswerChoiceSelections;

  SurveyRestModel({
    this.survey,
    this.surveySections,
    this.surveyGroups,
    this.surveyQuestions,
    this.surveyQuestionAnswerChoices,
    this.surveyQuestionAnswerChoiceSelections,
  });

  factory SurveyRestModel.fromMap(Map<String, dynamic> json) => new SurveyRestModel(
        survey: Survey.fromJsonMap(json["survey"]),
        surveySections: json["surveySections"]
            .map<SurveySection>((value) => SurveySection.fromJsonMap(value))
            .toList(),
        surveyGroups: json["surveyGroups"]
            .map<SurveyGroup>((value) => SurveyGroup.fromJsonMap(value))
            .toList(),
        surveyQuestions: json["surveyQuestions"]
            .map<SurveyQuestion>((value) => SurveyQuestion.fromJsonMap(value))
            .toList(),
        surveyQuestionAnswerChoices: json["surveyQuestionAnswerChoices"]
            .map<SurveyQuestionAnswerChoice>(
                (value) => SurveyQuestionAnswerChoice.fromJsonMap(value))
            .toList(),
        surveyQuestionAnswerChoiceSelections:
            json["surveyQuestionAnswerChoiceSelections"]
                .map<SurveyQuestionAnswerChoiceSelection>((value) =>
                    SurveyQuestionAnswerChoiceSelection.fromJsonMap(value))
                .toList(),
      );

  Map<String, dynamic> toMap() => {
        "survey": survey,
        "surveySections": surveySections,
        "surveyGroups": surveyGroups,
        "surveyQuestions": surveyQuestions,
        "surveyQuestionAnswerChoices": surveyQuestionAnswerChoices,
        "surveyQuestionAnswerChoiceSelections":
            surveyQuestionAnswerChoiceSelections,
      };
}
