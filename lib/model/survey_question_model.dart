import 'dart:convert';

class SurveyQuestion {
  static final String tableSurveyQuestions = "SurveyQuestions";
  static final String columnId = "id";
  static final String columnActive = "active";
  static final String columnSurveyId = "survey_id";
  static final String columnQuestion = "question";
  static final String columnQuestionDescription = "question_description";
  static final String columnOrder = "order_";
  static final String columnQuestionType = "question_type";
  static final String columnRequired = "required";
  static final String columnRequiredError = "required_error";
  static final String columnMultipleSelection = "multiple_selection";
  static final String columnSectionId = "section_id";
  static final String columnGroupId = "group_id";

  int id;
  bool active;
  int surveyId;
  String question;
  String questionDescription;
  int order;
  String questionType;
  bool required;
  String requiredError;
  bool multipleSelection;
  int sectionId;
  int groupId;

  SurveyQuestion(
      {this.id,
      this.active,
      this.surveyId,
      this.question,
      this.questionDescription,
      this.order,
      this.questionType,
      this.required,
      this.requiredError,
      this.multipleSelection,
      this.sectionId,
      this.groupId});

  SurveyQuestion clientFromJson(String str) {
    final jsonData = json.decode(str);
    return SurveyQuestion.fromJsonMap(jsonData);
  }

  String clientToJson(SurveyQuestion data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory SurveyQuestion.fromJsonMap(Map<String, dynamic> json) {
    if(json!=null) {
      return SurveyQuestion(
        id: json["id"],
        active: json["active"] == true,
        surveyId: json["surveyId"],
        question: json["question"],
        questionDescription: json["questionDescription"],
        order: json["order"],
        questionType: json["questionType"],
        required: json["required"] == true,
        requiredError: json["requiredError"],
        multipleSelection: json["multipleSelection"] == true,
        sectionId: json["sectionId"],
        groupId: json["groupId"],
      );
    }
    return null;
  }

  factory SurveyQuestion.fromDbMap(Map<String, dynamic> json) {
    if(json!=null) {
      return SurveyQuestion(
        id: json[columnId],
        active: json[columnActive] == 1,
        surveyId: json[columnSurveyId],
        question: json[columnQuestion],
        questionDescription: json[columnQuestionDescription],
        order: json[columnOrder],
        questionType: json[columnQuestionType],
        required: json[columnRequired] == 1,
        requiredError: json[columnRequiredError],
        multipleSelection: json[columnMultipleSelection] == 1,
        sectionId: json[columnSectionId],
        groupId: json[columnGroupId],
      );
    }
    return null;
  }

  Map<String, dynamic> toDbMap() => {
        columnId: id,
        columnActive: active,
        columnSurveyId: surveyId,
        columnQuestion: question,
        columnQuestionDescription: questionDescription,
        columnOrder: order,
        columnQuestionType: questionType,
        columnRequired: required,
        columnRequiredError: requiredError,
        columnMultipleSelection: multipleSelection,
        columnSectionId: sectionId,
        columnGroupId: groupId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyQuestion &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          active == other.active &&
          surveyId == other.surveyId &&
          question == other.question &&
          questionDescription == other.questionDescription &&
          order == other.order &&
          questionType == other.questionType &&
          required == other.required &&
          requiredError == other.requiredError &&
          multipleSelection == other.multipleSelection &&
          sectionId == other.sectionId &&
          groupId == other.groupId;

  @override
  int get hashCode =>
      id.hashCode ^
      active.hashCode ^
      surveyId.hashCode ^
      question.hashCode ^
      questionDescription.hashCode ^
      order.hashCode ^
      questionType.hashCode ^
      required.hashCode ^
      requiredError.hashCode ^
      multipleSelection.hashCode ^
      sectionId.hashCode ^
      groupId.hashCode;

  @override
  String toString() {
    return 'SurveyQuestion{id: $id, active: $active, surveyId: $surveyId, question: $question, questionDescription: $questionDescription, order: $order, questionType: $questionType, required: $required, requiredError: $requiredError, multipleSelection: $multipleSelection, sectionId: $sectionId, groupId: $groupId}';
  }
}
