import 'dart:convert';

import 'package:es_control_app/util/utilities.dart';

class SurveyGroup {
  static final String tableSurveyGroups = "SurveyGroups";
  static final String columnId = "id";
  static final String columnName = "name";
  static final String columnDescription = "description";
  static final String columnSurveyId = "survey_id";
  static final String columnActive = "active";

  int id;
  String name;
  String description;
  int surveyId;
  bool active;

  SurveyGroup({
    this.id,
    this.name,
    this.description,
    this.surveyId,
    this.active,
  });

  SurveyGroup clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyGroup.fromJsonMap(jsonData);
  }

  String clientToJson(SurveyGroup data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory SurveyGroup.fromJsonMap(Map<String, dynamic> json) {
    if(json!=null) {
      return SurveyGroup(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        surveyId: Utilities.getSurveyIdFromJson(json["survey"]),
        active: json["active"] == true,
      );
    }
    return null;
  }

  factory SurveyGroup.fromDbMap(Map<String, dynamic> json) {
    if(json!=null) {
      return SurveyGroup(
        id: json[columnId],
        name: json[columnName],
        description: json[columnDescription],
        surveyId: json[columnSurveyId],
        active: json[columnActive] == 1,
      );
    }
    return null;
  }

  Map<String, dynamic> toDbMap() => {
        columnId: id,
        columnName: name,
        columnDescription: description,
        columnSurveyId: surveyId,
        columnActive: active,
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
          active == other.active;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      surveyId.hashCode ^
      active.hashCode;

  @override
  String toString() {
    return 'SurveyGroup{id: $id, name: $name, description: $description, surveyId: $surveyId, active: $active}';
  }
}
