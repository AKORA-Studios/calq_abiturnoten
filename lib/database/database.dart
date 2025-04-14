import 'dart:math';

import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:calq_abiturnoten/database/Data_Test.dart';
import 'package:calq_abiturnoten/database/Data_Type.dart';
import 'package:calq_abiturnoten/util/averages.dart';
import 'package:calq_abiturnoten/util/color_extension.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'Data_Settings.dart';

class DatabaseClass {
  static late final Database db;
  static String PATH = "calq.db";
  static final DatabaseClass Shared = DatabaseClass();

  static const String SUBJECT_SHEMA =
      "Subject (id INTEGER PRIMARY KEY, color TEXT, exampoints INTEGER, examtype INTEGER, lk INTEGER, inactiveYears TEXT, name TEXT, showinlinegraph INTEGER)";
  static const String TEST_SHEMA =
      "Test (id INTEGER PRIMARY KEY, name TEXT, points INTEGER, type INTEGER, date TEXT, year INTEGER, subject INTEGER, FOREIGN KEY (subject) REFERENCES Subject(id))";
  static const String GRADETYPE_SHEMA =
      "Gradetype (id INTEGER PRIMARY KEY, name TEXT, weigth TEXT, assignedID INTEGER)";
  static const String APPSETTINGS_SHEMA =
      "Appsettings (colorfulCharts INTEGER, weightBigGrades TEXT, hasFiveexams INTEGER, primaryType INTEGER)";

  // Loaded AppSettings
  bool rainbowEnabled = true;
  bool hasFiveexams = true;
  int primaryType = -1;

  // Cache
  //id: subject
  Map<int, Data_Subject> mappedSubjects = {};
  Map<int, Map<int, Data_Test>> mappedTests = {};

  DatabaseClass() {
    print("Init Datase....");
    //  connectToDatabase();
  }

  static initDb() async {
    var databasesPath = await getDatabasesPath();
    PATH = join(databasesPath, 'calq.db');
    db = await openDatabase(PATH, version: 1, onCreate: _onCreate);
    print(".... Finished");
  }

  // When creating the db, create the table
  static void _onCreate(Database db1, int version) async {
    Map<String, String> allTables = {
      "Subject": SUBJECT_SHEMA,
      "Test": TEST_SHEMA,
      "Gradetype": GRADETYPE_SHEMA,
      "Appsettings": APPSETTINGS_SHEMA
    };
    for (String tab in allTables.keys) {
      String checkExistTable =
          "SELECT * FROM sqlite_master WHERE name ='$tab' and type='table'";
      var checkExist = await db1.rawQuery(checkExistTable);

      if (checkExist.isNotEmpty) {
      } else {
        print("Table $tab was missing :c");
        await db1.execute('CREATE TABLE ${allTables[tab]}');
      }
    }
  }

  // FETCH DATA
  Future<List<Map>?> fetchSettings() async {
    return await db.rawQuery('SELECT * FROM Appsettings');
  }

  Future<List<Map>?> fetchSubjects() async {
    return await db.rawQuery('SELECT * FROM Subject');
  }

  Future<List<Map>?> fetchTests() async {
    return await db.rawQuery('SELECT * FROM Test');
  }

  Future<List<Map>?> fetchTypes() async {
    return await db.rawQuery('SELECT * FROM Gradetype');
  }

  // GET DATA
  Future<Data_Settings> getSettings() async {
    List<Map<dynamic, dynamic>>? res = await fetchSettings();
    if (res == null || res.isEmpty) {
      print("WARNING: No AppSettings found");
      var temp = await createSettings();
      res = await fetchSettings();
    }

    var result = res!
        .map((e) {
          Map<String, Object> y =
              e.map((key, value) => MapEntry(key, value as Object));
          return Data_Settings.fromMap(y);
        })
        .toList()
        .first;
    rainbowEnabled = result.colorfulCharts;
    hasFiveexams = result.hasFiveexams;
    primaryType = result.primaryType;
    return result;
  }

  Future<List<Data_Subject>> getSubjects() async {
    if (mappedSubjects.isNotEmpty) {
      List<Data_Subject> subs = mappedSubjects.values.toList();
      subs.sort((a, b) => a.name.compareTo(b.name));
      subs.sort((a, b) {
        return b.lk ? 1 : -1;
      });
      return subs;
    }
    List<Map<dynamic, dynamic>>? res2 = await fetchSubjects();
    List<Map<dynamic, dynamic>>? resTests = await fetchTests();

    var result = res2?.map((e) {
          List<Map<dynamic, dynamic>>? subjectTests = resTests
              ?.where((element) => element["subject"] == e["id"])
              .toList();

          List<Map<String, Object>> x = [];
          subjectTests?.forEach((element) {
            element.map((key, value) => MapEntry(key, value as Object));
            x.add(element.map((key, value) => MapEntry(key, value as Object)));
          });

          Map<String, Object> y =
              e.map((key, value) => MapEntry(key, value as Object));
          return Data_Subject.fromMap(y, x);
        }).toList() ??
        [];
    result.sort((a, b) => a.name.compareTo(b.name));
    result.sort((a, b) {
      return b.lk ? 1 : -1;
    });
    // update mapping
    for (Data_Subject sub in result) {
      mappedSubjects[sub.id] = sub;
    }
    return result;
  }

  Future<List<Data_Test>> getSubjectTests(Data_Subject sub) async {
    if (mappedTests[sub.id] != null) {
      return mappedTests[sub.id]!.values.toList();
    }
    List<Map<dynamic, dynamic>>? resTests = await fetchTests();
    List<Map<dynamic, dynamic>>? subjectTests =
        resTests?.where((element) => element["subject"] == sub.id).toList();

    List<Map<String, Object>> x = [];
    subjectTests?.forEach((element) {
      element.map((key, value) => MapEntry(key, value as Object));
      x.add(element.map((key, value) => MapEntry(key, value as Object)));
    });

    return x.map((e) => Data_Test.fromMap(e)).toList();
  }

  Future<List<Data_Type>> getTypes() async {
    List<Map<dynamic, dynamic>>? res2 = await fetchTypes();

    // TODO: chekc if can be removed
    /*if (res2!.isEmpty) {
      resetTypes();
    }*/

    res2 = await fetchTypes();

    return res2?.map((e) {
          Map<String, Object> y =
              e.map((key, value) => MapEntry(key, value as Object));
          return Data_Type.fromMap(y);
        }).toList() ??
        [];
  }

  // CREATE DATA
  Future<int> createSubject(String name, String color, int lk,
      {String inactiveYears = ""}) async {
    int id = await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Subject(name, color, exampoints, examtype, lk,inactiveYears, showinlinegraph) VALUES(?,?,?,?,?,?,?)',
          [name, color, 0, 0, lk, inactiveYears, 1]);
      print('Inserted Subject: $id1');
      return id1;
    });

    mappedSubjects[id] = Data_Subject(
        id, name, fromHex(color), 0, 0, lk == 1, inactiveYears, true);
    return id;
  }

  Future<void> createTest(int subjectID, String name, int points, int year,
      DateTime date, int selectedType) async {
    if (subjectID < 0) {
      print("No! Invalid Subejct ID");
      return;
    }
    if (name.isEmpty) {
      print("No! Invalid Test Name");
      return;
    }
    int newID = await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Test(name, points, type, date, year,subject) VALUES(?,?,?,?,?,?)',
          [name, points, selectedType, date.toString(), year, subjectID]);
      print('Inserted Test: $id1');
      return id1;
    });
    mappedTests[subjectID]?[newID] =
        Data_Test(newID, name, points, selectedType, date, year);
  }

  Future<void> createSettings() async {
    await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Appsettings(colorfulCharts, weightBigGrades, hasFiveexams, primaryType)  VALUES(?,?,?, ?)',
          [1, "", 1, 0]);
      print('Inserted Appsettings: $id1');
    });
  }

  // MARK: Managed GradeTypes
  Future<void> addType(String name) async {
    await createType(name, 0.0, -1);
  }

  // Assigned id == -1 automatically assign id
  Future<void> createType(String name, double weight, int assignedID) async {
    List<Data_Type> existingTypes = await getTypes();

    List<int> existingIDs = existingTypes.map((e) => e.assignedID).toList();
    double existingWeights = existingTypes.isNotEmpty
        ? existingTypes.map((e) => e.weigth).toList().reduce((a, b) => a + b)
        : 0.0;

    int assignedNewID = assignedID;
    double weightNew = weight;
    if (assignedID < 0) {
      assignedNewID = getNewIDQwQ(existingIDs);
    }
    if (weightNew + existingWeights > 100.0) {
      weightNew = 0.0;
    }

    await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Gradetype(name, weigth, assignedID)  VALUES(?,?,?)',
          [name, weightNew, assignedNewID]);
      print('Inserted Gradetype: $id1');
    });
  }

  int getNewIDQwQ(List<int> ids) {
    final yMax = ids.cast<num>().reduce(max);

    for (var i = 0; i < yMax; i++) {
      if (!ids.contains(i)) {
        return i;
      }
    }
    return ids.length + 1;
  }

  Future<List<Data_Test>> getTypeGrades(int type) async {
    List<Data_Test> arr = [];
    List<Data_Subject> subjects =
        await getSubjects(); // TODO: just fetch tests without subs?

    for (Data_Subject sub in subjects) {
      List<Data_Test> tests = await getSubjectTests(sub);
      for (Data_Test test in tests) {
        if (test.type == type) {
          arr.add(test);
        }
      }
    }
    return arr;
  }

  // UPDATE DATA
  Future<void> updatePrimaryType(int newPrimaryType) async {
    int count = await db
        .rawUpdate('UPDATE Appsettings SET primaryType = ?', [newPrimaryType]);
    print('Updated Settings: $count');
    primaryType = newPrimaryType;
  }

  Future<void> editTypeWeights(Map<int, double> map) async {
    map.forEach((key, value) async {
      double roundedValue = double.parse(value.toStringAsFixed(1));
      int count = await db.rawUpdate(
          'UPDATE Gradetype SET weigth = ? WHERE id = ?', [roundedValue, key]);
      print('Updated Gradetype ${key}´s value: $count');
    });
  }

  Future<void> updateSettings(
      bool colorfulCharts, bool hasFiveExamsValue) async {
    int count = await db.rawUpdate(
        'UPDATE Appsettings SET colorfulCharts = ?, hasFiveexams = ?',
        [colorfulCharts ? 1 : 0, hasFiveExamsValue ? 1 : 0]);
    print('Updated Settings: $count');
    hasFiveexams = hasFiveExamsValue;
    rainbowEnabled = colorfulCharts;
  }

  Future<void> updateSubject(Data_Subject newSub) async {
    int count = await db.rawUpdate(
        'UPDATE Subject SET color = ?, exampoints = ?, examtype = ?, lk = ?, inactiveYears = ?, name = ?, showinlinegraph = ? WHERE id = ?',
        newSub.toMapUpdate());
    print('Updated Settings: $count');
    mappedSubjects[newSub.id] = newSub;
  }

  Future<void> updateTest(Data_Test newTest) async {
    mappedTests[newTest.subject]?[newTest.id] = newTest;
    int count = await db.rawUpdate(
        'UPDATE Test SET name = ?, points = ?, type = ?, date = ?, year = ? WHERE id = ?',
        [
          newTest.name,
          newTest.points,
          newTest.type,
          newTest.date.toString(),
          newTest.year,
          newTest.id
        ]);

    print('Updated Test: $count');
  }

  Future<void> updateSubjectYear(Data_Subject sub) async {
    int count = await db.rawUpdate(
        'UPDATE Subject SET inactiveYears = ?, WHERE id = ?',
        [sub.inactiveYears, sub.id]);
    print('Updated Settings: $count');
  }

  // FINAL EXAMS
  List<int> examPoints = [0, 0, 0, 0, 0];
  Future<void> updateSubjectExam(Data_Subject sub, int type) async {
    // TODO: Validate
    await resetExams(year: type); // reset exams before in this year

    int count = await db.rawUpdate(
        'UPDATE Subject SET examtype = ? WHERE id = ?', [type, sub.id]);
    print('Updated Exam: $count');
  }

  /// Remove Exam of type [type]
  Future<void> removeExam(int type) async {
    await resetExams(year: type);
    examPoints[type - 1] = 0;
  }

  /// Update the Exam [points] of a [subject]
  Future<void> updateExamPoints(int points, Data_Subject sub) async {
    if (points > 15 || points < 0) {
      print("Error updating Exampoints for _${sub.name}_! Out of range");
      return;
    }
    int count = await db.rawUpdate(
        'UPDATE Subject SET exampoints = ? WHERE id = ?', [points, sub.id]);
    print('Updated Exam points: $count');
    examPoints[sub.examtype - 1] = points;
  }

// DELETE DATA
  Future<void> deleteData() async {
    await db.rawQuery('DELETE FROM Subject;');
    await db.rawQuery('DELETE FROM Test;');
    await db.rawQuery('DELETE FROM Gradetype;');
    await db.rawQuery('DELETE FROM Appsettings;');

    await resetTypes();
  }

  Future<void> deleteSubject(int id) async {
    int count = await db.rawDelete('DELETE FROM Subject WHERE id = ?', [id]);
    assert(count == 1);
    mappedSubjects.remove(id);
  }

  Future<void> deleteTest(int id, int subID) async {
    int count = await db.rawDelete('DELETE FROM Test WHERE id = ?', [id]);
    assert(count == 1);
    mappedTests[subID]?.remove(id);
  }

  Future<void> deleteSubjectTests(Data_Subject sub) async {
    List<Map<dynamic, dynamic>>? resTests = await fetchTests();
    List<Map<dynamic, dynamic>>? subjectTests =
        resTests?.where((element) => element["subject"] == sub.id).toList();
    List<dynamic>? ids = subjectTests?.map((e) {
      return e["id"];
    }).toList();

    ids?.forEach((element) async {
      int count = await db
          .rawDelete('DELETE FROM Test WHERE id = ?', [element.toString()]);
      assert(count == 1);
    });
  }

  Future<bool> deleteType(int typeID) async {
    List<Data_Test> testsWithType = await getTypeGrades(typeID);

    if (testsWithType.isNotEmpty) {
      print("Tests still use this type!");
      return false;
    }

    int count = await db
        .rawDelete('DELETE FROM Gradetype WHERE assignedID = ?', [typeID]);
    assert(count == 1);
    return true;
  }

  Future<void> deleteAllTypes() async {
    int count = await db.rawDelete(
      'DELETE FROM Gradetype',
    );
    //assert(count == 1);
  }

  // RESET DATA
  /// add default grade types
  Future<void> resetTypes() async {
    await deleteAllTypes();

    await createType("Test", 50, 0);
    await createType("Klausur", 50, 1);

    Averages.setPrimaryType(1);
  }

  Future<void> resetExams({int year = -1}) async {
    //  TODO: validate
    var args = year < 0
        ? [0, 0]
        : [0, 0, year]; // remove all exams if no year specified
    int count = await db.rawUpdate(
        'UPDATE Subject SET examtype = ?, exampoints = ? WHERE examtype = ?',
        args);
    print('Reseted Exams: $count');
  }
}
