import 'dart:convert';

import 'package:es_control_app/constants.dart';
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
  static final String columnUsername = "username";
  static final String columnUploaded = "uploaded";

  int id;
  String uniqueId;
  int surveyId;
  String formName;
  String username;
  DateTime createdOn;
  bool active;
  bool uploaded;

  SurveyResponse({
    this.id,
    this.uniqueId,
    this.surveyId,
    this.formName,
    this.createdOn,
    this.active,
    this.username,
    this.uploaded,
  });

  static SurveyResponse clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyResponse.fromJsonMap(jsonData);
  }

  static String clientToJson(SurveyResponse data) {
    final dyn = data.toMap();
    return json.encode(dyn);
  }

  factory SurveyResponse.fromJsonMap(Map<String, dynamic> json) {
    if(json!=null) {
      return SurveyResponse(
        id: json["id"],
        uniqueId: json["uniqueId"],
        surveyId: Utilities.getSurveyIdFromJson(json["survey"]),
        formName: json["formName"],
        createdOn: Utilities.getDateTimeFromJson(json["createdOn"]),
        active: json["active"] == true,
        uploaded: json["uploaded"] == true,
        username: json["username"],
      );
    }
    return null;
  }

  factory SurveyResponse.fromDbMap(Map<String, dynamic> json) {
    if(json!=null) {
      return SurveyResponse(
        id: json[columnId],
        uniqueId: json[columnUniqueId],
        surveyId: json[columnSurveyId],
        formName: json[columnFormName],
        createdOn: DateTime.fromMicrosecondsSinceEpoch(json[columnCreatedOn]),
        active: json[columnActive] == 1,
        uploaded: json[columnUploaded] == 1,
        username: json[columnUsername],
      );
    }
    return null;
  }

  Map<String, dynamic> toDbMap() => {
        columnId: id,
        columnUniqueId: uniqueId,
        columnSurveyId: surveyId,
        columnFormName: formName,
        columnCreatedOn: createdOn.microsecondsSinceEpoch,
        columnActive: active,
        columnUploaded: active,
        columnUsername: username,
      };

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["uniqueId"] = uniqueId;
    map["surveyId"] = surveyId;
    map["formName"] = formName;
    map["createdOn"] = DateFormat(Constants.dateFormatPrecise).format(createdOn);
    map["active"] = active;
    map["username"] = username;
    map["uploaded"] = uploaded;
    return map;
  }

  @override
  String toString() {
    return 'SurveyResponse{id: $id, uniqueId: $uniqueId, surveyId: $surveyId, formName: $formName, username: $username, createdOn: $createdOn, active: $active, uploaded: $uploaded}';
  }

}
