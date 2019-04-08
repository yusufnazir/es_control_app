import 'dart:convert';

import 'package:es_control_app/util/utilities.dart';

import 'survey_model.dart';

SurveyGroup clientFromJson(String str) {
  final jsonData = json.decode(str);
  return SurveyGroup.fromJsonMap(jsonData);
}

String clientToJson(SurveyGroup data) {
  final dyn = data.toDbMap();
  return json.encode(dyn);
}

class SurveyGroup {
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

  factory SurveyGroup.fromJsonMap(Map<String, dynamic> json) => new SurveyGroup(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        surveyId: getSurveyIdFromJson(json["survey"]),
        active: json["active"] == true,
      );

  factory SurveyGroup.fromDbMap(Map<String, dynamic> json) => new SurveyGroup(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        surveyId: json["survey_id"],
        active: json["active"] == 1,
      );

  Map<String, dynamic> toDbMap() => {
        "id": id,
        "name": name,
        "description": description,
        "survey_id": surveyId,
        "active": active,
      };

  @override
  String toString() {
    return 'SurveyGroup{id: $id, name: $name, description: $description, survey: $surveyId, active: $active}';
  }
}
