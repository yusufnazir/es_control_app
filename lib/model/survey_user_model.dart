import 'dart:convert';

class SurveyUser {
  static final String tableSurveyUsers = "SurveyUsers";
  static final String columnId = "id";
  static final String columnActive = "active";
  static final String columnUsername = "username";
  static final String columnSurveyId = "survey_id";

  String id;
  String username;
  int surveyId;
  bool active;

  SurveyUser({
    this.id,
    this.username,
    this.surveyId,
    this.active,
  });

  SurveyUser clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyUser.fromJsonMap(jsonData);
  }

  String clientToJson(SurveyUser data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory SurveyUser.fromJsonMap(Map<String, dynamic> json) {
    if (json != null) {
      return SurveyUser(
        id: json["id"],
        username: json["username"],
        surveyId: json["surveyId"],
        active: json["active"] == true,
      );
    }
    return null;
  }

  factory SurveyUser.fromDbMap(Map<String, dynamic> json) {
    if (json != null) {
      return SurveyUser(
        id: json[columnId],
        username: json[columnUsername],
        surveyId: json[columnSurveyId],
        active: json[columnActive] == 1,
      );
    }
    return null;
  }

  Map<String, dynamic> toDbMap() => {
        columnId: id,
        columnUsername: username,
        columnSurveyId: surveyId,
        columnActive: active,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          surveyId == other.surveyId &&
          active == other.active;

  @override
  int get hashCode =>
      id.hashCode ^ username.hashCode ^ surveyId.hashCode ^ active.hashCode;

  @override
  String toString() {
    return 'SurveyUser{id: $id, username: $username, surveyId: $surveyId, active: $active}';
  }
}
