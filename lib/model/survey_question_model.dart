import 'dart:convert';

import 'package:es_control_app/util/utilities.dart';

SurveyQuestion clientFromJson(String str) {
  final jsonData = json.decode(str);
  return SurveyQuestion.fromJsonMap(jsonData);
}

String clientToJson(SurveyQuestion data) {
  final dyn = data.toDbMap();
  return json.encode(dyn);
}

class SurveyQuestion {
  int id;
  bool active;
  int surveyId;
  String question;
  String questionDescription;
  int order;
  String questionType;
  bool required;
  String requiredError;
  bool multipleSelection;
  int groupId;

  SurveyQuestion(
      {this.id,
      this.active,
      this.surveyId,
      this.question,
      this.questionDescription,
      this.order,
      this.questionType,
      this.required,
      this.requiredError,
      this.multipleSelection,
      this.groupId});

  factory SurveyQuestion.fromJsonMap(Map<String, dynamic> json) =>
      new SurveyQuestion(
        id: json["id"],
        active: json["active"] == true,
        surveyId: getSurveyIdFromJson(json["survey"]),
        question: json["question"],
        questionDescription: json["questionDescription"],
        order: json["order"],
        questionType: json["questionType"],
        required: json["required"] == true,
        requiredError: json["requiredError"],
        multipleSelection: json["multipleSelection"] == true,
        groupId: getSurveyIdFromJson(json["surveyGroup"]),
      );

  factory SurveyQuestion.fromDbMap(Map<String, dynamic> json) =>
      new SurveyQuestion(
        id: json["id"],
        active: json["active"] == 1,
        surveyId: json["survey_id"],
        question: json["question"],
        questionDescription: json["question_description"],
        order: json["order_"],
        questionType: json["question_type"],
        required: json["required"] == 1,
        requiredError: json["required_error"],
        multipleSelection: json["multiple_selection"] == 1,
        groupId: json["group_id"],
      );

  Map<String, dynamic> toDbMap() => {
        "id": id,
        "active": active,
        "survey_id": surveyId,
        "question": question,
        "question_description": questionDescription,
        "order_": order,
        "question_type": questionType,
        "required": required,
        "required_error": requiredError,
        "multiple_selection": multipleSelection,
        "group_id": groupId,
      };

  @override
  String toString() {
    return 'SurveyQuestion{id: $id, active: $active, surveyId: $surveyId, question: $question, questionDescription: $questionDescription, order: $order, questionType: $questionType, required: $required, requiredError: $requiredError, multipleSelection: $multipleSelection, groupId: $groupId}';
  }
}
