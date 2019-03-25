import 'dart:convert';

import 'survey_model.dart';

SurveyGroup clientFromJson(String str) {
  final jsonData = json.decode(str);
  return SurveyGroup.fromMap(jsonData);
}

String clientToJson(SurveyGroup data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class SurveyGroup {
  int id;
  String name;
  String description;
  Survey survey;
  bool active;

  SurveyGroup({
    this.id,
    this.name,
    this.description,
    this.survey,
    this.active,
  });

  factory SurveyGroup.fromMap(Map<String, dynamic> json) => new SurveyGroup(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        survey:Survey.fromMap(json["survey"]),
        active: json["active"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "description": description,
        "survey_id": survey.id,
        "active": active,
      };

  @override
  String toString() {
    return 'SurveyGroup{id: $id, name: $name, description: $description, survey: $survey, active: $active}';
  }
}
