import 'dart:convert';

class SurveyQuestionAnswerChoice {
  static final String tableSurveyQuestionAnswerChoices =
      "SurveyQuestionAnswerChoices";
  static final String columnId = "id";
  static final String columnSurveyQuestionId = "survey_question_id";
  static final String columnLabel = "label";
  static final String columnQuestionType = "question_type";
  static final String columnAxis = "axis";
  static final String columnMatrixColumnType = "matrix_column_type";
  static final String columnIndex = "index_";
  static final String columnMinLength = "min_length";
  static final String columnMaxLength = "max_length";
  static final String columnMinValue = "min_value";
  static final String columnMaxValue = "max_value";
  static final String columnMinDate = "min_date";
  static final String columnMaxDate = "max_date";
  static final String columnValidate = "validate";
  static final String columnValidationError = "validation_error";
  static final String columnMultipleSelection = "multiple_selection";
  static final String columnIsOther = "is_other";
  static final String columnMakeSelectedQuestionRequired =
      "make_selected_question_required";
  static final String columnMakeSelectedGroupRequired =
      "make_selected_group_required";

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
  int makeSelectedGroupRequired;

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
    this.makeSelectedGroupRequired,
  });

  SurveyQuestionAnswerChoice clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyQuestionAnswerChoice.fromJsonMap(jsonData);
  }

  String clientToJson(SurveyQuestionAnswerChoice data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory SurveyQuestionAnswerChoice.fromJsonMap(Map<String, dynamic> json) {
    if (json != null) {
      return SurveyQuestionAnswerChoice(
        id: json["id"],
        surveyQuestionId:json["surveyQuestionId"],
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
        makeSelectedGroupRequired: json["makeSelectedGroupRequired"],
      );
    }
    return null;
  }

  factory SurveyQuestionAnswerChoice.fromDbMap(Map<String, dynamic> json) {
    if (json != null) {
      return SurveyQuestionAnswerChoice(
        id: json[columnId],
        surveyQuestionId: json[columnSurveyQuestionId],
        label: json[columnLabel],
        questionType: json[columnQuestionType],
        axis: json[columnAxis],
        matrixColumnType: json[columnMatrixColumnType],
        index: json[columnIndex],
        minLength: json[columnMinLength],
        maxLength: json[columnMaxLength],
        minValue: json[columnMinValue],
        maxValue: json[columnMaxValue],
        minDate: json[columnMinDate],
        maxDate: json[columnMaxDate],
        validate: json[columnValidate] == 1,
        validationError: json[columnValidationError],
        multipleSelection: json[columnMultipleSelection] == 1,
        isOther: json[columnIsOther] == 1,
        makeSelectedQuestionRequired: json[columnMakeSelectedQuestionRequired],
        makeSelectedGroupRequired: json[columnMakeSelectedGroupRequired],
      );
    }
    return null;
  }

  Map<String, dynamic> toDbMap() => {
        columnId: id,
        columnSurveyQuestionId: surveyQuestionId,
        columnLabel: label,
        columnQuestionType: questionType,
        columnAxis: axis,
        columnMatrixColumnType: matrixColumnType,
        columnIndex: index,
        columnMinLength: minLength,
        columnMaxLength: maxLength,
        columnMinValue: minValue,
        columnMaxValue: maxValue,
        columnMinDate: minDate,
        columnMaxDate: maxDate,
        columnValidate: validate,
        columnValidationError: validationError,
        columnMultipleSelection: multipleSelection,
        columnIsOther: isOther,
        columnMakeSelectedQuestionRequired: makeSelectedQuestionRequired,
        columnMakeSelectedGroupRequired: makeSelectedGroupRequired,
      };

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
          makeSelectedQuestionRequired == other.makeSelectedQuestionRequired &&
          makeSelectedGroupRequired == other.makeSelectedGroupRequired;

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
      makeSelectedQuestionRequired.hashCode ^
      makeSelectedGroupRequired.hashCode;

  @override
  String toString() {
    return 'SurveyQuestionAnswerChoice{id: $id, surveyQuestionId: $surveyQuestionId, label: $label, questionType: $questionType, axis: $axis, matrixColumnType: $matrixColumnType, index: $index, minLength: $minLength, maxLength: $maxLength, minValue: $minValue, maxValue: $maxValue, minDate: $minDate, maxDate: $maxDate, validate: $validate, validationError: $validationError, multipleSelection: $multipleSelection, isOther: $isOther, makeSelectedQuestionRequired: $makeSelectedQuestionRequired, makeSelectedGroupRequired: $makeSelectedGroupRequired}';
  }
}
