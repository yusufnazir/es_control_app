import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/util/question_types.dart';
import 'package:flutter/material.dart';

class QuestionValidator {
  List<int> questionsToSkip = List<int>();
  Map<int, int> _requiredQuestionsSectionMap = Map<int, int>();
  List<int> madeRequiredList = List<int>();
  final String surveyResponseUniqueId;
  SurveyQuestion _surveyQuestion;
  final int surveyId;

  QuestionValidator(this.surveyId, this.surveyResponseUniqueId);

  validateQuestions() async {
    List<SurveyQuestion> allSurveyQuestions =
        await DBProvider.db.getAllSurveyQuestions(surveyId);
    for (SurveyQuestion surveyQuestion in allSurveyQuestions) {
      await validateSurveyQuestion(surveyQuestion);
    }
  }

  void validateSurveyQuestion(SurveyQuestion surveyQuestion) async {
    if (!questionsToSkip.contains(surveyQuestion.id)) {
      bool required = surveyQuestion.required;
      if (!required) {
        if (madeRequiredList.contains(surveyQuestion.id)) {
          required = true;
        }
      }
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
      this._surveyQuestion = surveyQuestion;
      this._requiredQuestionsSectionMap[surveyQuestion.id] =
          surveyQuestion.sectionId;
      return;
    }
  }

  void validateChoices(SurveyQuestion surveyQuestion) async {
//    debugPrint("surveyQuestion $surveyQuestion");
    bool multipleSelection = surveyQuestion.multipleSelection;
    if (!multipleSelection) {
//      List<SurveyQuestionAnswerChoice> surveyQuestionAnswerChoices = await DBProvider.db.getSurveyQuestionAnswerChoiceByQuestion(surveyQuestion.id);
      List<SurveyResponseAnswer> surveyResponseAnswers = await DBProvider.db
          .getSurveyResponseAnswerForChoicesByResponseAndQuestion(
              surveyResponseUniqueId, surveyQuestion.id);
      if (surveyResponseAnswers == null || surveyResponseAnswers.length == 0) {
        this._surveyQuestion = surveyQuestion;
        this._requiredQuestionsSectionMap[surveyQuestion.id] =
            surveyQuestion.sectionId;
        return;
      } else {
        SurveyResponseAnswer surveyResponseAnswer = surveyResponseAnswers[0];
        int choiceId = surveyResponseAnswer.surveyQuestionAnswerChoiceRowId;
        SurveyQuestionAnswerChoice surveyQuestionAnswerChoice =
            await DBProvider.db.getSurveyQuestionAnswerChoice(choiceId);
        debugPrint("SurveyQuestionAnswerChoice $surveyQuestionAnswerChoice");
        // for other
        bool isOther = surveyQuestionAnswerChoice.isOther;
        if (!surveyResponseAnswer.selected ||
            (isOther &&
                (surveyResponseAnswer.otherValue == null ||
                    surveyResponseAnswer.otherValue.trim().isEmpty))) {
          this._surveyQuestion = surveyQuestion;
          this._requiredQuestionsSectionMap[surveyQuestion.id] =
              surveyQuestion.sectionId;
          return;
        }

        int questionId =
            surveyQuestionAnswerChoice.makeSelectedQuestionRequired;
        if (questionId != null) {
          madeRequiredList.add(questionId);
        }
      }
    }
  }

  SurveyQuestion get surveyQuestion => _surveyQuestion;

  set surveyQuestion(SurveyQuestion value) {
    _surveyQuestion = value;
  }

  Map<int, int> get requiredQuestionsSectionMap => _requiredQuestionsSectionMap;

  set requiredQuestionsSectionMap(Map<int, int> value) {
    _requiredQuestionsSectionMap = value;
  }

  validateMatrix(SurveyQuestion surveyQuestion) {}
}
