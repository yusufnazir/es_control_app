import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/util/question_types.dart';
import 'package:flutter/material.dart';

class QuestionValidator {
  List<int> questionsToSkip = List<int>();
  Map<int, int> requiredQuestionsGroupMap = Map<int, int>();
  final String surveyResponseUniqueId;
  final int surveyId;

  QuestionValidator(this.surveyId, this.surveyResponseUniqueId);

  validateQuestions() async {
    List<SurveyQuestion> allSurveyQuestions =
        await DBProvider.db.getAllSurveyQuestions(surveyId);
    for (SurveyQuestion surveyQuestion in allSurveyQuestions) {
      await validateSurveyQuestion(surveyQuestion);
    }
    return requiredQuestionsGroupMap;
  }

  void validateSurveyQuestion(SurveyQuestion surveyQuestion) async {
    if (!questionsToSkip.contains(surveyQuestion.id)) {
      bool required = surveyQuestion.required;
      if (required) {
        String questionType = surveyQuestion.questionType;
        switch (questionType) {
          case question_type_single:
            await validateSingle(surveyQuestion);
            break;
          case question_type_choices:
            await validateChoices(surveyQuestion);
            break;
          case question_type_matrix:
            await validateMatrix(surveyQuestion);
            break;
        }
      }
    }
  }

  void validateSingle(SurveyQuestion surveyQuestion) async {
    SurveyResponseAnswer surveyResponseAnswer = await DBProvider.db
        .getSurveyResponseAnswerForSingleTextByResponseAndQuestion(
            surveyResponseUniqueId, surveyQuestion.id);
    if (surveyResponseAnswer == null ||
        surveyResponseAnswer.responseText == null ||
        surveyResponseAnswer.responseText.trim().isEmpty) {
      requiredQuestionsGroupMap[surveyQuestion.id] = surveyQuestion.groupId;
      return;
    }
  }

  void validateChoices(SurveyQuestion surveyQuestion) async {
    debugPrint("surveyQuestion $surveyQuestion");
    bool multipleSelection = surveyQuestion.multipleSelection;
    if (!multipleSelection) {
      List<SurveyResponseAnswer> surveyResponseAnswers = await DBProvider.db
          .getSurveyResponseAnswerForChoicesByResponseAndQuestion(
              surveyResponseUniqueId, surveyQuestion.id);
      debugPrint("surveyResponseAnswers ${surveyResponseAnswers.length}");
      if (surveyResponseAnswers == null || surveyResponseAnswers.length == 0) {
        requiredQuestionsGroupMap[surveyQuestion.id] = surveyQuestion.groupId;
        return;
      } else {
        SurveyResponseAnswer surveyResponseAnswer = surveyResponseAnswers[0];
        int choiceId = surveyResponseAnswer.surveyQuestionAnswerChoiceRowId;
        SurveyQuestionAnswerChoice surveyQuestionAnswerChoice =
            await DBProvider.db.getSurveyQuestionAnswerChoice(choiceId);
        bool isOther = surveyQuestionAnswerChoice.isOther;
        if (!surveyResponseAnswer.selected ||
            (isOther &&
                (surveyResponseAnswer.otherValue == null ||
                    surveyResponseAnswer.otherValue.trim().isEmpty))) {
          requiredQuestionsGroupMap[surveyQuestion.id] = surveyQuestion.groupId;
          return;
        }
      }
    }
  }

  validateMatrix(SurveyQuestion surveyQuestion) {}
}
