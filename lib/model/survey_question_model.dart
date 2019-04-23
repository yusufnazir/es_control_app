import 'dart:convert';

import 'package:es_control_app/util/utilities.dart';

class SurveyQuestion {
  static final String tableSurveyQuestions = "SurveyQuestions";
  static final String columnId = "id";
  static final String columnSurveyId = "survey_id";

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

  SurveyQuestion clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyQuestion.fromJsonMap(jsonData);
  }

  String clientToJson(SurveyQuestion data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory SurveyQuestion.fromJsonMap(Map<String, dynamic> json) =>
      new SurveyQuestion(
        id: json["id"],
        active: json["active"] == true,
        surveyId: Utilities.getSurveyIdFromJson(json["survey"]),
        question: json["question"],
        questionDescription: json["questionDescription"],
        order: json["order"],
        questionType: json["questionType"],
        required: json["required"] == true,
        requiredError: json["requiredError"],
        multipleSelection: json["multipleSelection"] == true,
        groupId: Utilities.getSurveyIdFromJson(json["surveyGroup"]),
      );

  factory SurveyQuestion.fromDbMap(Map<String, dynamic> json) =>
      new SurveyQuestion(
        id: json[columnId],
        active: json["active"] == 1,
        surveyId: json[columnSurveyId],
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
        columnId: id,
        "active": active,
        columnSurveyId: surveyId,
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyQuestion &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          active == other.active &&
          surveyId == other.surveyId &&
          question == other.question &&
          questionDescription == other.questionDescription &&
          order == other.order &&
          questionType == other.questionType &&
          required == other.required &&
          requiredError == other.requiredError &&
          multipleSelection == other.multipleSelection &&
          groupId == other.groupId;

  @override
  int get hashCode =>
      id.hashCode ^
      active.hashCode ^
      surveyId.hashCode ^
      question.hashCode ^
      questionDescription.hashCode ^
      order.hashCode ^
      questionType.hashCode ^
      required.hashCode ^
      requiredError.hashCode ^
      multipleSelection.hashCode ^
      groupId.hashCode;

  @override
  String toString() {
    return 'SurveyQuestion{id: $id, active: $active, surveyId: $surveyId, question: $question, questionDescription: $questionDescription, order: $order, questionType: $questionType, required: $required, requiredError: $requiredError, multipleSelection: $multipleSelection, groupId: $groupId}';
  }
}
