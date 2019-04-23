import 'dart:convert';

import 'package:es_control_app/util/utilities.dart';

class SurveyResponseAnswer {
  static final String tableSurveyResponseAnswers = "SurveyResponseAnswers";

  static final String columnId = "id";
  static final String columnUniqueId = "unique_id";
  static final String columnActive = "active";
  static final String columnSurveyResponseUniqueId =
      "survey_response_unique_id";
  static final String columnSurveyQuestionId = "survey_question_id";
  static final String columnSurveyQuestionChoiceRowId =
      "survey_question_choice_row_id";
  static final String columnSurveyQuestionChoiceColumnId =
      "survey_question_choice_column_id";
  static final String columnSurveyQuestionChoiceSelectionId =
      "survey_question_choice_selection_id";
  static final String columnQuestionType = "question_type";
  static final String columnResponseText = "response_text";
  static final String columnOtherValue = "other_value";
  static final String columnSelected = "selected";

  int id;
  String uniqueId;
  bool active;
  String surveyResponseUniqueId;
  int surveyQuestionId;
  int surveyQuestionAnswerChoiceRowId;
  int surveyQuestionAnswerChoiceColumnId;
  int surveyQuestionAnswerChoiceSelectionId;
  String questionType;
  String matrixColumnType;
  String responseText;
  String otherValue;
  bool selected;

  SurveyResponseAnswer({
    this.id,
    this.uniqueId,
    this.active,
    this.surveyResponseUniqueId,
    this.surveyQuestionId,
    this.surveyQuestionAnswerChoiceRowId,
    this.surveyQuestionAnswerChoiceColumnId,
    this.surveyQuestionAnswerChoiceSelectionId,
    this.questionType,
    this.responseText,
    this.otherValue,
    this.selected,
  });

  SurveyResponseAnswer clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyResponseAnswer.fromJsonMap(jsonData);
  }

  String clientToJson(SurveyResponseAnswer data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory SurveyResponseAnswer.fromJsonMap(Map<String, dynamic> json) =>
      new SurveyResponseAnswer(
          id: json["id"],
          uniqueId: json["uniqueId"],
          active: json["active"] == true,
          surveyResponseUniqueId: Utilities.getSurveyResponseUniqueIdFromJson(
              json["surveyResponseUniqueId"]),
          surveyQuestionId: Utilities.getSurveyQuestionAnswerChoiceIdFromJson(
              json["surveyQuestionId"]),
          surveyQuestionAnswerChoiceRowId:
              Utilities.getSurveyQuestionAnswerChoiceIdFromJson(
                  json["surveyQuestionAnswerChoiceRowId"]),
          surveyQuestionAnswerChoiceColumnId:
              Utilities.getSurveyQuestionAnswerChoiceIdFromJson(
                  json["surveyQuestionAnswerChoiceColumnId"]),
          surveyQuestionAnswerChoiceSelectionId:
              Utilities.getSurveyQuestionAnswerChoiceSelectionIdFromJson(
                  json["surveyQuestionAnswerChoiceSelectionId"]),
          questionType: json["questionType"],
          responseText: json["responseText"],
          otherValue: json["otherValue"],
          selected: json["selected"] == true);

  factory SurveyResponseAnswer.fromDbMap(Map<String, dynamic> json) =>
      new SurveyResponseAnswer(
        id: json[columnId],
        uniqueId: json[columnUniqueId],
        surveyResponseUniqueId: json[columnSurveyResponseUniqueId],
        surveyQuestionId: json[columnSurveyQuestionId],
        surveyQuestionAnswerChoiceRowId: json[columnSurveyQuestionChoiceRowId],
        surveyQuestionAnswerChoiceColumnId:
            json[columnSurveyQuestionChoiceColumnId],
        surveyQuestionAnswerChoiceSelectionId:
            json[columnSurveyQuestionChoiceSelectionId],
        questionType: json[columnQuestionType],
        responseText: json[columnResponseText],
        otherValue: json[columnOtherValue],
        active: json[columnActive] == 1,
        selected: json[columnSelected] == 1,
      );

  Map<String, dynamic> toDbMap() => {
        columnId: id,
        columnUniqueId: uniqueId,
        columnSurveyResponseUniqueId: surveyResponseUniqueId,
        columnSurveyQuestionId: surveyQuestionId,
        columnSurveyQuestionChoiceRowId: surveyQuestionAnswerChoiceRowId,
        columnSurveyQuestionChoiceColumnId: surveyQuestionAnswerChoiceColumnId,
        columnSurveyQuestionChoiceSelectionId:
            surveyQuestionAnswerChoiceSelectionId,
        columnQuestionType: questionType,
        columnResponseText: responseText,
        columnOtherValue: otherValue,
        columnActive: active,
        columnSelected: selected
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyResponseAnswer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          uniqueId == other.uniqueId &&
          active == other.active &&
          surveyResponseUniqueId == other.surveyResponseUniqueId &&
          surveyQuestionId == other.surveyQuestionId &&
          surveyQuestionAnswerChoiceRowId ==
              other.surveyQuestionAnswerChoiceRowId &&
          surveyQuestionAnswerChoiceColumnId ==
              other.surveyQuestionAnswerChoiceColumnId &&
          surveyQuestionAnswerChoiceSelectionId ==
              other.surveyQuestionAnswerChoiceSelectionId &&
          questionType == other.questionType &&
          matrixColumnType == other.matrixColumnType &&
          responseText == other.responseText &&
          otherValue == other.otherValue &&
          selected == other.selected;

  @override
  int get hashCode =>
      id.hashCode ^
      uniqueId.hashCode ^
      active.hashCode ^
      surveyResponseUniqueId.hashCode ^
      surveyQuestionId.hashCode ^
      surveyQuestionAnswerChoiceRowId.hashCode ^
      surveyQuestionAnswerChoiceColumnId.hashCode ^
      surveyQuestionAnswerChoiceSelectionId.hashCode ^
      questionType.hashCode ^
      matrixColumnType.hashCode ^
      responseText.hashCode ^
      otherValue.hashCode ^
      selected.hashCode;

  @override
  String toString() {
    return 'SurveyResponseAnswer{id: $id, uniqueId: $uniqueId, active: $active, surveyResponseUniqueId: $surveyResponseUniqueId, surveyQuestionId: $surveyQuestionId, surveyQuestionAnswerChoiceRowId: $surveyQuestionAnswerChoiceRowId, surveyQuestionAnswerChoiceColumnId: $surveyQuestionAnswerChoiceColumnId, surveyQuestionAnswerChoiceSelectionId: $surveyQuestionAnswerChoiceSelectionId, questionType: $questionType, matrixColumnType: $matrixColumnType, responseText: $responseText, otherValue: $otherValue, selected: $selected}';
  }
}
