import 'dart:convert';

import 'survey_question_model.dart';

SurveyQuestionAnswerChoice clientFromJson(String str) {
  final jsonData = json.decode(str);
  return SurveyQuestionAnswerChoice.fromMap(jsonData);
}

String clientToJson(SurveyQuestionAnswerChoice data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class SurveyQuestionAnswerChoice {
  int id;
  SurveyQuestion surveyQuestion;
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
    this.surveyQuestion,
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

  factory SurveyQuestionAnswerChoice.fromMap(Map<String, dynamic> json) =>
      new SurveyQuestionAnswerChoice(
        id: json["id"],
        surveyQuestion: SurveyQuestion.fromMap(json["surveyQuestion"]),
        label: json["label"],
        questionType: json["questionType"],
        axis: json["axis"],
        minLength: json["minLength"],
        maxLength: json["maxLength"],
        minValue: json["minValue"],
        maxValue: json["maxValue"],
        minDate: json["minDate"],
        maxDate: json["maxDate"],
        validate: json["validate"] == 1,
        validationError: json["validationError"],
        multipleSelection: json["multipleSelection"] == 1,
        isOther: json["isOther"] == 1,
        makeSelectedQuestionRequired: json["makeSelectedQuestionRequired"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "survey_question_id": surveyQuestion.id,
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
        "make_selected_querion_required": makeSelectedQuestionRequired,
      };
}
