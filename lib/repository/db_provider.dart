import 'dart:async';
import 'dart:io';

import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_selection_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

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
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Surveys ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "description TEXT,"
          "active BIT"
          ")");
      await db.execute("CREATE TABLE SurveyGroups ("
          "id INTEGER PRIMARY KEY,"
          "active BIT,"
          "name TEXT,"
          "description TEXT,"
          "survey_id INTEGER"
          ")");
      await db.execute("CREATE TABLE SurveyQuestions ("
          "id INTEGER PRIMARY KEY,"
          "active BIT,"
          "survey_id INTEGER,"
          "question TEXT,"
          "question_description TEXT,"
          "order_ INTEGER,"
          "question_type TEXT,"
          "required BIT,"
          "required_error TEXT,"
          "multiple_selection BIT,"
          "group_id INTEGER"
          ")");
      await db.execute("CREATE TABLE SurveyQuestionAnswerChoices ("
          "id INTEGER PRIMARY KEY,"
          "survey_question_id INTEGER,"
          "label TEXT,"
          "question_type TEXT,"
          "axis TEXT,"
          "matrix_column_type TEXT,"
          "index_ INTEGER,"
          "min_length INTEGER,"
          "max_length INTEGER,"
          "min_value REAL,"
          "max_value REAL,"
          "min_date TEXT,"
          "max_date TEXT,"
          "validate BIT,"
          "validation_error TEXT,"
          "multiple_selection BIT,"
          "is_other BIT,"
          "make_selected_question_required INTEGER"
          ")");
      await db.execute("CREATE TABLE SurveyQuestionAnswerChoiceSelections ("
          "id INTEGER PRIMARY KEY,"
          "survey_question_answer_choice_id INTEGER,"
          "label TEXT"
          ")");
      await db.execute("CREATE TABLE SurveyResponses ("
          "uniqueId TEXT PRIMARY KEY,"
          "id INTEGER,"
          "active BIT,"
          "survey_id INTEGER,"
          "form_name TEXT,"
          "created_on TEXT"
          ")");
    });
  }

  /*
  Surveys
   */

  Future<Survey> getSurvey(int id) async {
    final db = await database;
    var res = await db.query("Surveys", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Survey.fromDbMap(res.first) : null;
  }

  Future<Survey> createSurvey(Survey survey) async {
    final db = await database;
    //get the biggest id in the table
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Surveys (id,name,description,active)"
        " VALUES (?,?,?,?)",
        [survey.id, survey.name, survey.description, survey.active]);
//    debugPrint("Created survey: " + survey.toString());
    return survey;
  }

  updateSurvey(Survey survey) async {
    final db = await database;
    var res = await db.update("Surveys", survey.toDbMap(),
        where: "id = ?", whereArgs: [survey.id]);
    return res;
  }

  deleteSurvey(int id) async {
    final db = await database;
    var delete = db.delete("Surveys", where: "id = ?", whereArgs: [id]);
//    debugPrint("Removed survey with id [$id]");
    return delete;
  }

  Future<List<Survey>> getAllSurveys() async {
    final db = await database;
    var res = await db.query("Surveys");
    List<Survey> list =
        res.isNotEmpty ? res.map((c) => Survey.fromDbMap(c)).toList() : [];
//    debugPrint("Retrieved all surveys");
    return list;
  }

  blockOrUnblock(Survey survey) async {
    final db = await database;
    Survey blocked = Survey(
        id: survey.id,
        name: survey.name,
        description: survey.description,
        active: !survey.active);
    var res = await db.update("Surveys", blocked.toDbMap(),
        where: "id = ?", whereArgs: [survey.id]);
    return res;
  }

  Future<List<Survey>> getBlockedSurveys() async {
    final db = await database;

    print("works");
    // var res = await db.rawQuery("SELECT * FROM Client WHERE blocked=1");
    var res = await db.query("Surveys", where: "blocked = ? ", whereArgs: [1]);

    List<Survey> list =
        res.isNotEmpty ? res.map((c) => Survey.fromDbMap(c)).toList() : [];
//    debugPrint("Retrieved all blocked surveys");
    return list;
  }

  deleteAll() async {
    final db = await database;
    await db.rawDelete("Delete from Surveys");
    await db.rawDelete("Delete from SurveyGroups");
    await db.rawDelete("Delete from SurveyQuestions");
    await db.rawDelete("Delete from SurveyQuestionAnswerChoices");
    await db.rawDelete("Delete from SurveyQuestionAnswerChoiceSelections");

//    debugPrint("Removed all surveys");
  }

  /*
  SurveyGroups
   */
  Future<SurveyGroup> getSurveyGroup(int id) async {
    final db = await database;
    var res = await db.query("SurveyGroups", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? SurveyGroup.fromDbMap(res.first) : null;
  }

  createSurveyGroup(SurveyGroup surveyGroup) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into SurveyGroups (id,survey_id,name,description,active)"
        " VALUES (?,?,?,?,?)",
        [
          surveyGroup.id,
          surveyGroup.surveyId,
          surveyGroup.name,
          surveyGroup.description,
          surveyGroup.active
        ]);
//    debugPrint("Created survey: " + surveyGroup.toString());
    return raw;
  }

  updateSurveyGroup(SurveyGroup surveyGroup) async {
    final db = await database;
    var res = await db.update("SurveyGroups", surveyGroup.toDbMap(),
        where: "id = ?", whereArgs: [surveyGroup.id]);
    return res;
  }

  deleteSurveyGroup(int id) async {
    final db = await database;
    var delete = db.delete("SurveyGroups", where: "id = ?", whereArgs: [id]);
//    debugPrint("Removed surveyGroup with id [$id]");
    return delete;
  }

  Future<List<SurveyGroup>> getAllSurveyGroups() async {
    final db = await database;
    var res = await db.query("SurveyGroups");
    List<SurveyGroup> list =
        res.isNotEmpty ? res.map((c) => SurveyGroup.fromDbMap(c)).toList() : [];
//    debugPrint("Retrieved all surveyGroups");
    return list;
  }

/*
  SurveyQuestions
   */

  Future<SurveyQuestion> getSurveyQuestion(int id) async {
    final db = await database;
    var res =
        await db.query("SurveyQuestions", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? SurveyQuestion.fromDbMap(res.first) : null;
  }

  createSurveyQuestion(SurveyQuestion surveyQuestion) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into SurveyQuestions (id,active,survey_id,question,question_description,order_,question_type,required,required_error,"
        "multiple_selection, group_id)"
        " VALUES (?,?,?,?,?,?,?,?,?,?,?)",
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
          surveyQuestion.groupId,
        ]);
//    debugPrint("Created surveyQuestion: " + surveyQuestion.toString());
    return raw;
  }

  updateSurveyQuestion(SurveyQuestion surveyQuestion) async {
    final db = await database;
    var res = await db.update("SurveyQuestions", surveyQuestion.toDbMap(),
        where: "id = ?", whereArgs: [surveyQuestion.id]);
    return res;
  }

  deleteSurveyQuestion(int id) async {
    final db = await database;
    var delete = db.delete("SurveyQuestions", where: "id = ?", whereArgs: [id]);
//    debugPrint("Removed surveyQuestion with id [$id]");
    return delete;
  }

  Future<List<SurveyQuestion>> getAllSurveyQuestions() async {
    final db = await database;
    var res = await db.query("SurveyQuestions");
    List<SurveyQuestion> list = res.isNotEmpty
        ? res.map((c) => SurveyQuestion.fromDbMap(c)).toList()
        : [];
//    debugPrint("Retrieved all surveyQuestions");
    return list;
  }

  Future<List<SurveyQuestion>> getAllSurveyQuestionsForSurvey(
      int surveyId) async {
    final db = await database;
    var res = await db.query("SurveyQuestions",
        where: "survey_id= ?", whereArgs: [surveyId], orderBy: "order_");
    List<SurveyQuestion> list = res.isNotEmpty
        ? res.map((c) => SurveyQuestion.fromDbMap(c)).toList()
        : [];
//    debugPrint("Retrieved all surveyQuestions ${list.length}");
    return list;
  }

  Future<bool> isSurveyQuestionDependant(int surveyQuestionId) async {
    final db = await database;
    var res = await db.query(
      "SurveyQuestionAnswerChoices",
      where: "make_selected_question_required= ?",
      whereArgs: [surveyQuestionId],
    );
    List<SurveyQuestionAnswerChoice> list = res.isNotEmpty
        ? res.map((c) => SurveyQuestionAnswerChoice.fromDbMap(c)).toList()
        : [];
//    debugPrint("SurveyQuestion is dependant ${(list != null && list.length > 0)}");
    return (list != null && list.length > 0);
  }

  /*
  SurveyQuestionAnswerChoices
   */

  Future<SurveyQuestionAnswerChoice> getSurveyQuestionAnswerChoice(
      int id) async {
    final db = await database;
    var res = await db.query("SurveyQuestionAnswerChoices",
        where: "id = ?", whereArgs: [id], columns: ["id"]);
    return res.isNotEmpty
        ? SurveyQuestionAnswerChoice.fromDbMap(res.first)
        : null;
  }

  createSurveyQuestionAnswerChoice(
      SurveyQuestionAnswerChoice surveyQuestionAnswerChoice) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into SurveyQuestionAnswerChoices (id,survey_question_id,label,question_type,axis,matrix_column_type,"
        "index_,min_length,max_length,min_value,max_value,min_date,max_date,validate,validation_error,multiple_selection,"
        "is_other,make_selected_question_required)"
        " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
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
          surveyQuestionAnswerChoice.makeSelectedQuestionRequired
        ]);
//    debugPrint("Created surveyQuestionAnswerChoice: " +
//        surveyQuestionAnswerChoice.toString());
    return raw;
  }

  updateSurveyQuestionAnswerChoice(
      SurveyQuestionAnswerChoice surveyQuestionAnswerChoice) async {
    final db = await database;
    var res = await db.update(
        "SurveyQuestionAnswerChoices", surveyQuestionAnswerChoice.toDbMap(),
        where: "id = ?", whereArgs: [surveyQuestionAnswerChoice.id]);
    return res;
  }

  deleteSurveyQuestionAnswerChoice(int id) async {
    final db = await database;
    var delete = db.delete("SurveyQuestionAnswerChoices",
        where: "id = ?", whereArgs: [id]);
//    debugPrint("Removed surveyQuestionAnswerChoice with id [$id]");
    return delete;
  }

  Future<List<SurveyQuestionAnswerChoice>>
      getAllSurveyQuestionAnswerChoices() async {
    final db = await database;
    var res = await db.query("SurveyQuestionAnswerChoices");
    List<SurveyQuestionAnswerChoice> list = res.isNotEmpty
        ? res.map((c) => SurveyQuestionAnswerChoice.fromDbMap(c)).toList()
        : [];
//    debugPrint("Retrieved all surveyQuestionAnswerChoices");
    return list;
  }

  Future<List<SurveyQuestionAnswerChoice>>
      getSurveyQuestionAnswerChoiceByQuestion(int surveyQuestionId) async {
    final db = await database;
    var res = await db.query("SurveyQuestionAnswerChoices",
        where: "survey_question_id=?", whereArgs: [surveyQuestionId]);
    List<SurveyQuestionAnswerChoice> list = res.isNotEmpty
        ? res.map((c) => SurveyQuestionAnswerChoice.fromDbMap(c)).toList()
        : [];
    debugPrint("Retrieved surveyQuestionAnswerChoices size ${list.length}");
    return list;
  }

  /*
  SurveyQuestionAnswerChoiceSelections
   */

  Future<SurveyQuestionAnswerChoiceSelection>
      getSurveyQuestionAnswerChoiceSelection(int id) async {
    final db = await database;
    var res = await db.query("SurveyQuestionAnswerChoiceSelections",
        where: "id = ?", whereArgs: [id]);
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
        "INSERT Into SurveyQuestionAnswerChoiceSelections (id,survey_question_answer_choice_id,label)"
        " VALUES (?,?,?)",
        [
          surveyQuestionAnswerChoiceSelection.id,
          surveyQuestionAnswerChoiceSelection.surveyQuestionAnswerChoiceId,
          surveyQuestionAnswerChoiceSelection.label
        ]);
//    debugPrint("Created surveyQuestionAnswerChoiceSelection: " +
//        surveyQuestionAnswerChoiceSelection.toString());
    return raw;
  }

  updateSurveyQuestionAnswerChoiceSelection(
      SurveyQuestionAnswerChoiceSelection
          surveyQuestionAnswerChoiceSelection) async {
    final db = await database;
    var res = await db.update("SurveyQuestionAnswerChoiceSelections",
        surveyQuestionAnswerChoiceSelection.toDbMap(),
        where: "id = ?", whereArgs: [surveyQuestionAnswerChoiceSelection.id]);
    return res;
  }

  deleteSurveyQuestionAnswerChoiceSelection(int id) async {
    final db = await database;
    var delete = db.delete("SurveyQuestionAnswerChoiceSelections",
        where: "id = ?", whereArgs: [id]);
//    debugPrint("Removed surveyQuestionAnswerChoiceSelection with id [$id]");
    return delete;
  }

  Future<List<SurveyQuestionAnswerChoiceSelection>>
      getAllSurveyQuestionAnswerChoiceSelections() async {
    final db = await database;
    var res = await db.query("SurveyQuestionAnswerChoiceSelections");
    List<SurveyQuestionAnswerChoiceSelection> list = res.isNotEmpty
        ? res
            .map((c) => SurveyQuestionAnswerChoiceSelection.fromDbMap(c))
            .toList()
        : [];
//    debugPrint("Retrieved all surveyQuestionAnswerChoiceSelections");
    return list;
  }

  /*
  SurveyResponses
   */

  Future<SurveyResponse> getSurveyResponse(int id) async {
    final db = await database;
    var res =
        await db.query("SurveyResponses", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? SurveyResponse.fromDbMap(res.first) : null;
  }

  createSurveyResponse(SurveyResponse surveyResponse) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into SurveyResponses (id,uniqueId, survey_id,form_name, created_on,active)"
        " VALUES (?,?,?,?,?,?)",
        [
          surveyResponse.id,
          surveyResponse.uniqueId,
          surveyResponse.surveyId,
          surveyResponse.formName,
          DateFormat('yyyy-MM-dd – kk:mm').format(surveyResponse.createdOn),
          surveyResponse.active
        ]);
//    debugPrint("Created surveyQuestionAnswerChoiceSelection: " +
//        surveyQuestionAnswerChoiceSelection.toString());
    return raw;
  }

  updateSurveyResponse(SurveyResponse surveyResponse) async {
    final db = await database;
    var res = await db.update("SurveyResponses", surveyResponse.toDbMap(),
        where: "id = ?", whereArgs: [surveyResponse.id]);
    return res;
  }

  deleteSurveyResponse(int id) async {
    final db = await database;
    var delete = db.delete("SurveyResponses", where: "id = ?", whereArgs: [id]);
//    debugPrint("Removed surveyQuestionAnswerChoiceSelection with id [$id]");
    return delete;
  }

  Future<List<SurveyResponse>> getAllSurveyResponses(int surveyId) async {
    final db = await database;
    var res = await db
        .query("SurveyResponses", where: "survey_id=?", whereArgs: [surveyId]);
    List<SurveyResponse> list = res.isNotEmpty
        ? res.map((c) => SurveyResponse.fromDbMap(c)).toList()
        : [];
//    debugPrint("Retrieved all surveyQuestionAnswerChoiceSelections");
    return list;
  }
}
