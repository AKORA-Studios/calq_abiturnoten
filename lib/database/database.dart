import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseClass {
  static late final Database db;
  static late String PATH = "calq.db";
  static final DatabaseClass Shared = DatabaseClass();

  static final String SUBJECT_SHEMA =
      "Subject (id INTEGER PRIMARY KEY, color TEXT, exampoints INTEGER, examtype INTEGER, lk INTEGER, inactiveYears TEXT, name TEXT, showinlinegraph INTEGER)";
  static final String TEST_SHEMA =
      "Test (id INTEGER PRIMARY KEY, name TEXT, points INTEGER, type INTEGER, date TEXT, year INTEGER, subject INTEGER, FOREIGN KEY (subject) REFERENCES Subject(id))";
  static final String GRADETYPE_SHEMA =
      "Gradetype (id INTEGER PRIMARY KEY, name TEXT, weigth TEXT)";
  static final String APPSETTINGS_SHEMA =
      "Appsettings (colorfulCharts INTEGER, weightBigGrades TEXT, hasFiveexams INTEGER)";

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

  Future<void> deleteData() async {
    await deleteDatabase(PATH);
  }

  Future<void> createSubject() async {
    await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Subject(name, color, exampoints, examtype, lk,inactiveYears, showinlinegraph) VALUES("some name", "3af4de", 0, 0, 0, "", 1)');
      print('inserted1: $id1');
    });
  }

  Future<void> createTest(int subjectID) async {
    await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Test(name, points, type, date, year,subject) VALUES("some cool unique name", 12, 1, "", 1, $subjectID)');
      print('Inserted Test: $id1');
    });
  }

/*
 // Delete a record
count = await database
    .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
assert(count == 1);

// Update some record
int count = await database.rawUpdate(
    'UPDATE Test SET name = ?, value = ? WHERE name = ?',
    ['updated name', '9876', 'some name']);
print('updated: $count');
**/
  Future<List<Map>?> getSubjects() async {
    return await db.rawQuery('SELECT * FROM Subject');
  }

  Future<List<Map>?> getTests() async {
    return await db.rawQuery('SELECT * FROM Test');
  }

  Future<List<Data_Subject>> getSubjectsList() async {
    List<Map<dynamic, dynamic>>? res2 = await getSubjects();
    List<Map<dynamic, dynamic>>? resTests = await getTests();

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
}
