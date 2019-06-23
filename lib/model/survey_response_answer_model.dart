import 'dart:convert';

class SurveyResponseAnswer {
  static final String tableSurveyResponseAnswers = "SurveyResponseAnswers";

  static final String columnId = "id";
  static final String columnUniqueId = "unique_id";
  static final String columnActive = "active";
  static final String columnSurveyResponseUniqueId =
      "survey_response_unique_id";
  static final String columnSurveyQuestionId = "survey_question_id";
  static final String columnQuestionType = "question_type";
  static final String columnSurveyQuestionChoiceRowId =
      "survey_question_choice_row_id";
  static final String columnSurveyQuestionChoiceColumnId =
      "survey_question_choice_column_id";
  static final String columnSurveyQuestionChoiceSelectionId =
      "survey_question_choice_selection_id";
  static final String columnResponseText = "response_text";
  static final String columnOtherValue = "other_value";
  static final String columnSelected = "selected";
  static final String columnState = "state";
  static final String columnMatrixColumnType = "matrix_column_type";

  int id;
  String uniqueId;
  bool active;
  String surveyResponseUniqueId;
  int surveyQuestionId;
  String questionType;
  int surveyQuestionAnswerChoiceRowId;
  int surveyQuestionAnswerChoiceColumnId;
  int surveyQuestionAnswerChoiceSelectionId;
  String matrixColumnType;
  String responseText;
  String otherValue;
  bool selected;
  String state;

  SurveyResponseAnswer({
    this.id,
    this.uniqueId,
    this.active,
    this.surveyResponseUniqueId,
    this.surveyQuestionId,
    this.questionType,
    this.surveyQuestionAnswerChoiceRowId,
    this.surveyQuestionAnswerChoiceColumnId,
    this.surveyQuestionAnswerChoiceSelectionId,
    this.responseText,
    this.otherValue,
    this.selected,
    this.state,
    this.matrixColumnType,
  });

  SurveyResponseAnswer clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyResponseAnswer.fromJsonMap(jsonData);
  }

  String clientToJson(SurveyResponseAnswer data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory SurveyResponseAnswer.fromJsonMap(Map<String, dynamic> json) {
    if (json != null) {
      return SurveyResponseAnswer(
        id: json["id"],
        uniqueId: json["uniqueId"],
        active: json["active"] == true,
        surveyResponseUniqueId: json["surveyResponseUniqueId"],
        surveyQuestionId: json["surveyQuestionId"],
        questionType: json["questionType"],
        surveyQuestionAnswerChoiceRowId:
            json["surveyQuestionAnswerChoiceRowId"],
        surveyQuestionAnswerChoiceColumnId:
            json["surveyQuestionAnswerChoiceColumnId"],
        surveyQuestionAnswerChoiceSelectionId:
            json["surveyQuestionAnswerChoiceSelectionId"],
        responseText: json["responseText"],
        otherValue: json["otherValue"],
        selected: json["selected"] == true,
        state: json["state"],
        matrixColumnType: json["matrixColumnType"],
      );
    }
    return null;
  }

  factory SurveyResponseAnswer.fromDbMap(Map<String, dynamic> json) {
    if (json != null) {
      return SurveyResponseAnswer(
          id: json[columnId],
          uniqueId: json[columnUniqueId],
          surveyResponseUniqueId: json[columnSurveyResponseUniqueId],
          surveyQuestionId: json[columnSurveyQuestionId],
          questionType: json[columnQuestionType],
          surveyQuestionAnswerChoiceRowId:
              json[columnSurveyQuestionChoiceRowId],
          surveyQuestionAnswerChoiceColumnId:
              json[columnSurveyQuestionChoiceColumnId],
          surveyQuestionAnswerChoiceSelectionId:
              json[columnSurveyQuestionChoiceSelectionId],
          responseText: json[columnResponseText],
          otherValue: json[columnOtherValue],
          active: json[columnActive] == 1,
          selected: json[columnSelected] == 1,
          state: json[columnState],
          matrixColumnType: json[columnMatrixColumnType]);
    }
    return null;
  }

  Map<String, dynamic> toDbMap() => {
        columnId: id,
        columnUniqueId: uniqueId,
        columnSurveyResponseUniqueId: surveyResponseUniqueId,
        columnSurveyQuestionId: surveyQuestionId,
        columnQuestionType: questionType,
        columnSurveyQuestionChoiceRowId: surveyQuestionAnswerChoiceRowId,
        columnSurveyQuestionChoiceColumnId: surveyQuestionAnswerChoiceColumnId,
        columnSurveyQuestionChoiceSelectionId:
            surveyQuestionAnswerChoiceSelectionId,
        columnResponseText: responseText,
        columnOtherValue: otherValue,
        columnActive: active,
        columnSelected: selected,
        columnState: state,
        columnMatrixColumnType: matrixColumnType
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'uniqueId': uniqueId,
        'active': active,
        'surveyResponseUniqueId': surveyResponseUniqueId,
        'surveyQuestionId': surveyQuestionId,
        'questionType': questionType,
        'surveyQuestionAnswerChoiceRowId': surveyQuestionAnswerChoiceRowId,
        'surveyQuestionAnswerChoiceColumnId':
            surveyQuestionAnswerChoiceColumnId,
        'surveyQuestionAnswerChoiceSelectionId':
            surveyQuestionAnswerChoiceSelectionId,
        'matrixColumnType': matrixColumnType,
        'responseText': responseText,
        'otherValue': otherValue,
        'selected': selected,
        'state': state,
        'matrixColumnType': matrixColumnType,
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
          questionType == other.questionType &&
          surveyQuestionAnswerChoiceRowId ==
              other.surveyQuestionAnswerChoiceRowId &&
          surveyQuestionAnswerChoiceColumnId ==
              other.surveyQuestionAnswerChoiceColumnId &&
          surveyQuestionAnswerChoiceSelectionId ==
              other.surveyQuestionAnswerChoiceSelectionId &&
          matrixColumnType == other.matrixColumnType &&
          responseText == other.responseText &&
          otherValue == other.otherValue &&
          selected == other.selected &&
          state == other.state;

  @override
  int get hashCode =>
      id.hashCode ^
      uniqueId.hashCode ^
      active.hashCode ^
      surveyResponseUniqueId.hashCode ^
      surveyQuestionId.hashCode ^
      questionType.hashCode ^
      surveyQuestionAnswerChoiceRowId.hashCode ^
      surveyQuestionAnswerChoiceColumnId.hashCode ^
      surveyQuestionAnswerChoiceSelectionId.hashCode ^
      matrixColumnType.hashCode ^
      responseText.hashCode ^
      otherValue.hashCode ^
      selected.hashCode ^
      state.hashCode;

  @override
  String toString() {
    return 'SurveyResponseAnswer{id: $id, uniqueId: $uniqueId, active: $active, surveyResponseUniqueId: $surveyResponseUniqueId, surveyQuestionId: $surveyQuestionId, surveyQuestionAnswerChoiceRowId: $surveyQuestionAnswerChoiceRowId, surveyQuestionAnswerChoiceColumnId: $surveyQuestionAnswerChoiceColumnId, surveyQuestionAnswerChoiceSelectionId: $surveyQuestionAnswerChoiceSelectionId, matrixColumnType: $matrixColumnType, responseText: $responseText, otherValue: $otherValue, selected: $selected}';
  }
}
