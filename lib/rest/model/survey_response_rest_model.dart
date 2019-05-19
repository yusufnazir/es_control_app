import 'dart:convert';

import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/model/survey_response_section_model.dart';

SurveyResponseRestModel clientFromJson(String str) {
  final jsonData = json.decode(str);
  return SurveyResponseRestModel.fromMap(jsonData);
}

String clientToJson(SurveyResponseRestModel data) {
  return json.encode(data);
}

class SurveyResponseRestModel {
  SurveyResponse surveyResponse;
  List<SurveyResponseAnswer> surveyResponseAnswers;
  List<SurveyResponseSection> surveyResponseSections;

  SurveyResponseRestModel({
    this.surveyResponse,
    this.surveyResponseAnswers,
    this.surveyResponseSections,
  });

  factory SurveyResponseRestModel.fromMap(Map<String, dynamic> json) =>
      new SurveyResponseRestModel(
        surveyResponse: SurveyResponse.fromJsonMap(json["surveyResponse"]),
        surveyResponseAnswers: json["surveyResponseAnswers"]
            .map<SurveyResponseAnswer>(
                (value) => SurveyResponseAnswer.fromJsonMap(value))
            .toList(),
        surveyResponseSections: json["surveyResponseSections"]
            ?.map<SurveyResponseSection>(
                (value) => SurveyResponseSection.fromJsonMap(value))
            ?.toList(),
      );

  Map<String, dynamic> toJson() => {
        "surveyResponse": surveyResponse,
        "surveyResponseAnswers": surveyResponseAnswers,
        "surveyResponseSections": surveyResponseSections,
      };

  static String clientToJson(SurveyResponseRestModel data) {
    return json.encode(data);
  }

}
