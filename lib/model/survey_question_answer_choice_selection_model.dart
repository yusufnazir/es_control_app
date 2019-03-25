import 'dart:convert';

import 'survey_question_answer_choice_model.dart';

SurveyQuestionAnswerChoiceSelection clientFromJson(String str) {
  final jsonData = json.decode(str);
  return SurveyQuestionAnswerChoiceSelection.fromMap(jsonData);
}

String clientToJson(SurveyQuestionAnswerChoiceSelection data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class SurveyQuestionAnswerChoiceSelection {
  int id;
  SurveyQuestionAnswerChoice surveyQuestionAnswerChoice;
  String label;

  SurveyQuestionAnswerChoiceSelection({
    this.id,
    this.surveyQuestionAnswerChoice,
    this.label,
  });

  factory SurveyQuestionAnswerChoiceSelection.fromMap(
          Map<String, dynamic> json) =>
      new SurveyQuestionAnswerChoiceSelection(
        id: json["id"],
        surveyQuestionAnswerChoice: SurveyQuestionAnswerChoice.fromMap(json["surveyQuestionAnswerChoice"]),
        label: json["label"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "survey_question_answer_choice_id": surveyQuestionAnswerChoice.id,
        "label": label,
      };

  @override
  String toString() {
    return 'SurveyQuestionAnswerChoiceSelection{id: $id, surveyQuestionAnswerChoice: $surveyQuestionAnswerChoice, label: $label}';
  }
}
