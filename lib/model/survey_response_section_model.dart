import 'dart:convert';

class SurveyResponseSection {
  static final String tableSurveyResponseSections = "SurveyResponseSections";

  static final String columnId = "id";
  static final String columnUniqueId = "unique_id";
  static final String columnActive = "active";
  static final String columnSurveyResponseUniqueId =
      "survey_response_unique_id";
  static final String columnSurveySectionId = "survey_section_id";
  static final String columnNotApplicable = "notApplicable";

  int id;
  String uniqueId;
  bool active;
  String surveyResponseUniqueId;
  int surveySectionId;
  bool notApplicable;

  SurveyResponseSection({
    this.id,
    this.uniqueId,
    this.active,
    this.surveyResponseUniqueId,
    this.surveySectionId,
    this.notApplicable,
  });

  SurveyResponseSection clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyResponseSection.fromJsonMap(jsonData);
  }

  String clientToJson(SurveyResponseSection data) {
    return json.encode(data);
  }

  factory SurveyResponseSection.fromJsonMap(Map<String, dynamic> json) {
    if (json != null) {
      return SurveyResponseSection(
          id: json["id"],
          uniqueId: json["uniqueId"],
          active: json["active"] == true,
          surveyResponseUniqueId: json["surveyResponseUniqueId"],
          surveySectionId: json["surveySectionId"],
          notApplicable: json["notApplicable"] == true);
    }
    return null;
  }

  factory SurveyResponseSection.fromDbMap(Map<String, dynamic> json) {
    if (json != null) {
      return SurveyResponseSection(
        id: json[columnId],
        uniqueId: json[columnUniqueId],
        surveyResponseUniqueId: json[columnSurveyResponseUniqueId],
        surveySectionId: json[columnSurveySectionId],
        active: json[columnActive] == 1,
        notApplicable: json[columnNotApplicable] == 1,
      );
    }
    return null;
  }

  Map<String, dynamic> toDbMap() => {
        columnId: id,
        columnUniqueId: uniqueId,
        columnSurveyResponseUniqueId: surveyResponseUniqueId,
        columnSurveySectionId: surveySectionId,
        columnActive: active,
        columnNotApplicable: notApplicable
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'uniqueId': uniqueId,
        'active': active,
        'surveyResponseUniqueId': surveyResponseUniqueId,
        'surveySectionId': surveySectionId,
        'notApplicable': notApplicable,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyResponseSection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          uniqueId == other.uniqueId &&
          active == other.active &&
          surveyResponseUniqueId == other.surveyResponseUniqueId &&
          surveySectionId == other.surveySectionId &&
          notApplicable == other.notApplicable;

  @override
  int get hashCode =>
      id.hashCode ^
      uniqueId.hashCode ^
      active.hashCode ^
      surveyResponseUniqueId.hashCode ^
      surveySectionId.hashCode ^
      notApplicable.hashCode;

  @override
  String toString() {
    return 'SurveyResponseSection{id: $id, uniqueId: $uniqueId, active: $active, surveyResponseUniqueId: $surveyResponseUniqueId, surveySectionId: $surveySectionId, notApplicable: $notApplicable}';
  }
}
