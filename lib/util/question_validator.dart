import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/util/question_types.dart';
import 'package:flutter/material.dart';

class QuestionValidator {
  List<int> questionsToSkip = List<int>();
  Map<int, int> _requiredQuestionsSectionMap = Map<int, int>();
  List<int> notApplicableSections = List<int>();
  List<int> madeRequiredList = List<int>();
  List<int> madeRequiredGroupList = List<int>();
  final String surveyResponseUniqueId;
  SurveyQuestion _surveyQuestion;
  final int surveyId;

  QuestionValidator(this.surveyId, this.surveyResponseUniqueId);

  validateQuestions() async {
    notApplicableSections = await DBProvider.db
        .getAllApplicableSectionsForSurveyResponse(surveyResponseUniqueId);
    List<SurveyQuestion> allSurveyQuestions =
        await DBProvider.db.getAllSurveyQuestions(surveyId);
    for (SurveyQuestion surveyQuestion in allSurveyQuestions) {
      bool exit = await validateSurveyQuestion(surveyQuestion);
      if(exit){
        break;
      }
    }
  }

  Future<bool> validateSurveyQuestion(SurveyQuestion surveyQuestion) async {
    //skip not applicable grouped questions
    if (surveyQuestion.sectionId != null &&
        notApplicableSections.contains(surveyQuestion.sectionId)) {
      return false;
    }

    if (!questionsToSkip.contains(surveyQuestion.id)) {
      bool required = surveyQuestion.required;
      if (!required) {
        if (madeRequiredList.contains(surveyQuestion.id)) {
          required = true;
        }
      }

      if (surveyQuestion.groupId != null &&
          madeRequiredGroupList.contains(surveyQuestion.groupId)) {
        required = true;
      }
//      debugPrint("surveyQuestion ${surveyQuestion.id} groupid ${surveyQuestion.groupId}");
      if (required) {
        String questionType = surveyQuestion.questionType;
        switch (questionType) {
          case question_type_single:
          case question_type_area_ft_inch:
            return await validateSingle(surveyQuestion);
          case question_type_choices:
            return await validateChoices(surveyQuestion);
          case question_type_matrix:
            return await validateMatrix(surveyQuestion);
        }
      }
    }
    return false;
  }

  Future<bool> validateSingle(SurveyQuestion surveyQuestion) async {
    SurveyResponseAnswer surveyResponseAnswer = await DBProvider.db
        .getSurveyResponseAnswerForSingleTextByResponseAndQuestion(
            surveyResponseUniqueId, surveyQuestion.id);
    if (surveyResponseAnswer == null ||
        surveyResponseAnswer.responseText == null ||
        surveyResponseAnswer.responseText.trim().isEmpty) {
      this._surveyQuestion = surveyQuestion;
      this._requiredQuestionsSectionMap[surveyQuestion.id] =
          surveyQuestion.sectionId;
      return true;
    }
    return false;
  }

  Future<bool> validateChoices(SurveyQuestion surveyQuestion) async {
    bool multipleSelection = surveyQuestion.multipleSelection;
    if (!multipleSelection) {
      List<SurveyResponseAnswer> surveyResponseAnswers = await DBProvider.db
          .getSurveyResponseAnswerForChoicesByResponseAndQuestion(
              surveyResponseUniqueId, surveyQuestion.id);
      if (surveyResponseAnswers == null || surveyResponseAnswers.length == 0) {
        this._surveyQuestion = surveyQuestion;
        this._requiredQuestionsSectionMap[surveyQuestion.id] =
            surveyQuestion.sectionId;
        return true;
      } else {
        SurveyResponseAnswer surveyResponseAnswer = surveyResponseAnswers[0];
        int choiceId = surveyResponseAnswer.surveyQuestionAnswerChoiceRowId;
        SurveyQuestionAnswerChoice surveyQuestionAnswerChoice =
            await DBProvider.db.getSurveyQuestionAnswerChoice(choiceId);
        // for other
        bool isOther = surveyQuestionAnswerChoice.isOther;
        if (!surveyResponseAnswer.selected ||
            (isOther &&
                (surveyResponseAnswer.otherValue == null ||
                    surveyResponseAnswer.otherValue.trim().isEmpty))) {
          this._surveyQuestion = surveyQuestion;
          this._requiredQuestionsSectionMap[surveyQuestion.id] =
              surveyQuestion.sectionId;
          return true;
        }

        int questionId =
            surveyQuestionAnswerChoice.makeSelectedQuestionRequired;
        if (questionId != null) {
          madeRequiredList.add(questionId);
        }

        int makeSelectedGroupRequired =
            surveyQuestionAnswerChoice.makeSelectedGroupRequired;
        if (makeSelectedGroupRequired != null) {
          madeRequiredGroupList.add(makeSelectedGroupRequired);
        }
      }
    }
    return false;
  }

  SurveyQuestion get surveyQuestion => _surveyQuestion;

  set surveyQuestion(SurveyQuestion value) {
    _surveyQuestion = value;
  }

  Map<int, int> get requiredQuestionsSectionMap => _requiredQuestionsSectionMap;

  set requiredQuestionsSectionMap(Map<int, int> value) {
    _requiredQuestionsSectionMap = value;
  }

  Future<bool> validateMatrix(SurveyQuestion surveyQuestion) async {
    return false;
  }
}
