import 'dart:convert';

import 'package:es_control_app/model/survey_group_model.dart';
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
  List<SurveyGroup> surveyGroups;
  List<SurveyQuestion> surveyQuestions;
  List<SurveyQuestionAnswerChoice> surveyQuestionAnswerChoices;
  List<SurveyQuestionAnswerChoiceSelection>
      surveyQuestionAnswerChoiceSelections;

  SurveyPojo({
    this.survey,
    this.surveyGroups,
    this.surveyQuestions,
    this.surveyQuestionAnswerChoices,
    this.surveyQuestionAnswerChoiceSelections,
  });

  factory SurveyPojo.fromMap(Map<String, dynamic> json) => new SurveyPojo(
        survey: Survey.fromMap(json["survey"]),
        surveyGroups: json["surveyGroups"]
            .map<SurveyGroup>((value) => SurveyGroup.fromMap(value)).toList(),
        surveyQuestions: json["surveyQuestions"]
            .map<SurveyQuestion>((value) => SurveyQuestion.fromMap(value))
            .toList(),
        surveyQuestionAnswerChoices: json["surveyQuestionAnswerChoices"]
            .map<SurveyQuestionAnswerChoice>((value) => SurveyQuestionAnswerChoice.fromMap(value))
            .toList(),
        surveyQuestionAnswerChoiceSelections: json[
                "surveyQuestionAnswerChoiceSelections"]
            .map<SurveyQuestionAnswerChoiceSelection>((value) => SurveyQuestionAnswerChoiceSelection.fromMap(value))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        "survey": survey,
        "surveyGroups": surveyGroups,
        "surveyQuestions": surveyQuestions,
        "surveyQuestionAnswerChoices": surveyQuestionAnswerChoices,
        "surveyQuestionAnswerChoiceSelections":
            surveyQuestionAnswerChoiceSelections,
      };
}
