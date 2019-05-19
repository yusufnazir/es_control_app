import 'dart:convert';

class SurveySection {
  static final String tableSurveySections = "SurveySections";
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

  SurveySection(
      {this.id,
      this.name,
      this.description,
      this.surveyId,
      this.active,
      this.enableApplicability});

  SurveySection clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveySection.fromJsonMap(jsonData);
  }

  String clientToJson(SurveySection data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory SurveySection.fromJsonMap(Map<String, dynamic> json) {
    if (json != null) {
      return SurveySection(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        surveyId: json["surveyId"],
        active: json["active"] == true,
        enableApplicability: json["enableApplicability"] == true,
      );
    }
    return null;
  }

  factory SurveySection.fromDbMap(Map<String, dynamic> json) {
    if (json != null) {
      return SurveySection(
        id: json[columnId],
        name: json[columnName],
        description: json[columnDescription],
        surveyId: json[columnSurveyId],
        active: json[columnActive] == 1,
        enableApplicability: json[columnEnableApplicability] == 1,
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
        columnEnableApplicability: enableApplicability,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveySection &&
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
    return 'SurveySection{id: $id, name: $name, description: $description, surveyId: $surveyId, active: $active, enableApplicability: $enableApplicability}';
  }
}
