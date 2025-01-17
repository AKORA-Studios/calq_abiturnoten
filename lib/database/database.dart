import 'package:calq_abiturnoten/database/Data_Subject.dart';
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
      "Gradetype (id INTEGER PRIMARY KEY, name TEXT, weigth TEXT)";
  static const String APPSETTINGS_SHEMA =
      "Appsettings (colorfulCharts INTEGER, weightBigGrades TEXT, hasFiveexams INTEGER)";

  // Loaded AppSettings
  bool rainbowEnabled = true;
  bool hasFiveexams = true;

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
      var checkExist = await db.rawQuery(checkExistTable);

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
    return result;
  }

  Future<List<Data_Subject>> getSubjects() async {
    List<Map<dynamic, dynamic>>? res2 = await fetchSubjects();
    List<Map<dynamic, dynamic>>? resTests = await fetchTests();

    return res2?.map((e) {
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
  }

  // CREATE DATA
  Future<void> createSubject(String name, String color, int lk) async {
    await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Subject(name, color, exampoints, examtype, lk,inactiveYears, showinlinegraph) VALUES(?,?,?,?,?,?,?)',
          [name, color, 0, 0, lk, "", 1]);
      print('Inserted Subject: $id1');
    });
  }

  Future<void> createTest(int subjectID, String name, int points) async {
    if (name.isEmpty) {
      print("No! Invalid Test Name");
      return;
    }
    await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Test(name, points, type, date, year,subject) VALUES(?,?,?,?,?,?)',
          [name, points, 1, "", 1, subjectID]);
      print('Inserted Test: $id1');
    });
  }

  Future<void> createSettings() async {
    await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Appsettings(colorfulCharts, weightBigGrades, hasFiveexams)  VALUES(?,?,?)',
          [1, "", 1]);
      print('Inserted Appsettings: $id1');
    });
  }

  Future<void> createType(String name, double weigth) {
    /*
    *   let existingTypes = getTypes().map { $0.id }

  let newType = GradeType(context: getContext())
  newType.name = name
  newType.weigth = weigth
  newType.id = getNewIDQwQ(existingTypes)

  let new = getTypes().map {$0.weigth}.reduce(0.0, +)
  if new + weigth > 100.0 {
  newType.weigth = 0.0
  }
  let settings = Util.getSettings()
  settings.addToGradetypes(newType)
  saveCoreData()

  return newType*/
  }

  /*

  // MARK: Managed GradeTypes
  static func addSecondType(_ firstID: Int16) {
  let newType = GradeType(context: getContext())
  newType.name = "new default type"
  newType.weigth = 0.0
  newType.id = getNewIDQwQ([firstID])

  let settings = Util.getSettings()
  settings.addToGradetypes(newType)
  saveCoreData()
  }



    private static func getNewIDQwQ(_ ids: [Int16]) -> Int16 {
  for i in 0...(ids.max() ?? Int16(ids.count)) {
  if !ids.contains(Int16(i)) { return Int16(i) }
  }
  return Int16(ids.count + 1)
  }


  static func getTypes() -> [GradeType] {
  var types = getSettings().getAllGradeTypes()

  if types.count >= 2 { return types }

  if types.count == 1 {
  addSecondType(types[0].id)
  } else if types.isEmpty {
  setTypes(Util.getSettings())
  }

    static func getTypeGrades(_ type: Int16) -> [UserTest] {
  var arr: [UserTest] = []
  for sub in Util.getAllSubjects() {
  for test in Util.getAllSubjectTests(sub) {
  if test.type != type { continue }
  arr.append(test)
  }
  }
  return arr
  }
  * */

  // UPDATE DATA
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
  }

  Future<void> updatesubjectYear(Data_Subject sub) async {
    int count = await db.rawUpdate(
        'UPDATE Subject SET inactiveYears = ?, WHERE id = ?',
        [sub.inactiveYears, sub.id]);
    print('Updated Settings: $count');
  }

// DELETE DATA
  Future<void> deleteData() async {
    await deleteDatabase(PATH);
  }

  Future<void> deleteSubject(int id) async {
    int count = await db.rawDelete('DELETE FROM Subject WHERE id = ?', [id]);
    assert(count == 1);
  }

  Future<void> deleteType(int id) async {
    // TODO: IMPLEMENT Tpes
  }
}
