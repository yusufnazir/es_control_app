import 'dart:convert';

import 'package:es_control_app/util/utilities.dart';

class SurveyGroup {
  static final String tableSurveyGroups = "SurveyGroups";
  static final String columnId = "id";
  static final String columnName = "name";
  static final String columnDescription = "description";
  static final String columnSurveyId = "survey_id";
  static final String columnActive = "active";
  static final String columnEnableApplicability = "enable_applicability";

  int id;
  String name;
  String description;
  int surveyId;
  bool active;
  bool enableApplicability;

  SurveyGroup(
      {this.id,
      this.name,
      this.description,
      this.surveyId,
      this.active,
      this.enableApplicability});

  SurveyGroup clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyGroup.fromJsonMap(jsonData);
  }

  String clientToJson(SurveyGroup data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory SurveyGroup.fromJsonMap(Map<String, dynamic> json) => new SurveyGroup(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        surveyId: Utilities.getSurveyIdFromJson(json["survey"]),
        active: json["active"] == true,
        enableApplicability: json["enableApplicability"] == true,
      );

  factory SurveyGroup.fromDbMap(Map<String, dynamic> json) => new SurveyGroup(
        id: json[columnId],
        name: json[columnName],
        description: json[columnDescription],
        surveyId: json[columnSurveyId],
        active: json[columnActive] == 1,
        enableApplicability: json[columnEnableApplicability] == 1,
      );

  Map<String, dynamic> toDbMap() => {
        columnId: id,
        columnName: name,
        columnDescription: description,
        columnSurveyId: surveyId,
        columnActive: active,
        columnEnableApplicability: enableApplicability,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyGroup &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          surveyId == other.surveyId &&
          active == other.active &&
          enableApplicability == other.enableApplicability;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      surveyId.hashCode ^
      active.hashCode ^
      enableApplicability.hashCode;

  @override
  String toString() {
    return 'SurveyGroup{id: $id, name: $name, description: $description, surveyId: $surveyId, active: $active, enableApplicability: $enableApplicability}';
  }
}
