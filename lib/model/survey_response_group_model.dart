import 'dart:convert';

import 'package:es_control_app/util/utilities.dart';

class SurveyResponseGroup {
  static final String tableSurveyResponseGroups = "SurveyResponseGroups";

  static final String columnId = "id";
  static final String columnUniqueId = "unique_id";
  static final String columnActive = "active";
  static final String columnSurveyResponseUniqueId =
      "survey_response_unique_id";
  static final String columnSurveyGroupId = "survey_group_id";
  static final String columnApplicable = "applicable";

  int id;
  String uniqueId;
  bool active;
  String surveyResponseUniqueId;
  int surveyGroupId;
  bool applicable;

  SurveyResponseGroup({
    this.id,
    this.uniqueId,
    this.active,
    this.surveyResponseUniqueId,
    this.surveyGroupId,
    this.applicable,
  });

  SurveyResponseGroup clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyResponseGroup.fromJsonMap(jsonData);
  }

  String clientToJson(SurveyResponseGroup data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory SurveyResponseGroup.fromJsonMap(Map<String, dynamic> json) =>
      new SurveyResponseGroup(
          id: json["id"],
          uniqueId: json["uniqueId"],
          active: json["active"] == true,
          surveyResponseUniqueId: Utilities.getSurveyResponseUniqueIdFromJson(
              json["surveyResponseUniqueId"]),
          surveyGroupId: Utilities.getGroupIdFromJson(json["surveyGroupId"]),
          applicable: json["applicable"] == true);

  factory SurveyResponseGroup.fromDbMap(Map<String, dynamic> json) =>
      new SurveyResponseGroup(
        id: json[columnId],
        uniqueId: json[columnUniqueId],
        surveyResponseUniqueId: json[columnSurveyResponseUniqueId],
        surveyGroupId: json[columnSurveyGroupId],
        active: json[columnActive] == 1,
        applicable: json[columnApplicable] == 1,
      );

  Map<String, dynamic> toDbMap() => {
        columnId: id,
        columnUniqueId: uniqueId,
        columnSurveyResponseUniqueId: surveyResponseUniqueId,
        columnSurveyGroupId: surveyGroupId,
        columnActive: active,
        columnApplicable: applicable
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyResponseGroup &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          uniqueId == other.uniqueId &&
          active == other.active &&
          surveyResponseUniqueId == other.surveyResponseUniqueId &&
          surveyGroupId == other.surveyGroupId &&
          applicable == other.applicable;

  @override
  int get hashCode =>
      id.hashCode ^
      uniqueId.hashCode ^
      active.hashCode ^
      surveyResponseUniqueId.hashCode ^
      surveyGroupId.hashCode ^
      applicable.hashCode;

  @override
  String toString() {
    return 'SurveyResponseGroup{id: $id, uniqueId: $uniqueId, active: $active, surveyResponseUniqueId: $surveyResponseUniqueId, surveyGroupId: $surveyGroupId, applicable: $applicable}';
  }
}
