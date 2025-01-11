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
      "Test (id INTEGER PRIMARY KEY, name TEXT, points INTEGER, type INTEGER, date TEXT, year INTEGER, subject INT FOREIGN KEY REFERENCES Subject(id))";

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
    String checkExistTable =
        "SELECT * FROM sqlite_master WHERE name ='Subject' and type='table'";
    var checkExist = await db.rawQuery(checkExistTable);

    if (checkExist.isNotEmpty) {
      // table exist
    } else {
      await db1.execute('CREATE TABLE $SUBJECT_SHEMA');
    }
    // Check 2
    checkExistTable =
        "SELECT * FROM sqlite_master WHERE name ='Test' and type='table'";
    checkExist = await db.rawQuery(checkExistTable);

    if (checkExist.isNotEmpty) {
      // table exist
    } else {
      await db1.execute('CREATE TABLE $TEST_SHEMA');
    }
  }

  Future<void> deleteData() async {
    await deleteDatabase(PATH);
  }

  Future<void> createSubject() async {
    await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Subject(name, color, exampoints, examtype, lk,inactiveYears, showinlinegraph) VALUES("some name", "f0f0f0", 0, 0, 0, "", 1)');
      print('inserted1: $id1');
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

  Future<List<Data_Subject>> getSubjectsList() async {
    List<Map<dynamic, dynamic>>? res2 = await getSubjects();

    return res2?.map((e) {
          Map<String, Object> y =
              e.map((key, value) => MapEntry(key, value as Object));
          return Data_Subject.fromMap(y);
        }).toList() ??
        [];
  }
}
