import 'dart:async';
import 'dart:io';

import 'package:es_control_app/model/survey_group_model.dart';
import 'package:es_control_app/model/survey_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_model.dart';
import 'package:es_control_app/model/survey_question_answer_choice_selection_model.dart';
import 'package:es_control_app/model/survey_question_model.dart';
import 'package:es_control_app/model/survey_response_answer_model.dart';
import 'package:es_control_app/model/survey_response_group_model.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/util/matrix_column_types.dart';
import 'package:es_control_app/util/question_types.dart';
import 'package:intl/intl.dart';
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
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Surveys ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "description TEXT,"
          "active BIT"
          ")");
      await db.execute("CREATE TABLE ${SurveyGroup.tableSurveyGroups} ("
          "${SurveyGroup.columnId} INTEGER PRIMARY KEY,"
          "${SurveyGroup.columnActive} BIT,"
          "${SurveyGroup.columnName} TEXT,"
          "${SurveyGroup.columnDescription} TEXT,"
          "${SurveyGroup.columnSurveyId} INTEGER,"
          "${SurveyGroup.columnEnableApplicability} BIT"
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
      await db.execute(
          "CREATE TABLE ${SurveyQuestionAnswerChoiceSelection.tableSurveyQuestionAnswerChoiceSelections} ("
          "${SurveyQuestionAnswerChoiceSelection.columnId} INTEGER PRIMARY KEY,"
          "${SurveyQuestionAnswerChoiceSelection.columnSurveyQuestionAnswerChoiceId} INTEGER,"
          "${SurveyQuestionAnswerChoiceSelection.columnLabel} TEXT"
          ")");
      await db.execute("CREATE TABLE SurveyResponses ("
          "unique_id TEXT PRIMARY KEY,"
          "id INTEGER,"
          "active BIT,"
          "survey_id INTEGER,"
          "form_name TEXT,"
          "created_on TEXT"
          ")");
      await db.execute(
          "CREATE TABLE ${SurveyResponseGroup.tableSurveyResponseGroups} ("
          "${SurveyResponseGroup.columnUniqueId} TEXT PRIMARY KEY,"
          "${SurveyResponseGroup.columnId} INTEGER,"
          "${SurveyResponseGroup.columnActive} BIT,"
          "${SurveyResponseGroup.columnSurveyResponseUniqueId} TEXT,"
          "${SurveyResponseGroup.columnSurveyGroupId} INTEGER,"
          "${SurveyResponseGroup.columnApplicable} BIT"
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
    await db.rawDelete("Delete from Surveys");
    await db.rawDelete("Delete from SurveyGroups");
    await db.rawDelete("Delete from SurveyQuestions");
    await db.rawDelete("Delete from SurveyQuestionAnswerChoices");
    await db.rawDelete("Delete from SurveyQuestionAnswerChoiceSelections");
  }

  Future<SurveyResponse> getSurveyResponse(int id) async {
    final db = await database;
    var res = await db.query(SurveyResponse.tableSurveyResponses,
        where: "id = ?", whereArgs: [id]);
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
        "INSERT Into ${SurveyResponse.tableSurveyResponses} (${SurveyResponse.columnId},${SurveyResponse.columnUniqueId}, ${SurveyResponse.columnSurveyId},${SurveyResponse.columnFormName},${SurveyResponse.columnCreatedOn},${SurveyResponse.columnActive})"
        " VALUES (?,?,?,?,?,?)",
        [
          surveyResponse.id,
          surveyResponse.uniqueId,
          surveyResponse.surveyId,
          surveyResponse.formName,
          DateFormat('yyyy-MM-dd – kk:mm').format(surveyResponse.createdOn),
          surveyResponse.active
        ]);
    return raw;
  }

  updateSurveyResponse(SurveyResponse surveyResponse) async {
    final db = await database;
    var res = await db.update(
        SurveyResponse.tableSurveyResponses, surveyResponse.toDbMap(),
        where: "id = ?", whereArgs: [surveyResponse.id]);
    return res;
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
        where: "${SurveyResponse.columnSurveyId}=?", whereArgs: [surveyId]);
    List<SurveyResponse> list = res.isNotEmpty
        ? res.map((c) => SurveyResponse.fromDbMap(c)).toList()
        : [];
    return list;
  }

  Future<SurveyResponseAnswer> getSurveyResponseAnswer(int id) async {
    final db = await database;
    var res = await db.query(SurveyResponseAnswer.tableSurveyResponseAnswers,
        where: "id = ?", whereArgs: [id]);
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
        where: "id = ?", whereArgs: [surveyResponseAnswer.id]);
    return res;
  }

  deleteSurveyResponseAnswer(int id) async {
    final db = await database;
    var delete = db.delete(SurveyResponseAnswer.tableSurveyResponseAnswers,
        where: "id = ?", whereArgs: [id]);
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
    return delete;
  }

  Future<List<Survey>> getAllSurveys() async {
    final db = await database;
    var res = await db.query("Surveys");
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
    return list;
  }

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
    return delete;
  }

  Future<List<SurveyQuestion>> getAllSurveyQuestions(int surveyId) async {
    final db = await database;
    var res = await db.query(SurveyQuestion.tableSurveyQuestions,
        where: "${SurveyQuestion.columnSurveyId}=?", whereArgs: [surveyId]);
    List<SurveyQuestion> list = res.isNotEmpty
        ? res.map((c) => SurveyQuestion.fromDbMap(c)).toList()
        : [];
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
        "INSERT Into ${SurveyQuestionAnswerChoiceSelection.tableSurveyQuestionAnswerChoiceSelections} (${SurveyQuestionAnswerChoiceSelection.columnId},${SurveyQuestionAnswerChoiceSelection.columnSurveyQuestionAnswerChoiceId},${SurveyQuestionAnswerChoiceSelection.columnLabel})"
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
    return delete;
  }

  Future<List<SurveyQuestionAnswerChoice>>
      getAllSurveyQuestionAnswerChoices() async {
    final db = await database;
    var res = await db.query("SurveyQuestionAnswerChoices");
    List<SurveyQuestionAnswerChoice> list = res.isNotEmpty
        ? res.map((c) => SurveyQuestionAnswerChoice.fromDbMap(c)).toList()
        : [];
    return list;
  }

  Future<List<SurveyQuestionAnswerChoice>>
      getSurveyQuestionAnswerChoiceByQuestion(int surveyQuestionId) async {
    final db = await database;
    var res = await db.query("SurveyQuestionAnswerChoices",
        where: "${SurveyQuestionAnswerChoice.columnSurveyQuestionId}=?",
        whereArgs: [surveyQuestionId],
        orderBy: SurveyQuestionAnswerChoice.columnIndex);
    List<SurveyQuestionAnswerChoice> list = res.isNotEmpty
        ? res.map((c) => SurveyQuestionAnswerChoice.fromDbMap(c)).toList()
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
        "INSERT Into ${SurveyGroup.tableSurveyGroups} (${SurveyGroup.columnId},${SurveyGroup.columnSurveyId},${SurveyGroup.columnName},${SurveyGroup.columnDescription},${SurveyGroup.columnActive},${SurveyGroup.columnEnableApplicability})"
        " VALUES (?,?,?,?,?,?)",
        [
          surveyGroup.id,
          surveyGroup.surveyId,
          surveyGroup.name,
          surveyGroup.description,
          surveyGroup.active,
          surveyGroup.enableApplicability
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

  createSurveyResponseGroup(SurveyResponseGroup surveyResponseGroup) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into ${SurveyResponseGroup.tableSurveyResponseGroups} "
        "(${SurveyResponseGroup.columnSurveyGroupId},"
        "${SurveyResponseGroup.columnSurveyResponseUniqueId}, "
        "${SurveyResponseGroup.columnActive}, "
        "${SurveyResponseGroup.columnApplicable},"
        "${SurveyResponseGroup.columnUniqueId})"
        " VALUES (?,?,?,?,?)",
        [
          surveyResponseGroup.surveyGroupId,
          surveyResponseGroup.surveyResponseUniqueId,
          surveyResponseGroup.active,
          surveyResponseGroup.applicable,
          surveyResponseGroup.uniqueId,
        ]);
    return raw;
  }

  Future<SurveyResponseGroup> getSurveyResponseGroupByResponseAndGroup(
      String surveyResponseUniqueId, int surveyGroupId) async {
    final db = await database;
    var res = await db.query(SurveyResponseGroup.tableSurveyResponseGroups,
        where: "${SurveyResponseGroup.columnSurveyResponseUniqueId} = ? "
            "and ${SurveyResponseGroup.columnSurveyGroupId} = ? ",
        whereArgs: [surveyResponseUniqueId, surveyGroupId]);
    return res.isNotEmpty ? SurveyResponseGroup.fromDbMap(res.first) : null;
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

  void updateSurveyResponseGroup(
      String surveyResponseUniqueId, int surveyGroupId, bool selected) async {
    final db = await database;
    var res = await db.query(SurveyResponseGroup.tableSurveyResponseGroups,
        where: "${SurveyResponseGroup.columnSurveyResponseUniqueId}=? "
            "and ${SurveyResponseGroup.columnSurveyGroupId}=? ",
        whereArgs: [
          surveyResponseUniqueId,
          surveyGroupId,
        ]);
    SurveyResponseGroup surveyResponseGroup =
        res.isNotEmpty ? SurveyResponseGroup.fromDbMap(res.first) : null;

    if (surveyResponseGroup == null) {
      Uuid uuid = Uuid();
      String uniqueId = uuid.v4();
      SurveyResponseGroup surveyResponseGroup = SurveyResponseGroup(
          surveyResponseUniqueId: surveyResponseUniqueId,
          active: true,
          uniqueId: uniqueId,
          applicable: selected,
          surveyGroupId: surveyGroupId);
      await createSurveyResponseGroup(surveyResponseGroup);
    } else {
      await db.update(SurveyResponseGroup.tableSurveyResponseGroups,
          {SurveyResponseGroup.columnApplicable: selected},
          where: "${SurveyResponseGroup.columnSurveyResponseUniqueId} = ? "
              "and ${SurveyResponseGroup.columnSurveyGroupId} = ?",
          whereArgs: [surveyResponseUniqueId, surveyGroupId]);
    }
  }
}
