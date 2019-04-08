import 'dart:convert';

import 'package:es_control_app/util/utilities.dart';

SurveyQuestionAnswerChoiceSelection clientFromJson(String str) {
  final jsonData = json.decode(str);
  return SurveyQuestionAnswerChoiceSelection.fromJsonMap(jsonData);
}

String clientToJson(SurveyQuestionAnswerChoiceSelection data) {
  final dyn = data.toDbMap();
  return json.encode(dyn);
}

class SurveyQuestionAnswerChoiceSelection {
  int id;
  int surveyQuestionAnswerChoiceId;
  String label;

  SurveyQuestionAnswerChoiceSelection({
    this.id,
    this.surveyQuestionAnswerChoiceId,
    this.label,
  });

  factory SurveyQuestionAnswerChoiceSelection.fromJsonMap(
          Map<String, dynamic> json) =>
      new SurveyQuestionAnswerChoiceSelection(
        id: json["id"],
        surveyQuestionAnswerChoiceId: getSurveyQuestionAnswerChoiceIdFromJson(
            json["surveyQuestionAnswerChoice"]),
        label: json["label"],
      );

  factory SurveyQuestionAnswerChoiceSelection.fromDbMap(
          Map<String, dynamic> json) =>
      new SurveyQuestionAnswerChoiceSelection(
        id: json["id"],
        surveyQuestionAnswerChoiceId: json["survey_question_answer_choice_id"],
        label: json["label"],
      );

  Map<String, dynamic> toDbMap() => {
        "id": id,
        "survey_question_answer_choice_id": surveyQuestionAnswerChoiceId,
        "label": label,
      };

  @override
  String toString() {
    return 'SurveyQuestionAnswerChoiceSelection{id: $id, surveyQuestionAnswerChoice: $surveyQuestionAnswerChoiceId, label: $label}';
  }
}
