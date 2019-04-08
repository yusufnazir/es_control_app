import 'dart:convert';
import 'package:es_control_app/util/utilities.dart';
import 'survey_question_model.dart';

SurveyQuestionAnswerChoice clientFromJson(String str) {
  final jsonData = json.decode(str);
  return SurveyQuestionAnswerChoice.fromJsonMap(jsonData);
}

String clientToJson(SurveyQuestionAnswerChoice data) {
  final dyn = data.toDbMap();
  return json.encode(dyn);
}

class SurveyQuestionAnswerChoice {
  int id;
  int surveyQuestionId;
  String label;
  String questionType;
  String axis;
  String matrixColumnType;
  int index;
  int minLength;
  int maxLength;
  double minValue;
  double maxValue;
  String minDate;
  String maxDate;
  bool validate;
  String validationError;
  bool multipleSelection;
  bool isOther;
  int makeSelectedQuestionRequired;

  SurveyQuestionAnswerChoice({
    this.id,
    this.surveyQuestionId,
    this.label,
    this.questionType,
    this.axis,
    this.matrixColumnType,
    this.index,
    this.minLength,
    this.maxLength,
    this.minValue,
    this.maxValue,
    this.minDate,
    this.maxDate,
    this.validate,
    this.validationError,
    this.multipleSelection,
    this.isOther,
    this.makeSelectedQuestionRequired,
  });

  factory SurveyQuestionAnswerChoice.fromJsonMap(Map<String, dynamic> json) =>
      new SurveyQuestionAnswerChoice(
        id: json["id"],
        surveyQuestionId: getSurveyQuestionIdFromJson(json["surveyQuestion"]),
        label: json["label"],
        questionType: json["questionType"],
        axis: json["axis"],
        matrixColumnType: json["matrixColumnType"],
        index: json["index"],
        minLength: json["minLength"],
        maxLength: json["maxLength"],
        minValue: json["minValue"],
        maxValue: json["maxValue"],
        minDate: json["minDate"],
        maxDate: json["maxDate"],
        validate: json["validate"] == true,
        validationError: json["validationError"],
        multipleSelection: json["multipleSelection"] == true,
        isOther: json["isOther"] == true,
        makeSelectedQuestionRequired: json["makeSelectedQuestionRequired"],
      );

  factory SurveyQuestionAnswerChoice.fromDbMap(Map<String, dynamic> json) =>
      new SurveyQuestionAnswerChoice(
        id: json["id"],
        surveyQuestionId: json["survey_question_id"],
        label: json["label"],
        questionType: json["question_type"],
        axis: json["axis"],
        matrixColumnType: json["matrix_column_type"],
        index: json["index_"],
        minLength: json["min_length"],
        maxLength: json["max_length"],
        minValue: json["min_value"],
        maxValue: json["max_value"],
        minDate: json["min_date"],
        maxDate: json["max_date"],
        validate: json["validate"] == 1,
        validationError: json["validation_error"],
        multipleSelection: json["multiple_selection"] == 1,
        isOther: json["is_other"] == 1,
        makeSelectedQuestionRequired: json["make_selected_question_required"],
      );

  Map<String, dynamic> toDbMap() => {
        "id": id,
        "survey_question_id": surveyQuestionId,
        "label": label,
        "question_type": questionType,
        "axis": axis,
        "matrix_column_type": matrixColumnType,
        "index_": index,
        "min_length": minLength,
        "max_length": maxLength,
        "min_value": minValue,
        "max_value": maxValue,
        "min_date": minDate,
        "max_date": maxDate,
        "validate": validate,
        "validation_error": validationError,
        "multiple_selection": multipleSelection,
        "is_other": isOther,
        "make_selected_question_required": makeSelectedQuestionRequired,
      };

  @override
  String toString() {
    return 'SurveyQuestionAnswerChoice{id: $id, surveyQuestionId: $surveyQuestionId, label: $label, questionType: $questionType, axis: $axis, matrixColumnType: $matrixColumnType, index: $index, minLength: $minLength, maxLength: $maxLength, minValue: $minValue, maxValue: $maxValue, minDate: $minDate, maxDate: $maxDate, validate: $validate, validationError: $validationError, multipleSelection: $multipleSelection, isOther: $isOther, makeSelectedQuestionRequired: $makeSelectedQuestionRequired}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SurveyQuestionAnswerChoice &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              surveyQuestionId == other.surveyQuestionId &&
              label == other.label &&
              questionType == other.questionType &&
              axis == other.axis &&
              matrixColumnType == other.matrixColumnType &&
              index == other.index &&
              minLength == other.minLength &&
              maxLength == other.maxLength &&
              minValue == other.minValue &&
              maxValue == other.maxValue &&
              minDate == other.minDate &&
              maxDate == other.maxDate &&
              validate == other.validate &&
              validationError == other.validationError &&
              multipleSelection == other.multipleSelection &&
              isOther == other.isOther &&
              makeSelectedQuestionRequired ==
                  other.makeSelectedQuestionRequired;

  @override
  int get hashCode =>
      id.hashCode ^
      surveyQuestionId.hashCode ^
      label.hashCode ^
      questionType.hashCode ^
      axis.hashCode ^
      matrixColumnType.hashCode ^
      index.hashCode ^
      minLength.hashCode ^
      maxLength.hashCode ^
      minValue.hashCode ^
      maxValue.hashCode ^
      minDate.hashCode ^
      maxDate.hashCode ^
      validate.hashCode ^
      validationError.hashCode ^
      multipleSelection.hashCode ^
      isOther.hashCode ^
      makeSelectedQuestionRequired.hashCode;




}
