import 'dart:convert';

import 'survey_model.dart';

SurveyQuestion clientFromJson(String str) {
  final jsonData = json.decode(str);
  return SurveyQuestion.fromMap(jsonData);
}

String clientToJson(SurveyQuestion data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class SurveyQuestion {
  int id;
  bool active;
  Survey survey;
  String question;
  String questionDescription;
  int order;
  String questionType;
  bool required;
  String requiredError;
  bool multipleSelection;

  SurveyQuestion({
    this.id,
    this.active,
    this.survey,
    this.question,
    this.questionDescription,
    this.order,
    this.questionType,
    this.required,
    this.requiredError,
    this.multipleSelection,
  });

  factory SurveyQuestion.fromMap(Map<String, dynamic> json) =>
      new SurveyQuestion(
        id: json["id"],
        active: json["active"] == 1,
        survey: Survey.fromMap(json["survey"]),
        question: json["question"],
        questionDescription: json["questionDescription"],
        order: json["order"],
        questionType: json["questionType"],
        required: json["required"] == 1,
        requiredError: json["requiredError"],
        multipleSelection: json["multipleSelection"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "active": active,
        "survey_id": survey.id,
        "question": question,
        "question_description": questionDescription,
        "order_": order,
        "question_type": questionType,
        "required": required,
        "required_error": requiredError,
        "multiple_selection": multipleSelection,
      };

  @override
  String toString() {
    return 'SurveyQuestion{id: $id, active: $active, survey: $survey, question: $question, questionDescription: $questionDescription, order: $order, questionType: $questionType, required: $required, requiredError: $requiredError, multipleSelection: $multipleSelection}';
  }


}
