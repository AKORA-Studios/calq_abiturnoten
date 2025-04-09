import 'dart:core';

import 'package:calq_abiturnoten/database/database.dart';
import 'package:pair/pair.dart';

import '../database/Data_Subject.dart';
import '../database/Data_Test.dart';
import '../database/Data_Type.dart';

class Averages {
  static bool isStringInputInvalid(String str) {
    if (str.isEmpty) {
      return false;
    }
    RegExp regex = RegExp("[^\\/\"']+");
    if (regex.hasMatch(str)) {
      return true;
    }
    return false;
  }

// MARK: Average Functions
  static double averageInt(List<int> values) {
    if (values.isEmpty) {
      return 0.0;
    }

    double avg = 0;
    for (var i = 0; i < values.length; i++) {
      avg += values[i];
    }
    return (avg / values.length);
  }

  static double average(List<int> values, [int from = 0, int to = -1]) {
    List<int> res = [];

    /* for (final (index, item) in values.indexed) {
      if (index >= from && index <= to) {
        res.add(item);
      }
    }
    print("averages $res");*/
    return averageInt(values);
  }

  /// Returns the average of an array of tests.
// TODO: check when types
  static Future<double> testAverage(List<Data_Test> tests) async {
    if (tests.length == 1) {
      return double.parse(tests[0].points.toString());
    }
    double gradeWeights = 0.0;
    List<double> avgArr = [];

    List<Data_Type> allTypes = await DatabaseClass.Shared.getTypes();

    for (var type in allTypes) {
      List<Data_Test> filteredTests =
          tests.where((element) => element.type == type.id).toList();
      if (filteredTests.isNotEmpty) {
        double weight = (type.weigth) / 100;
        gradeWeights += weight;

        double avg = average(filteredTests.map((e) => e.points).toList());
        avgArr.add(avg * weight);
      }
    }

    if (avgArr.isEmpty || gradeWeights <= 0.0) {
      return 0.0;
    }

    var num = (avgArr.reduce((a, b) => a + b)) / gradeWeights;

    if (num < 0.0) {
      return 0.0;
    }
    return num;
  }

  /// Returns the average of all grades from one subject
  static Future<double> getSubjectAverages(Data_Subject sub) async {
    List<Data_Test> tests =
        getAllSubjectTests(sub, TestSortCriteria.onlyActiveTerm);
    if (tests.isEmpty) {
      return 0.0;
    }

    var count = 0.0;
    var subaverage = 0.0;

    for (var i = 0; i < 5; i++) {
      List<Data_Test> yearTests =
          tests.where((element) => element.year == i).toList();

      if (yearTests.isEmpty) {
        continue;
      }
      count += 1;
      subaverage += await testAverage(yearTests);
    }
    var average = (subaverage / count);
    var rounded = average.toStringAsFixed(2).padLeft(4, "0");
    return double.parse(rounded);
  }

  /// Returns the average of all grades from one subject
  static Future<double> getSubjectAverage(Data_Subject sub, int year,
      [bool filterinactve = true]) async {
    var tests = filterinactve
        ? sub.tests
        : getAllSubjectTests(sub, TestSortCriteria.onlyActiveTerm);
    tests = tests.where((element) => element.year == year).toList();

    if (tests.isEmpty) {
      return 0.0;
    }
    return await testAverage(tests);
  }

  /// Returns the average of all grades from all subjects.
  static Future<double> generalAverage() async {
    List<Data_Subject> allSubjects = await DatabaseClass.Shared.getSubjects();
    if (allSubjects.isEmpty) {
      return 0.0;
    }

    var a = 0.0;
    var subjectCount = allSubjects.length;

    for (var sub in allSubjects) {
      if (sub.tests.isEmpty) {
        subjectCount -= 1;
        continue;
      }
      List<Data_Test> tests =
          getAllSubjectTests(sub, TestSortCriteria.onlyActiveTerm);
      if (tests.isEmpty) {
        subjectCount -= 1;
        continue;
      }
      a += (await getSubjectAverages(sub)).round();
    }

    if (subjectCount == 0) {
      return 0.0;
    }
    return a / subjectCount;
  }

  /// Returns the average of all grades from all subjects in a specific halfyear
  static Future<double> generalAverageForYear(int year) async {
    final allSubjects = await DatabaseClass.Shared.getSubjects();
    if (allSubjects.isEmpty) {
      return 0.0;
    }
    double count = 0.0;
    double grades = 0.0;

    for (var sub in allSubjects) {
      if (sub.tests.isEmpty) {
        continue;
      }
      List<Data_Test> tests =
          getAllSubjectTests(sub, TestSortCriteria.onlyActiveTerm)
              .where((element) => element.year == year)
              .toList();

      if (tests.isEmpty) {
        continue;
      }
      var multiplier = sub.lk ? 2.0 : 1.0;

      count += multiplier * 1;
      grades += (multiplier * await testAverage(tests)).round();
    }

    if (grades == 0.0) {
      return 0.0;
    }
    return grades / count;
  }

  /// Converts the points(0-15) representation of a grade to the more common 1-6 scale.
  static double grade(double number) {
    if (number == 0.0) {
      return 0.0;
    }
    return ((17 - (number.abs())) / 3.0);
  }

  /// Generates a convient String that shows the grades of the subject.
  static Future<String> averageString(Data_Subject sub) async {
    String str = "";

    if (sub.tests.isEmpty) {
      return "-- -- -- -- ";
    }

    for (var i = 1; i < 5; i++) {
      List<Data_Test> arr =
          sub.tests.where((element) => element.year == i).toList();
      if (arr.isEmpty) {
        str += "-- ";
        continue;
      }
      str += int.parse((await testAverage(arr)).round().toString()).toString();
      if (i != 4) {
        str += " ";
      }
    }
    return str;
  }

  /// Generates a convenient String that shows the grades of the subject.
  static Future<List<String>> getSubjectYearString(Data_Subject subject) async {
    List<String> str = ["-", "-", "-", "-", "#"];
    var tests = subject.tests;
    if (tests.isEmpty) {
      return str;
    }

    var sum = 0.0;

    for (var i = 0; i < 4; i++) {
      var arr = tests.where((element) => element.year == i + 1).toList();
      if (arr.isEmpty) {
        continue;
      }

      if (!checkinactiveYears(subject.getinactiveYears(), i + 1)) {
        continue;
      }
      var points = int.parse((await testAverage(arr)).round().toString());

      str[i] = points.toString();
      sum += points;
    }
    str[4] = (subject.lk ? sum * 2 : sum).toString();
    return str;
  }

// MARK: Years
  /// Check if year is inactive
  static bool checkinactiveYears(List<String> arr, int num) {
    return !arr.contains(num.toString());
  }

  /// Remove  inactive term
  static void removeYear(Data_Subject sub, int num) {
    sub.removeYear(num);
    DatabaseClass.Shared.updateSubjectYear(sub); // TODO: check if works
  }

  /// Add inactive term
  static void addYear(Data_Subject sub, int num) {
    sub.addYear(num);
    DatabaseClass.Shared.updateSubjectYear(sub); // TODO: check if works
  }

  static String arrToString(List<String> arr) {
    return arr.join(" ");
  }

  static Future<bool> isPrimaryType(Data_Type type) {
    return isPrimaryTypeInt(type.id);
  }

  static Future<bool> isPrimaryTypeInt(int type) async {
    List<Data_Type> allTypes = await DatabaseClass.Shared.getTypes();
    List<int> typeIDs = allTypes.map((e) => e.id).toList();

    if (!typeIDs.contains(type)) {
      setPrimaryType(typeIDs[0]);
    }
    return type == DatabaseClass.Shared.primaryType;
  }

  static Future<void> setPrimaryType(int type) async {
    await DatabaseClass.Shared.updateSettingsPrimaryType(type);
  }

  // TODO: for whats new screen maybe
  /*
  static bool checkIfNewVersion() {
  let oldVersion = UserDefaults.standard.string(forKey: UD_lastVersion) ?? "0.0.0";
  if oldVersion == "0.0.0" { return true }
  let partsOldV = oldVersion.split(separator: ".")
  let partsNewV = appVersion.split(separator: ".")

  if partsOldV.isEmpty { return true }

  if partsOldV[0] < partsNewV[0] {
  return true
  } else if partsOldV[0] == partsNewV[0] && partsOldV[1] < partsNewV[1] {
  return true
  }
  return false
  }*/

  static bool isExamSubject(Data_Subject sub) {
    return sub.examtype != 0;
  }

  // MARK: Sorting
  static List<Pair<String, TestSortCriteria>> getSortingArray() {
    return TestSortCriteria.array;
  }

  /// Returns all Tests sorted By Criteria
  static List<Data_Test> getAllSubjectTests(Data_Subject subject,
      [TestSortCriteria sortedBy = TestSortCriteria.date]) {
    var tests = subject.tests;
    switch (sortedBy) {
      case TestSortCriteria.name:
        tests.sort((b, a) => b.name.compareTo(a.name));
        return tests;
      //return tests.sorted(by: {$0.name < $1.name})
      case TestSortCriteria.grade:
        tests.sort((b, a) => b.points.compareTo(a.points));
        return tests;
      //return tests.sorted(by: {$0.grade < $1.grade})
      case TestSortCriteria.date:
        tests.sort((b, a) => b.date.compareTo(a.date));
        return tests;
      //return tests.sorted(by: {$0.date < $1.date})
      case TestSortCriteria.onlyActiveTerm:
        return filterTests(tests, subject);
    }
  }

  /// Filters out every inactive term Grades for subject grade calculations
  static List<Data_Test> filterTests(
      List<Data_Test> tests, Data_Subject subject) {
    var filteredTests = tests;

    for (var year in [1, 2, 3, 4]) {
      if (!checkinactiveYears(subject.getinactiveYears(), year)) {
        filteredTests =
            filteredTests.where((element) => element.year != year).toList();
      }
    }
    return tests;
  }
}

enum TestSortCriteria {
  name,
  grade,
  date,
  onlyActiveTerm;

  @override
  String toString() {
    switch (this) {
      case name:
        return "sortName";
      case TestSortCriteria.grade:
        return "sortGrade";
      case TestSortCriteria.date:
        return "sortGradeDatum";
      case TestSortCriteria.onlyActiveTerm:
        return "sortHalfyears";
    }
  }

  static List<Pair<String, TestSortCriteria>> array = [
    const Pair("sortName", TestSortCriteria.name),
    const Pair("sortGrade", TestSortCriteria.grade),
    const Pair("sortGradeDatum", TestSortCriteria.date)
  ];
}
