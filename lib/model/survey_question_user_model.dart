import 'dart:convert';

class SurveyQuestionUser {
  static final String tableSurveyQuestionUsers = "SurveyQuestionUsers";
  static final String columnId = "id";
  static final String columnSurveyId = "survey_id";
  static final String columnQuestionId = "survey_question_id";
  static final String columnUsername = "username";
  static final String columnActive = "active";

  int id;
  int questionId;
  String username;
  int surveyId;
  bool active;

  SurveyQuestionUser({
    this.id,
    this.questionId,
    this.username,
    this.surveyId,
    this.active,
  });

  SurveyQuestionUser clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyQuestionUser.fromJsonMap(jsonData);
  }

  String clientToJson(SurveyQuestionUser data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory SurveyQuestionUser.fromJsonMap(Map<String, dynamic> json) {
    if (json != null) {
      return SurveyQuestionUser(
        id: json["id"],
        questionId: json["questionId"],
        username: json["username"],
        surveyId: json["surveyId"],
        active: json["active"] == true,
      );
    }
    return null;
  }

  factory SurveyQuestionUser.fromDbMap(Map<String, dynamic> json) {
    if (json != null) {
      return SurveyQuestionUser(
        id: json[columnId],
        username: json[columnUsername],
        questionId: json[columnQuestionId],
        surveyId: json[columnSurveyId],
        active: json[columnActive] == 1,
      );
    }
    return null;
  }

  Map<String, dynamic> toDbMap() => {
        columnId: id,
        columnUsername: username,
        columnQuestionId: questionId,
        columnSurveyId: surveyId,
        columnActive: active,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyQuestionUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          questionId == other.questionId &&
          username == other.username &&
          surveyId == other.surveyId &&
          active == other.active;

  @override
  int get hashCode =>
      id.hashCode ^
      questionId.hashCode ^
      username.hashCode ^
      surveyId.hashCode ^
      active.hashCode;

  @override
  String toString() {
    return 'SurveyQuestionUser{id: $id, questionId: $questionId, username: $username, surveyId: $surveyId, active: $active}';
  }
}
