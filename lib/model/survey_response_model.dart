import 'dart:convert';

import 'package:es_control_app/util/utilities.dart';
import 'package:intl/intl.dart';

class SurveyResponse {

  static final String tableSurveyResponses = "SurveyResponses";
  static final String columnUniqueId = "unique_id";
  static final String columnId = "id";
  static final String columnActive = "active";
  static final String columnSurveyId = "survey_id";
  static final String columnFormName = "form_name";
  static final String columnCreatedOn = "created_on";

  int id;
  String uniqueId;
  int surveyId;
  String formName;
  DateTime createdOn;
  bool active;

  SurveyResponse({
    this.id,
    this.uniqueId,
    this.surveyId,
    this.formName,
    this.createdOn,
    this.active,
  });

  SurveyResponse clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyResponse.fromJsonMap(jsonData);
  }

  String clientToJson(SurveyResponse data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory SurveyResponse.fromJsonMap(Map<String, dynamic> json) =>
      new SurveyResponse(
        id: json["id"],
        uniqueId: json["uniqueId"],
        surveyId: Utilities.getSurveyIdFromJson(json["survey"]),
        formName: json["formName"],
        createdOn: Utilities.getDateTimeFromJson(json["createdOn"]),
        active: json["active"] == true,
      );

  factory SurveyResponse.fromDbMap(Map<String, dynamic> json) =>
      new SurveyResponse(
        id: json["id"],
        uniqueId: json["unique_id"],
        surveyId: json["survey_id"],
        formName: json["form_name"],
        createdOn: Utilities.getDateTimeFromJson(json["created_on"]),
        active: json["active"] == 1,
      );

  Map<String, dynamic> toDbMap() => {
        "id": id,
        "unique_id": uniqueId,
        "survey_id": surveyId,
        "form_name": formName,
        "created_on": DateFormat('yyyy-MM-dd – kk:mm').format(createdOn),
        "active": active,
      };

  @override
  String toString() {
    return 'SurveyResponse{id: $id, uniqueId: $uniqueId, surveyId: $surveyId, formName: $formName, createdOn: $createdOn, active: $active}';
  }
}