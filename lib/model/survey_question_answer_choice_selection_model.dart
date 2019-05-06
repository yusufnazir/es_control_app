import 'dart:convert';

import 'package:es_control_app/util/utilities.dart';

class SurveyQuestionAnswerChoiceSelection {
  static final String tableSurveyQuestionAnswerChoiceSelections =
      "SurveyQuestionAnswerChoiceSelections";
  static final String columnId = "id";
  static final String columnSurveyQuestionAnswerChoiceId =
      "survey_question_answer_choice_id";
  static final String columnLabel = "label";

  int id;
  int surveyQuestionAnswerChoiceId;
  String label;

  SurveyQuestionAnswerChoiceSelection({
    this.id,
    this.surveyQuestionAnswerChoiceId,
    this.label,
  });

  SurveyQuestionAnswerChoiceSelection clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyQuestionAnswerChoiceSelection.fromJsonMap(jsonData);
  }

  String clientToJson(SurveyQuestionAnswerChoiceSelection data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory SurveyQuestionAnswerChoiceSelection.fromJsonMap(
      Map<String, dynamic> json) {
    if(json!=null) {
      return SurveyQuestionAnswerChoiceSelection(
        id: json["id"],
        surveyQuestionAnswerChoiceId:
        Utilities.getSurveyQuestionAnswerChoiceIdFromJson(
            json["surveyQuestionAnswerChoice"]),
        label: json["label"],
      );
    }
    return null;
  }

  factory SurveyQuestionAnswerChoiceSelection.fromDbMap(
          Map<String, dynamic> json) {
    if(json!=null) {
      return SurveyQuestionAnswerChoiceSelection(
        id: json[columnId],
        surveyQuestionAnswerChoiceId: json[columnSurveyQuestionAnswerChoiceId],
        label: json[columnLabel],
      );
    }
    return null;
  }

  Map<String, dynamic> toDbMap() => {
        columnId: id,
        columnSurveyQuestionAnswerChoiceId: surveyQuestionAnswerChoiceId,
        columnLabel: label,
      };

  @override
  String toString() {
    return 'SurveyQuestionAnswerChoiceSelection{id: $id, surveyQuestionAnswerChoice: $surveyQuestionAnswerChoiceId, label: $label}';
  }
}
