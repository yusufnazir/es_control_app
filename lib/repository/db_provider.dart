import 'dart:async';
import 'dart:io';

import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_selection_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/model/survey_response_section_model.dart';
import 'package:es_control_app/model/survey_section_model.dart';
import 'package:es_control_app/util/matrix_column_types.dart';
import 'package:es_control_app/util/question_types.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "EsControl.db");
    return await openDatabase(path, version: 2, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE ${Survey.tableSurveys} ("
          "${Survey.columnId} INTEGER PRIMARY KEY,"
          "${Survey.columnName} TEXT,"
          "${Survey.columnDescription} TEXT,"
          "${Survey.columnActive} BIT"
          ")");
      await db.execute("CREATE TABLE ${SurveySection.tableSurveySections} ("
          "${SurveySection.columnId} INTEGER PRIMARY KEY,"
          "${SurveySection.columnActive} BIT,"
          "${SurveySection.columnName} TEXT,"
          "${SurveySection.columnDescription} TEXT,"
          "${SurveySection.columnSurveyId} INTEGER,"
          "${SurveySection.columnEnableApplicability} BIT"
          ")");
      await db.execute("CREATE TABLE ${SurveyGroup.tableSurveyGroups} ("
          "${SurveyGroup.columnId} INTEGER PRIMARY KEY,"
          "${SurveyGroup.columnActive} BIT,"
          "${SurveyGroup.columnName} TEXT,"
          "${SurveyGroup.columnDescription} TEXT,"
          "${SurveyGroup.columnSurveyId} INTEGER"
          ")");
      await db.execute("CREATE TABLE ${SurveyQuestion.tableSurveyQuestions} ("
          "${SurveyQuestion.columnId} INTEGER PRIMARY KEY,"
          "${SurveyQuestion.columnActive} BIT,"
          "${SurveyQuestion.columnSurveyId} INTEGER,"
          "${SurveyQuestion.columnQuestion} TEXT,"
          "${SurveyQuestion.columnQuestionDescription} TEXT,"
          "${SurveyQuestion.columnOrder} INTEGER,"
          "${SurveyQuestion.columnQuestionType} TEXT,"
          "${SurveyQuestion.columnRequired} BIT,"
          "${SurveyQuestion.columnRequiredError} TEXT,"
          "${SurveyQuestion.columnMultipleSelection} BIT,"
          "${SurveyQuestion.columnSectionId} INTEGER,"
          "${SurveyQuestion.columnGroupId} INTEGER"
          ")");
      await db.execute(
          "CREATE TABLE ${SurveyQuestionAnswerChoice.tableSurveyQuestionAnswerChoices} ("
          "${SurveyQuestionAnswerChoice.columnId} INTEGER PRIMARY KEY,"
          "${SurveyQuestionAnswerChoice.columnSurveyQuestionId} INTEGER,"
          "${SurveyQuestionAnswerChoice.columnLabel} TEXT,"
          "${SurveyQuestionAnswerChoice.columnQuestionType} TEXT,"
          "${SurveyQuestionAnswerChoice.columnAxis} TEXT,"
          "${SurveyQuestionAnswerChoice.columnMatrixColumnType} TEXT,"
          "${SurveyQuestionAnswerChoice.columnIndex} INTEGER,"
          "${SurveyQuestionAnswerChoice.columnMinLength} INTEGER,"
          "${SurveyQuestionAnswerChoice.columnMaxLength} INTEGER,"
          "${SurveyQuestionAnswerChoice.columnMinValue} REAL,"
          "${SurveyQuestionAnswerChoice.columnMaxValue} REAL,"
          "${SurveyQuestionAnswerChoice.columnMinDate} TEXT,"
          "${SurveyQuestionAnswerChoice.columnMaxDate} TEXT,"
          "${SurveyQuestionAnswerChoice.columnValidate} BIT,"
          "${SurveyQuestionAnswerChoice.columnValidationError} TEXT,"
          "${SurveyQuestionAnswerChoice.columnMultipleSelection} BIT,"
          "${SurveyQuestionAnswerChoice.columnIsOther} BIT,"
          "${SurveyQuestionAnswerChoice.columnMakeSelectedQuestionRequired} INTEGER,"
          "${SurveyQuestionAnswerChoice.columnMakeSelectedGroupRequired} INTEGER"
          ")");
      await db.execute(
          "CREATE TABLE ${SurveyQuestionAnswerChoiceSelection.tableSurveyQuestionAnswerChoiceSelections} ("
          "${SurveyQuestionAnswerChoiceSelection.columnId} INTEGER PRIMARY KEY,"
          "${SurveyQuestionAnswerChoiceSelection.columnSurveyQuestionAnswerChoiceId} INTEGER,"
          "${SurveyQuestionAnswerChoiceSelection.columnLabel} TEXT"
          ")");
      await db.execute("CREATE TABLE ${SurveyResponse.tableSurveyResponses} ("
          "${SurveyResponse.columnUniqueId} TEXT PRIMARY KEY,"
          "${SurveyResponse.columnId} INTEGER,"
          "${SurveyResponse.columnActive} BIT,"
          "${SurveyResponse.columnSurveyId} INTEGER,"
          "${SurveyResponse.columnFormName} TEXT,"
          "${SurveyResponse.columnCreatedOn} INTEGER,"
          "${SurveyResponse.columnUploaded} BIT,"
          "${SurveyResponse.columnUsername} TEXT"
          ")");
      await db.execute(
          "CREATE TABLE ${SurveyResponseSection.tableSurveyResponseSections} ("
          "${SurveyResponseSection.columnUniqueId} TEXT PRIMARY KEY,"
          "${SurveyResponseSection.columnId} INTEGER,"
          "${SurveyResponseSection.columnActive} BIT,"
          "${SurveyResponseSection.columnSurveyResponseUniqueId} TEXT,"
          "${SurveyResponseSection.columnSurveySectionId} INTEGER,"
          "${SurveyResponseSection.columnApplicable} BIT"
          ")");
      await db.execute(
          "CREATE TABLE ${SurveyResponseAnswer.tableSurveyResponseAnswers} ("
          "${SurveyResponseAnswer.columnUniqueId} TEXT PRIMARY KEY,"
          "${SurveyResponseAnswer.columnId} INTEGER,"
          "${SurveyResponseAnswer.columnActive} BIT,"
          "${SurveyResponseAnswer.columnSurveyResponseUniqueId} TEXT,"
          "${SurveyResponseAnswer.columnSurveyQuestionId} INTEGER,"
          "${SurveyResponseAnswer.columnSurveyQuestionChoiceRowId} INTEGER,"
          "${SurveyResponseAnswer.columnSurveyQuestionChoiceColumnId} INTEGER,"
          "${SurveyResponseAnswer.columnSurveyQuestionChoiceSelectionId} INTEGER,"
          "${SurveyResponseAnswer.columnQuestionType} TEXT,"
          "${SurveyResponseAnswer.columnResponseText} TEXT,"
          "${SurveyResponseAnswer.columnSelected} BIT"
          ")");
    });
  }

  deleteAll() async {
    final db = await database;
    await db.rawDelete("Delete from ${Survey.tableSurveys}");
    await db.rawDelete("Delete from ${SurveySection.tableSurveySections}");
    await db.rawDelete("Delete from ${SurveyGroup.tableSurveyGroups}");
    await db.rawDelete("Delete from ${SurveyQuestion.tableSurveyQuestions}");
    await db.rawDelete(
        "Delete from ${SurveyQuestionAnswerChoice.tableSurveyQuestionAnswerChoices}");
    await db.rawDelete(
        "Delete from ${SurveyQuestionAnswerChoiceSelection.tableSurveyQuestionAnswerChoiceSelections}");
  }

  Future<SurveyResponse> getSurveyResponse(int id) async {
    final db = await database;
    var res = await db.query(SurveyResponse.tableSurveyResponses,
        where: "${SurveyResponse.columnId} = ?", whereArgs: [id]);
    return res.isNotEmpty ? SurveyResponse.fromDbMap(res.first) : null;
  }

  Future<SurveyResponse> getSurveyResponseByUniqueId(String uniqueId) async {
    final db = await database;
    var res = await db.query(SurveyResponse.tableSurveyResponses,
        where: "${SurveyResponse.columnUniqueId} = ?", whereArgs: [uniqueId]);
    return res.isNotEmpty ? SurveyResponse.fromDbMap(res.first) : null;
  }

  createSurveyResponse(SurveyResponse surveyResponse) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into ${SurveyResponse.tableSurveyResponses} "
        "(${SurveyResponse.columnId},"
        "${SurveyResponse.columnUniqueId}, "
        "${SurveyResponse.columnSurveyId},"
        "${SurveyResponse.columnFormName},"
        "${SurveyResponse.columnCreatedOn},"
        "${SurveyResponse.columnActive},"
        "${SurveyResponse.columnUploaded},"
        "${SurveyResponse.columnUsername}"
        ")"
        " VALUES (?,?,?,?,?,?,?,?)",
        [
          surveyResponse.id,
          surveyResponse.uniqueId,
          surveyResponse.surveyId,
          surveyResponse.formName,
          surveyResponse.createdOn.microsecondsSinceEpoch,
          surveyResponse.active,
          surveyResponse.uploaded,
          surveyResponse.username
        ]);
    return raw;
  }

  updateSurveyResponse(SurveyResponse surveyResponse) async {
    final db = await database;
    var res = await db.update(
        SurveyResponse.tableSurveyResponses, surveyResponse.toDbMap(),
        where: "${SurveyResponse.columnId} = ?",
        whereArgs: [surveyResponse.id]);
    return res;
  }

  Future<SurveyResponse> updateSurveyResponseUploaded(
      String uniqueId, bool uploaded) async {
    final db = await database;
    var res = await db.update(SurveyResponse.tableSurveyResponses,
        {SurveyResponse.columnUploaded: uploaded},
        where: "${SurveyResponse.columnUniqueId} = ? ", whereArgs: [uniqueId]);

    return await getSurveyResponseByUniqueId(uniqueId);
  }

  deleteSurveyResponse(int id) async {
    final db = await database;
    var delete = db.delete(SurveyResponse.tableSurveyResponses,
        where: "${SurveyResponse.columnId} = ?", whereArgs: [id]);
    return delete;
  }

  Future<List<SurveyResponse>> getAllSurveyResponses(int surveyId) async {
    final db = await database;
    var res = await db.query(SurveyResponse.tableSurveyResponses,
        where: "${SurveyResponse.columnSurveyId}=?",
        whereArgs: [surveyId],
        orderBy: SurveyResponse.columnCreatedOn + " desc");
    List<SurveyResponse> list = res.isNotEmpty
        ? res.map((c) => SurveyResponse.fromDbMap(c)).toList()
        : [];
    return list;
  }

  Future<SurveyResponseAnswer> getSurveyResponseAnswer(int id) async {
    final db = await database;
    var res = await db.query(SurveyResponseAnswer.tableSurveyResponseAnswers,
        where: "${SurveyResponseAnswer.columnId} = ?", whereArgs: [id]);
    return res.isNotEmpty ? SurveyResponseAnswer.fromDbMap(res.first) : null;
  }

  createSurveyResponseAnswer(SurveyResponseAnswer surveyResponseAnswer) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into ${SurveyResponseAnswer.tableSurveyResponseAnswers} "
        "(${SurveyResponseAnswer.columnId},"
        "${SurveyResponseAnswer.columnUniqueId}, "
        "${SurveyResponseAnswer.columnActive}, "
        "${SurveyResponseAnswer.columnSurveyResponseUniqueId},"
        "${SurveyResponseAnswer.columnSurveyQuestionId}, "
        "${SurveyResponseAnswer.columnSurveyQuestionChoiceRowId}, "
        "${SurveyResponseAnswer.columnSurveyQuestionChoiceColumnId}, "
        "${SurveyResponseAnswer.columnSurveyQuestionChoiceSelectionId}, "
        "${SurveyResponseAnswer.columnQuestionType},"
        "${SurveyResponseAnswer.columnResponseText},"
        "${SurveyResponseAnswer.columnSelected})"
        " VALUES (?,?,?,?,?,?,?,?,?,?,?)",
        [
          surveyResponseAnswer.id,
          surveyResponseAnswer.uniqueId,
          surveyResponseAnswer.active,
          surveyResponseAnswer.surveyResponseUniqueId,
          surveyResponseAnswer.surveyQuestionId,
          surveyResponseAnswer.surveyQuestionAnswerChoiceRowId,
          surveyResponseAnswer.surveyQuestionAnswerChoiceColumnId,
          surveyResponseAnswer.surveyQuestionAnswerChoiceSelectionId,
          surveyResponseAnswer.questionType,
          surveyResponseAnswer.responseText,
          surveyResponseAnswer.selected
        ]);
    return raw;
  }

  updateSurveyResponseAnswer(SurveyResponseAnswer surveyResponseAnswer) async {
    final db = await database;
    var res = await db.update(SurveyResponseAnswer.tableSurveyResponseAnswers,
        surveyResponseAnswer.toDbMap(),
        where: "${SurveyResponseAnswer.columnId} = ?",
        whereArgs: [surveyResponseAnswer.id]);
    return res;
  }

  deleteSurveyResponseAnswer(int id) async {
    final db = await database;
    var delete = db.delete(SurveyResponseAnswer.tableSurveyResponseAnswers,
        where: "${SurveyResponseAnswer.columnId} = ?", whereArgs: [id]);
    return delete;
  }

  Future<List<SurveyResponseAnswer>> getAllSurveyResponseAnswers(
      String surveyResponseUniqueId) async {
    final db = await database;
    var res = await db.query(SurveyResponseAnswer.tableSurveyResponseAnswers,
        where: "${SurveyResponseAnswer.columnSurveyResponseUniqueId}=?",
        whereArgs: [surveyResponseUniqueId]);
    List<SurveyResponseAnswer> list = res.isNotEmpty
        ? res.map((c) => SurveyResponseAnswer.fromDbMap(c)).toList()
        : [];
    return list;
  }

  Future<Survey> getSurvey(int id) async {
    final db = await database;
    var res = await db.query(Survey.tableSurveys,
        where: "${Survey.columnId} = ?", whereArgs: [id]);
    return res.isNotEmpty ? Survey.fromDbMap(res.first) : null;
  }

  Future<Survey> createSurvey(Survey survey) async {
    final db = await database;
    //get the biggest id in the table
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into ${Survey.tableSurveys} ("
        "${Survey.columnId},"
        "${Survey.columnName},"
        "${Survey.columnDescription},"
        "${Survey.columnActive})"
        " VALUES (?,?,?,?)",
        [survey.id, survey.name, survey.description, survey.active]);
    return survey;
  }

  updateSurvey(Survey survey) async {
    final db = await database;
    var res = await db.update(Survey.tableSurveys, survey.toDbMap(),
        where: "${Survey.columnId} = ?", whereArgs: [survey.id]);
    return res;
  }

  deleteSurvey(int id) async {
    final db = await database;
    var delete = db.delete(Survey.tableSurveys,
        where: "${Survey.columnId} = ?", whereArgs: [id]);
    return delete;
  }

  Future<List<Survey>> getAllSurveys() async {
    final db = await database;
    var res = await db.query(Survey.tableSurveys);
    List<Survey> list =
        res.isNotEmpty ? res.map((c) => Survey.fromDbMap(c)).toList() : [];
    return list;
  }

  blockOrUnblock(Survey survey) async {
    final db = await database;
    Survey blocked = Survey(
        id: survey.id,
        name: survey.name,
        description: survey.description,
        active: !survey.active);
    var res = await db.update(Survey.tableSurveys, blocked.toDbMap(),
        where: "${Survey.columnId} = ?", whereArgs: [survey.id]);
    return res;
  }

  Future<SurveyQuestion> getSurveyQuestion(int id) async {
    final db = await database;
    var res = await db.query(SurveyQuestion.tableSurveyQuestions,
        where: "${SurveyQuestion.columnId} = ?", whereArgs: [id]);
    return res.isNotEmpty ? SurveyQuestion.fromDbMap(res.first) : null;
  }

  createSurveyQuestion(SurveyQuestion surveyQuestion) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into ${SurveyQuestion.tableSurveyQuestions} ("
        "${SurveyQuestion.columnId},"
        "${SurveyQuestion.columnActive},"
        "${SurveyQuestion.columnSurveyId},"
        "${SurveyQuestion.columnQuestion},"
        "${SurveyQuestion.columnQuestionDescription},"
        "${SurveyQuestion.columnOrder},"
        "${SurveyQuestion.columnQuestionType},"
        "${SurveyQuestion.columnRequired},"
        "${SurveyQuestion.columnRequiredError},"
        "${SurveyQuestion.columnMultipleSelection},"
        "${SurveyQuestion.columnSectionId},"
        "${SurveyQuestion.columnGroupId})"
        " VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
        [
          surveyQuestion.id,
          surveyQuestion.active,
          surveyQuestion.surveyId,
          surveyQuestion.question,
          surveyQuestion.questionDescription,
          surveyQuestion.order,
          surveyQuestion.questionType,
          surveyQuestion.required,
          surveyQuestion.requiredError,
          surveyQuestion.multipleSelection,
          surveyQuestion.sectionId,
          surveyQuestion.groupId
        ]);
    return raw;
  }

  updateSurveyQuestion(SurveyQuestion surveyQuestion) async {
    final db = await database;
    var res = await db.update(
        SurveyQuestion.tableSurveyQuestions, surveyQuestion.toDbMap(),
        where: "${SurveyQuestion.columnId} = ?",
        whereArgs: [surveyQuestion.id]);
    return res;
  }

  deleteSurveyQuestion(int id) async {
    final db = await database;
    var delete = db.delete(SurveyQuestion.tableSurveyQuestions,
        where: "${SurveyQuestion.columnId} = ?", whereArgs: [id]);
    return delete;
  }

  Future<List<SurveyQuestion>> getAllSurveyQuestions(int surveyId) async {
    final db = await database;
    var res = await db.query(SurveyQuestion.tableSurveyQuestions,
        where: "${SurveyQuestion.columnSurveyId}=?",
        whereArgs: [surveyId],
        orderBy: SurveyQuestion.columnOrder);
    List<SurveyQuestion> list = res.isNotEmpty
        ? res.map((c) => SurveyQuestion.fromDbMap(c)).toList()
        : [];
    return list;
  }

  Future<List<SurveyQuestion>> getAllSurveyQuestionsForSurvey(
      int surveyId) async {
    final db = await database;
    var res = await db.query(SurveyQuestion.tableSurveyQuestions,
        where: "${SurveyQuestion.columnSurveyId}= ?",
        whereArgs: [surveyId],
        orderBy: SurveyQuestion.columnOrder);
    List<SurveyQuestion> list = res.isNotEmpty
        ? res.map((c) => SurveyQuestion.fromDbMap(c)).toList()
        : [];
    return list;
  }

  Future<bool> isSurveyQuestionDependant(int surveyQuestionId) async {
    final db = await database;
    var res = await db.query(
      SurveyQuestionAnswerChoice.tableSurveyQuestionAnswerChoices,
      where:
          "${SurveyQuestionAnswerChoice.columnMakeSelectedQuestionRequired}= ?",
      whereArgs: [surveyQuestionId],
    );
    List<SurveyQuestionAnswerChoice> list = res.isNotEmpty
        ? res.map((c) => SurveyQuestionAnswerChoice.fromDbMap(c)).toList()
        : [];
    return (list != null && list.length > 0);
  }

  Future<SurveyQuestionAnswerChoiceSelection>
      getSurveyQuestionAnswerChoiceSelection(int id) async {
    final db = await database;
    var res = await db.query(
        SurveyQuestionAnswerChoiceSelection
            .tableSurveyQuestionAnswerChoiceSelections,
        where: "${SurveyQuestionAnswerChoiceSelection.columnId} = ?",
        whereArgs: [id]);
    return res.isNotEmpty
        ? SurveyQuestionAnswerChoiceSelection.fromDbMap(res.first)
        : null;
  }

  createSurveyQuestionAnswerChoiceSelection(
      SurveyQuestionAnswerChoiceSelection
          surveyQuestionAnswerChoiceSelection) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into ${SurveyQuestionAnswerChoiceSelection.tableSurveyQuestionAnswerChoiceSelections} ("
        "${SurveyQuestionAnswerChoiceSelection.columnId},"
        "${SurveyQuestionAnswerChoiceSelection.columnSurveyQuestionAnswerChoiceId},"
        "${SurveyQuestionAnswerChoiceSelection.columnLabel})"
        " VALUES (?,?,?)",
        [
          surveyQuestionAnswerChoiceSelection.id,
          surveyQuestionAnswerChoiceSelection.surveyQuestionAnswerChoiceId,
          surveyQuestionAnswerChoiceSelection.label
        ]);
    return raw;
  }

  updateSurveyQuestionAnswerChoiceSelection(
      SurveyQuestionAnswerChoiceSelection
          surveyQuestionAnswerChoiceSelection) async {
    final db = await database;
    var res = await db.update(
        SurveyQuestionAnswerChoiceSelection
            .tableSurveyQuestionAnswerChoiceSelections,
        surveyQuestionAnswerChoiceSelection.toDbMap(),
        where: "${SurveyQuestionAnswerChoiceSelection.columnId} = ?",
        whereArgs: [surveyQuestionAnswerChoiceSelection.id]);
    return res;
  }

  deleteSurveyQuestionAnswerChoiceSelection(int id) async {
    final db = await database;
    var delete = db.delete(
        SurveyQuestionAnswerChoiceSelection
            .tableSurveyQuestionAnswerChoiceSelections,
        where: "${SurveyQuestionAnswerChoiceSelection.columnId} = ?",
        whereArgs: [id]);
    return delete;
  }

  Future<List<SurveyQuestionAnswerChoiceSelection>>
      getAllSurveyQuestionAnswerChoiceSelections() async {
    final db = await database;
    var res = await db.query(SurveyQuestionAnswerChoiceSelection
        .tableSurveyQuestionAnswerChoiceSelections);
    List<SurveyQuestionAnswerChoiceSelection> list = res.isNotEmpty
        ? res
            .map((c) => SurveyQuestionAnswerChoiceSelection.fromDbMap(c))
            .toList()
        : [];
    return list;
  }

  Future<SurveyQuestionAnswerChoice> getSurveyQuestionAnswerChoice(
      int id) async {
    final db = await database;
    var res = await db.query(
        SurveyQuestionAnswerChoice.tableSurveyQuestionAnswerChoices,
        where: "${SurveyQuestionAnswerChoice.columnId} = ?",
        whereArgs: [id]);
    return res.isNotEmpty
        ? SurveyQuestionAnswerChoice.fromDbMap(res.first)
        : null;
  }

  createSurveyQuestionAnswerChoice(
      SurveyQuestionAnswerChoice surveyQuestionAnswerChoice) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into ${SurveyQuestionAnswerChoice.tableSurveyQuestionAnswerChoices} ("
        "${SurveyQuestionAnswerChoice.columnId},"
        "${SurveyQuestionAnswerChoice.columnSurveyQuestionId},"
        "${SurveyQuestionAnswerChoice.columnLabel},"
        "${SurveyQuestionAnswerChoice.columnQuestionType},"
        "${SurveyQuestionAnswerChoice.columnAxis},"
        "${SurveyQuestionAnswerChoice.columnMatrixColumnType},"
        "${SurveyQuestionAnswerChoice.columnIndex},"
        "${SurveyQuestionAnswerChoice.columnMinLength},"
        "${SurveyQuestionAnswerChoice.columnMaxLength},"
        "${SurveyQuestionAnswerChoice.columnMinValue},"
        "${SurveyQuestionAnswerChoice.columnMaxValue},"
        "${SurveyQuestionAnswerChoice.columnMinDate},"
        "${SurveyQuestionAnswerChoice.columnMaxDate},"
        "${SurveyQuestionAnswerChoice.columnValidate},"
        "${SurveyQuestionAnswerChoice.columnValidationError},"
        "${SurveyQuestionAnswerChoice.columnMultipleSelection},"
        "${SurveyQuestionAnswerChoice.columnIsOther},"
        "${SurveyQuestionAnswerChoice.columnMakeSelectedQuestionRequired},"
        "${SurveyQuestionAnswerChoice.columnMakeSelectedGroupRequired})"
        " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        [
          surveyQuestionAnswerChoice.id,
          surveyQuestionAnswerChoice.surveyQuestionId,
          surveyQuestionAnswerChoice.label,
          surveyQuestionAnswerChoice.questionType,
          surveyQuestionAnswerChoice.axis,
          surveyQuestionAnswerChoice.matrixColumnType,
          surveyQuestionAnswerChoice.index,
          surveyQuestionAnswerChoice.minLength,
          surveyQuestionAnswerChoice.maxLength,
          surveyQuestionAnswerChoice.minValue,
          surveyQuestionAnswerChoice.maxValue,
          surveyQuestionAnswerChoice.minDate,
          surveyQuestionAnswerChoice.maxDate,
          surveyQuestionAnswerChoice.validate,
          surveyQuestionAnswerChoice.validationError,
          surveyQuestionAnswerChoice.multipleSelection,
          surveyQuestionAnswerChoice.isOther,
          surveyQuestionAnswerChoice.makeSelectedQuestionRequired,
          surveyQuestionAnswerChoice.makeSelectedGroupRequired
        ]);
    return raw;
  }

  updateSurveyQuestionAnswerChoice(
      SurveyQuestionAnswerChoice surveyQuestionAnswerChoice) async {
    final db = await database;
    var res = await db.update(
        SurveyQuestionAnswerChoice.tableSurveyQuestionAnswerChoices,
        surveyQuestionAnswerChoice.toDbMap(),
        where: "${SurveyQuestionAnswerChoice.columnId} = ?",
        whereArgs: [surveyQuestionAnswerChoice.id]);
    return res;
  }

  deleteSurveyQuestionAnswerChoice(int id) async {
    final db = await database;
    var delete = db.delete(
        SurveyQuestionAnswerChoice.tableSurveyQuestionAnswerChoices,
        where: "${SurveyQuestionAnswerChoice.columnId} = ?",
        whereArgs: [id]);
    return delete;
  }

  Future<List<SurveyQuestionAnswerChoice>>
      getAllSurveyQuestionAnswerChoices() async {
    final db = await database;
    var res = await db
        .query(SurveyQuestionAnswerChoice.tableSurveyQuestionAnswerChoices);
    List<SurveyQuestionAnswerChoice> list = res.isNotEmpty
        ? res.map((c) => SurveyQuestionAnswerChoice.fromDbMap(c)).toList()
        : [];
    return list;
  }

  Future<List<SurveyQuestionAnswerChoice>>
      getSurveyQuestionAnswerChoiceByQuestion(int surveyQuestionId) async {
    final db = await database;
    var res = await db.query(
        SurveyQuestionAnswerChoice.tableSurveyQuestionAnswerChoices,
        where: "${SurveyQuestionAnswerChoice.columnSurveyQuestionId}=?",
        whereArgs: [surveyQuestionId],
        orderBy: SurveyQuestionAnswerChoice.columnIndex);
    List<SurveyQuestionAnswerChoice> list = res.isNotEmpty
        ? res.map((c) => SurveyQuestionAnswerChoice.fromDbMap(c)).toList()
        : [];
    return list;
  }

  Future<SurveySection> getSurveySection(int id) async {
    final db = await database;
    var res = await db.query(SurveySection.tableSurveySections,
        where: "${SurveySection.columnId} = ?", whereArgs: [id]);
    return res.isNotEmpty ? SurveySection.fromDbMap(res.first) : null;
  }

  createSurveySection(SurveySection surveySection) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into ${SurveySection.tableSurveySections} ("
        "${SurveySection.columnId},"
        "${SurveySection.columnSurveyId},"
        "${SurveySection.columnName},"
        "${SurveySection.columnDescription},"
        "${SurveySection.columnActive},"
        "${SurveySection.columnEnableApplicability}"
        ")"
        " VALUES (?,?,?,?,?,?)",
        [
          surveySection.id,
          surveySection.surveyId,
          surveySection.name,
          surveySection.description,
          surveySection.active,
          surveySection.enableApplicability
        ]);
    return raw;
  }

  updateSurveySection(SurveySection surveySection) async {
    final db = await database;
    var res = await db.update(
        SurveySection.tableSurveySections, surveySection.toDbMap(),
        where: "${SurveySection.columnId} = ?", whereArgs: [surveySection.id]);
    return res;
  }

  deleteSurveySection(int id) async {
    final db = await database;
    var delete = db.delete(SurveySection.tableSurveySections,
        where: "${SurveySection.columnId} = ?", whereArgs: [id]);
    return delete;
  }

  Future<List<SurveySection>> getAllSurveySections() async {
    final db = await database;
    var res = await db.query(SurveySection.tableSurveySections);
    List<SurveySection> list = res.isNotEmpty
        ? res.map((c) => SurveySection.fromDbMap(c)).toList()
        : [];
    return list;
  }

  Future<SurveyGroup> getSurveyGroup(int id) async {
    final db = await database;
    var res = await db.query(SurveyGroup.tableSurveyGroups,
        where: "${SurveyGroup.columnId} = ?", whereArgs: [id]);
    return res.isNotEmpty ? SurveyGroup.fromDbMap(res.first) : null;
  }

  createSurveyGroup(SurveyGroup surveyGroup) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into ${SurveyGroup.tableSurveyGroups} ("
        "${SurveyGroup.columnId},"
        "${SurveyGroup.columnSurveyId},"
        "${SurveyGroup.columnName},"
        "${SurveyGroup.columnDescription},"
        "${SurveyGroup.columnActive}"
        ")"
        " VALUES (?,?,?,?,?)",
        [
          surveyGroup.id,
          surveyGroup.surveyId,
          surveyGroup.name,
          surveyGroup.description,
          surveyGroup.active
        ]);
    return raw;
  }

  updateSurveyGroup(SurveyGroup surveyGroup) async {
    final db = await database;
    var res = await db.update(
        SurveyGroup.tableSurveyGroups, surveyGroup.toDbMap(),
        where: "${SurveyGroup.columnId} = ?", whereArgs: [surveyGroup.id]);
    return res;
  }

  deleteSurveyGroup(int id) async {
    final db = await database;
    var delete = db.delete(SurveyGroup.tableSurveyGroups,
        where: "${SurveyGroup.columnId} = ?", whereArgs: [id]);
    return delete;
  }

  Future<List<SurveyGroup>> getAllSurveyGroups() async {
    final db = await database;
    var res = await db.query(SurveyGroup.tableSurveyGroups);
    List<SurveyGroup> list =
        res.isNotEmpty ? res.map((c) => SurveyGroup.fromDbMap(c)).toList() : [];
    return list;
  }

  createSurveyResponseSection(
      SurveyResponseSection surveyResponseSection) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into ${SurveyResponseSection.tableSurveyResponseSections} "
        "(${SurveyResponseSection.columnSurveySectionId},"
        "${SurveyResponseSection.columnSurveyResponseUniqueId}, "
        "${SurveyResponseSection.columnActive}, "
        "${SurveyResponseSection.columnApplicable},"
        "${SurveyResponseSection.columnUniqueId})"
        " VALUES (?,?,?,?,?)",
        [
          surveyResponseSection.surveySectionId,
          surveyResponseSection.surveyResponseUniqueId,
          surveyResponseSection.active,
          surveyResponseSection.applicable,
          surveyResponseSection.uniqueId,
        ]);
    return raw;
  }

  Future<SurveyResponseSection> getSurveyResponseSectionByResponseAndSection(
      String surveyResponseUniqueId, int surveySectionId) async {
    final db = await database;
    var res = await db.query(SurveyResponseSection.tableSurveyResponseSections,
        where: "${SurveyResponseSection.columnSurveyResponseUniqueId} = ? "
            "and ${SurveyResponseSection.columnSurveySectionId} = ? ",
        whereArgs: [surveyResponseUniqueId, surveySectionId]);
    return res.isNotEmpty ? SurveyResponseSection.fromDbMap(res.first) : null;
  }

  Future<List<SurveyQuestionAnswerChoiceSelection>>
      getSurveyQuestionAnswerChoiceSelections(
          int surveyQuestionAnswerChoiceColumnId) async {
    final db = await database;
    var res = await db.query(
        SurveyQuestionAnswerChoiceSelection
            .tableSurveyQuestionAnswerChoiceSelections,
        where:
            "${SurveyQuestionAnswerChoiceSelection.columnSurveyQuestionAnswerChoiceId} = ? ",
        whereArgs: [surveyQuestionAnswerChoiceColumnId]);
    List<SurveyQuestionAnswerChoiceSelection> list = res.isNotEmpty
        ? res
            .map((c) => SurveyQuestionAnswerChoiceSelection.fromDbMap(c))
            .toList()
        : [];
    return list;
  }

  getSurveyResponseAnswerForSingleTextByResponseAndQuestion(
      String surveyResponseUniqueId, int surveyQuestionId) async {
    final db = await database;
    var res = await db.query(SurveyResponseAnswer.tableSurveyResponseAnswers,
        where:
            "${SurveyResponseAnswer.columnSurveyResponseUniqueId}=? and ${SurveyResponseAnswer.columnSurveyQuestionId}=?",
        whereArgs: [surveyResponseUniqueId, surveyQuestionId]);
    return res.isNotEmpty ? SurveyResponseAnswer.fromDbMap(res.first) : null;
  }

  getSurveyResponseAnswerForChoiceByResponseAndQuestion(
      String surveyResponseUniqueId,
      int surveyQuestionId,
      int surveyQuestionAnswerChoiceId) async {
    final db = await database;
    var res = await db.query(SurveyResponseAnswer.tableSurveyResponseAnswers,
        where: "${SurveyResponseAnswer.columnSurveyResponseUniqueId}=? "
            "and ${SurveyResponseAnswer.columnSurveyQuestionId}=? "
            "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceRowId}=?",
        whereArgs: [
          surveyResponseUniqueId,
          surveyQuestionId,
          surveyQuestionAnswerChoiceId
        ]);
    return res.isNotEmpty ? SurveyResponseAnswer.fromDbMap(res.first) : null;
  }

  Future<List<SurveyResponseAnswer>>
      getSurveyResponseAnswerForChoicesByResponseAndQuestion(
          String surveyResponseUniqueId, int surveyQuestionId) async {
    final db = await database;
    var res = await db.query(SurveyResponseAnswer.tableSurveyResponseAnswers,
        where: "${SurveyResponseAnswer.columnSurveyResponseUniqueId}=? "
            "and ${SurveyResponseAnswer.columnSurveyQuestionId}=? ",
        whereArgs: [
          surveyResponseUniqueId,
          surveyQuestionId,
        ]);
    return res.isNotEmpty
        ? res.map((c) => SurveyResponseAnswer.fromDbMap(c)).toList()
        : [];
  }

  Future<SurveyResponseAnswer>
      getSurveyResponseAnswerChoiceForMatrixCellTextByResponseAndQuestion(
          String surveyResponseUniqueId,
          int surveyQuestionId,
          int surveyQuestionAnswerChoiceRowId,
          int surveyQuestionAnswerChoiceColumnId) async {
    final db = await database;
    var res = await db.query(SurveyResponseAnswer.tableSurveyResponseAnswers,
        where: "${SurveyResponseAnswer.columnSurveyResponseUniqueId}=? "
            "and ${SurveyResponseAnswer.columnSurveyQuestionId}=? "
            "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceRowId}=? "
            "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceColumnId}=? ",
        whereArgs: [
          surveyResponseUniqueId,
          surveyQuestionId,
          surveyQuestionAnswerChoiceRowId,
          surveyQuestionAnswerChoiceColumnId
        ]);
    return res.isNotEmpty ? SurveyResponseAnswer.fromDbMap(res.first) : null;
  }

  Future<SurveyResponseAnswer>
      getSurveyResponseAnswerChoiceForMatrixCellChoiceByResponseAndQuestion(
          String surveyResponseUniqueId,
          int surveyQuestionId,
          int surveyQuestionAnswerChoiceRowId,
          int surveyQuestionAnswerChoiceColumnId,
          int surveyQuestionAnswerChoiceSelectionId) async {
    final db = await database;
    var res = await db.query(SurveyResponseAnswer.tableSurveyResponseAnswers,
        where: "${SurveyResponseAnswer.columnSurveyResponseUniqueId}=? "
            "and ${SurveyResponseAnswer.columnSurveyQuestionId}=? "
            "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceRowId}=? "
            "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceColumnId}=? "
            "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceSelectionId}=? ",
        whereArgs: [
          surveyResponseUniqueId,
          surveyQuestionId,
          surveyQuestionAnswerChoiceRowId,
          surveyQuestionAnswerChoiceColumnId,
          surveyQuestionAnswerChoiceSelectionId
        ]);
    return res.isNotEmpty ? SurveyResponseAnswer.fromDbMap(res.first) : null;
  }

  void updateSurveyResponseAnswerForSingleText(String surveyResponseUniqueId,
      int surveyQuestionId, String responseText) async {
    final db = await database;
    SurveyResponseAnswer surveyResponseAnswer =
        await getSurveyResponseAnswerForSingleTextByResponseAndQuestion(
            surveyResponseUniqueId, surveyQuestionId);
    if (surveyResponseAnswer == null) {
      Uuid uuid = Uuid();
      String uniqueId = uuid.v4();
      SurveyResponseAnswer surveyResponseAnswer = SurveyResponseAnswer(
          active: true,
          questionType: question_type_choices,
          surveyQuestionId: surveyQuestionId,
          surveyResponseUniqueId: surveyResponseUniqueId,
          uniqueId: uniqueId,
          responseText: responseText,
          surveyQuestionAnswerChoiceColumnId: null,
          surveyQuestionAnswerChoiceRowId: null,
          selected: null,
          surveyQuestionAnswerChoiceSelectionId: null);
      await createSurveyResponseAnswer(surveyResponseAnswer);
    } else {
      await db.update(SurveyResponseAnswer.tableSurveyResponseAnswers,
          {SurveyResponseAnswer.columnResponseText: responseText},
          where: "${SurveyResponseAnswer.columnSurveyResponseUniqueId} = ? "
              "and ${SurveyResponseAnswer.columnSurveyQuestionId} = ?",
          whereArgs: [surveyResponseUniqueId, surveyQuestionId]);
    }
  }

  void updateSurveyResponseAnswerForChoice(
      String surveyResponseUniqueId,
      int surveyQuestionId,
      int surveyQuestionChoiceId,
      bool selected,
      bool multipleSelection) async {
    final db = await database;
    if (!multipleSelection) {
      await db.delete(SurveyResponseAnswer.tableSurveyResponseAnswers,
          where: "${SurveyResponseAnswer.columnSurveyResponseUniqueId} = ? "
              "and ${SurveyResponseAnswer.columnSurveyQuestionId} = ? ",
          whereArgs: [surveyResponseUniqueId, surveyQuestionId]);
//      await db.update(SurveyResponseAnswer.tableSurveyResponseAnswers,
//          {SurveyResponseAnswer.columnSelected: false},
//          where: "${SurveyResponseAnswer.columnSurveyResponseUniqueId} = ? "
//              "and ${SurveyResponseAnswer.columnSurveyQuestionId} = ? ",
//          whereArgs: [surveyResponseUniqueId, surveyQuestionId]);
    }

    SurveyResponseAnswer surveyResponseAnswer =
        await getSurveyResponseAnswerForChoiceByResponseAndQuestion(
            surveyResponseUniqueId, surveyQuestionId, surveyQuestionChoiceId);
    if (surveyResponseAnswer == null) {
      Uuid uuid = Uuid();
      String uniqueId = uuid.v4();
      SurveyResponseAnswer surveyResponseAnswer = SurveyResponseAnswer(
          active: true,
          questionType: question_type_choices,
          surveyQuestionId: surveyQuestionId,
          surveyResponseUniqueId: surveyResponseUniqueId,
          uniqueId: uniqueId,
          responseText: null,
          surveyQuestionAnswerChoiceColumnId: null,
          surveyQuestionAnswerChoiceRowId: surveyQuestionChoiceId,
          selected: selected,
          surveyQuestionAnswerChoiceSelectionId: null);
      await createSurveyResponseAnswer(surveyResponseAnswer);
    } else {
      await db.update(SurveyResponseAnswer.tableSurveyResponseAnswers,
          {SurveyResponseAnswer.columnSelected: selected},
          where: "${SurveyResponseAnswer.columnSurveyResponseUniqueId} = ? "
              "and ${SurveyResponseAnswer.columnSurveyQuestionId} = ? "
              "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceRowId} = ?",
          whereArgs: [
            surveyResponseUniqueId,
            surveyQuestionId,
            surveyQuestionChoiceId
          ]);
    }
  }

  void updateSurveyResponseAnswerChoiceForMatrixCellText(
      String surveyResponseUniqueId,
      int surveyQuestionId,
      String responseText,
      int surveyQuestionAnswerChoiceRowId,
      int surveyQuestionAnswerChoiceColumnId) async {
    final db = await database;
    SurveyResponseAnswer surveyResponseAnswer =
        await getSurveyResponseAnswerChoiceForMatrixCellTextByResponseAndQuestion(
            surveyResponseUniqueId,
            surveyQuestionId,
            surveyQuestionAnswerChoiceRowId,
            surveyQuestionAnswerChoiceColumnId);
    if (surveyResponseAnswer == null) {
      Uuid uuid = Uuid();
      String uniqueId = uuid.v4();
      SurveyResponseAnswer surveyResponseAnswer = SurveyResponseAnswer(
          active: true,
          questionType: question_type_matrix,
          surveyQuestionId: surveyQuestionId,
          surveyResponseUniqueId: surveyResponseUniqueId,
          uniqueId: uniqueId,
          responseText: responseText,
          surveyQuestionAnswerChoiceColumnId:
              surveyQuestionAnswerChoiceColumnId,
          surveyQuestionAnswerChoiceRowId: surveyQuestionAnswerChoiceRowId,
          selected: null,
          surveyQuestionAnswerChoiceSelectionId: null);
      await createSurveyResponseAnswer(surveyResponseAnswer);
    } else {
      await db.update(SurveyResponseAnswer.tableSurveyResponseAnswers,
          {SurveyResponseAnswer.columnResponseText: responseText},
          where: "${SurveyResponseAnswer.columnSurveyResponseUniqueId} = ? "
              "and ${SurveyResponseAnswer.columnSurveyQuestionId} = ? "
              "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceRowId} = ? "
              "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceColumnId} = ? ",
          whereArgs: [
            surveyResponseUniqueId,
            surveyQuestionId,
            surveyQuestionAnswerChoiceRowId,
            surveyQuestionAnswerChoiceColumnId
          ]);
    }
  }

  void updateSurveyResponseAnswerChoiceForMatrixCellChoice(
      String surveyResponseUniqueId,
      int surveyQuestionId,
      bool selected,
      int surveyQuestionAnswerChoiceRowId,
      int surveyQuestionAnswerChoiceColumnId,
      int surveyQuestionAnswerChoiceSelectionId,
      String matrixColumnType) async {
    final db = await database;
    if (matrixColumnType == single_composite_selection) {
      await db.update(SurveyResponseAnswer.tableSurveyResponseAnswers,
          {SurveyResponseAnswer.columnSelected: false},
          where: "${SurveyResponseAnswer.columnSurveyResponseUniqueId} = ? "
              "and ${SurveyResponseAnswer.columnSurveyQuestionId} = ? "
              "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceRowId} = ?"
              "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceColumnId} = ?",
          whereArgs: [
            surveyResponseUniqueId,
            surveyQuestionId,
            surveyQuestionAnswerChoiceRowId,
            surveyQuestionAnswerChoiceColumnId
          ]);
    }
    SurveyResponseAnswer surveyResponseAnswer =
        await getSurveyResponseAnswerChoiceForMatrixCellChoiceByResponseAndQuestion(
            surveyResponseUniqueId,
            surveyQuestionId,
            surveyQuestionAnswerChoiceRowId,
            surveyQuestionAnswerChoiceColumnId,
            surveyQuestionAnswerChoiceSelectionId);
    if (surveyResponseAnswer == null) {
      Uuid uuid = Uuid();
      String uniqueId = uuid.v4();
      SurveyResponseAnswer surveyResponseAnswer = SurveyResponseAnswer(
          active: true,
          questionType: question_type_matrix,
          surveyQuestionId: surveyQuestionId,
          surveyResponseUniqueId: surveyResponseUniqueId,
          uniqueId: uniqueId,
          responseText: null,
          surveyQuestionAnswerChoiceColumnId:
              surveyQuestionAnswerChoiceColumnId,
          surveyQuestionAnswerChoiceRowId: surveyQuestionAnswerChoiceRowId,
          selected: selected,
          surveyQuestionAnswerChoiceSelectionId:
              surveyQuestionAnswerChoiceSelectionId);
      await createSurveyResponseAnswer(surveyResponseAnswer);
    } else {
      await db.update(SurveyResponseAnswer.tableSurveyResponseAnswers,
          {SurveyResponseAnswer.columnSelected: selected},
          where: "${SurveyResponseAnswer.columnSurveyResponseUniqueId} = ? "
              "and ${SurveyResponseAnswer.columnSurveyQuestionId} = ?"
              "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceRowId} = ?"
              "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceColumnId} = ?"
              "and ${SurveyResponseAnswer.columnSurveyQuestionChoiceSelectionId} = ?",
          whereArgs: [
            surveyResponseUniqueId,
            surveyQuestionId,
            surveyQuestionAnswerChoiceRowId,
            surveyQuestionAnswerChoiceColumnId,
            surveyQuestionAnswerChoiceSelectionId
          ]);
    }
  }

  void updateSurveyResponseSection(
      String surveyResponseUniqueId, int surveySectionId, bool selected) async {
    final db = await database;
    var res = await db.query(SurveyResponseSection.tableSurveyResponseSections,
        where: "${SurveyResponseSection.columnSurveyResponseUniqueId}=? "
            "and ${SurveyResponseSection.columnSurveySectionId}=? ",
        whereArgs: [
          surveyResponseUniqueId,
          surveySectionId,
        ]);
    SurveyResponseSection surveyResponseSection =
        res.isNotEmpty ? SurveyResponseSection.fromDbMap(res.first) : null;

    if (surveyResponseSection == null) {
      Uuid uuid = Uuid();
      String uniqueId = uuid.v4();
      surveyResponseSection = SurveyResponseSection(
          surveyResponseUniqueId: surveyResponseUniqueId,
          active: true,
          uniqueId: uniqueId,
          applicable: selected,
          surveySectionId: surveySectionId);
      await createSurveyResponseSection(surveyResponseSection);
    } else {
      await db.update(SurveyResponseSection.tableSurveyResponseSections,
          {SurveyResponseSection.columnApplicable: selected},
          where: "${SurveyResponseSection.columnSurveyResponseUniqueId} = ? "
              "and ${SurveyResponseSection.columnSurveySectionId} = ?",
          whereArgs: [surveyResponseUniqueId, surveySectionId]);
    }
  }

  Future<List<int>> getAllApplicableGroupsForSurveyResponse(
      String surveyResponseUniqueId) async {
    final db = await database;
    var res = await db.query(SurveyResponseSection.tableSurveyResponseSections,
        where: "${SurveyResponseSection.columnSurveyResponseUniqueId}=? "
            "and ${SurveyResponseSection.columnApplicable} = ?",
        whereArgs: [surveyResponseUniqueId, 1],
        columns: [SurveyResponseSection.columnSurveySectionId]);
    debugPrint("res $res");

    return res.isNotEmpty
        ? res
            .map((c) => c[SurveyResponseSection.columnSurveySectionId] as int)
            .toList()
        : [];
  }
}
