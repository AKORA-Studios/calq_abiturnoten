import 'package:calq_abiturnoten/database/Data_Settings.dart';
import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:calq_abiturnoten/database/Data_Test.dart';
import 'package:calq_abiturnoten/database/Data_Type.dart';
import 'package:calq_abiturnoten/util/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pair/pair.dart';

import '../../database/database.dart';

String dateFormatter(DateTime inputDate) {
  var outputFormat = DateFormat('dd.MM.yy');
  var outputDate = outputFormat.format(inputDate);
  return outputDate; //12.12.12
}

// Final Exams
Future<Data_Subject?> getExam(int type) async {
  List<Data_Subject> subjects = await DatabaseClass.Shared.getSubjects();
  return subjects.where((element) => element.examtype == type).firstOrNull;
}

Future<List<Data_Subject>> getExamOptions() async {
  List<Data_Subject> subjects = await DatabaseClass.Shared.getSubjects();

  // set ExamPoints
  List<Data_Subject> examSubjects =
      subjects.where((element) => element.examtype != 0).toList();
  for (Data_Subject sub in examSubjects) {
    DatabaseClass.Shared.examPoints[sub.examtype - 1] = sub.exampoints;
  }

  return subjects.where((element) => element.examtype == 0).toList();
}

double calculateBlock2() {
  var value = 0;
  var arr = DatabaseClass.Shared.examPoints;

  for (var e in arr) {
    value += (4 * e);
  }

  return value / 300.0;
}

// MARK: Bock Calculations
/// Calc points block I
Future<int> generateBlockOne() async {
  List<Data_Subject> subjects = await DatabaseClass.Shared.getSubjects();
  int sum = 0;
  int count = 0;
  if (subjects.isEmpty) {
    return 0;
  }

  for (Data_Subject sub in subjects) {
    List<Data_Test> subTests = getSortedTests(
        sub, await DatabaseClass.Shared.getSubjectTests(sub),
        sortedBy: TestSortCriteria.onlyActiveTerms);
    if (subTests.isEmpty) {
      continue;
    }

    int multiplier = sub.lk ? 2 : 1;

    for (int e in [1, 2, 3, 4]) {
      List<Data_Test> tests =
          subTests.where((element) => element.year == e).toList();
      if (tests.isEmpty) {
        continue;
      }
      double average = await testAverage(tests);
      sum += multiplier * average.round();
      count += multiplier * 1;
    }
  }

  if (sum == 0) {
    return 0;
  }
  return ((sum / count) * 40).toInt();
}

/// Calc points block II
Future<int> generateBlockTwo() async {
  List<Data_Subject> subjects = await DatabaseClass.Shared.getSubjects();
  if (subjects.isEmpty) {
    return 0;
  }
  double sum = 0.0;
  Data_Settings settings = await DatabaseClass.Shared.getSettings();
  for (Data_Subject sub in subjects) {
    var multiplier = settings.hasFiveexams ? 4 : 5;
    sum += (sub.exampoints * multiplier).toDouble();
  }

  return sum.toInt();
}

/// Calc Max Points block I
Future<int> generatePossibleBlockOne() async {
  List<Data_Subject> subjects = await DatabaseClass.Shared.getSubjects();
  var sum = 0;
  var count = 0;
  if (subjects.isEmpty) {
    return 0;
  }

  for (int i = 0; i < subjects.length; i++) {
    Data_Subject sub = subjects[i];
    List<Data_Test> subTests = await DatabaseClass.Shared.getSubjectTests(sub);

    for (int e in [1, 2, 3, 4]) {
      List<Data_Test> tests =
          subTests.where((element) => element.year == e).toList();
      if (tests.isEmpty) {
        continue;
      }

      if (sub.lk) {
        sum += 2 * 15;
        count += 2;
      } else {
        sum += 15;
        count += 1;
      }
    }
  }

  if (sum == 0) {
    return 0;
  }
  return ((sum / count) * 40).round();
}

/// Returns the average of an array of tests.
Future<double> testAverage(List<Data_Test> tests) async {
  double gradeWeights = 0.0;
  List<double> avgArr = [];

  var types = await DatabaseClass.Shared.getTypes();

  for (Data_Type type in types) {
    List<Data_Test> filteredTests =
        tests.where((element) => element.type == type.assignedID).toList();
    if (filteredTests.isNotEmpty) {
      double weight = type.weigth / 100;
      gradeWeights += weight;
      double avg = average(filteredTests.map((e) => e.points).toList());
      avgArr.add(avg * weight);
    }
  }

  if (avgArr.isEmpty) {
    return 0.0;
  }
  double num = avgArr.reduce((a, b) => a + b) / gradeWeights;

  if (num.isNaN) {
    return 0.0;
  }
  return num;
}

double average(List<int> values) {
  if (values.isEmpty) {
    return 0.0;
  }

  double avg = 0.0;
  for (int i = 0; i < values.length; i++) {
    avg += values[i];
  }
  return avg / values.length;
}

double grade(double number) {
  if (number == 0.0) {
    return 0.0;
  }
  return ((17 - number.abs()) / 3.0);
}

/// Returns the average of all grades from all subjects in a specific term, -1 returns all terms
Future<double> generalAverage({int year = -1}) async {
  List<Data_Subject> allSubjects = await DatabaseClass.Shared.getSubjects();
  if (allSubjects.isEmpty) {
    return 0.0;
  }
  double count = 0.0;
  double grades = 0.0;

  for (Data_Subject sub in allSubjects) {
    List<Data_Test> allTests = await DatabaseClass.Shared.getSubjectTests(sub);
    if (allTests.isEmpty) {
      continue;
    }
    List<Data_Test> tests = allTests;
    if (year > 0) {
      tests = getSortedTests(sub, allTests,
              sortedBy: TestSortCriteria.onlyActiveTerms)
          .where((element) => element.year == year)
          .toList();
    }
    if (tests.isEmpty) {
      continue;
    }
    double multiplier = sub.lk ? 2.0 : 1.0;

    count += multiplier * 1;
    double average = await testAverage(tests);
    grades += multiplier * average.round();
  }
  if (grades == 0.0) {
    return 0.0;
  }
  return grades / count;
}

/// Returns all Tests sorted By Criteria // TODO: test if sorting works
List<Data_Test> getSortedTests(Data_Subject sub, List<Data_Test> tests,
    {TestSortCriteria sortedBy = TestSortCriteria.date}) {
  List<Data_Test> sortedTests = tests;
  switch (sortedBy) {
    case TestSortCriteria.name:
      sortedTests.sort((a, b) => a.name.compareTo(b.name));
      return sortedTests;
    case TestSortCriteria.grade:
      sortedTests.sort((a, b) => a.points.compareTo(b.points));
      return sortedTests;
    case TestSortCriteria.date:
      sortedTests.sort((a, b) => a.date.compareTo(b.date));
      return sortedTests;
    case TestSortCriteria.onlyActiveTerms:
      return sub.filterTests(sortedTests);
  }
}

// Returns <min, max> dates of all tests
Pair<int, int> getDateBounds(List<Data_Test> tests) {
  Pair<int, int> boundaries = Pair(DateTime.now().millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch);
  if (tests.isEmpty) {
    return boundaries;
  }
  tests.sort((a, b) => a.date.compareTo(b.date));
  var max = tests.first.date.millisecondsSinceEpoch -
      tests.last.date.millisecondsSinceEpoch;
  boundaries = Pair(tests.last.date.millisecondsSinceEpoch, max);
  return boundaries;
}

// Get all tests that are in this specific term
List<Data_Test> getTermTests(List<Data_Test> tests, int term) {
  return tests.where((element) => element.year == term).toList();
}

/// Returns last used term to auto select for new grades
int lastActiveYear(List<Data_Test> tests) {
  var num = 1;
  for (var i = 0; i < 5; i++) {
    var filteredTests = tests.where((element) => element.year == i);

    if (filteredTests.isNotEmpty) {
      num = i;
    }
  }
  return num;
}

// MARK: Rainbow Colors
List<Color> pastelColors = [
  "#ed8080",
  "#edaf80",
  "#edd980",
  "#caed80",
  "#90ed80",
  "#80edb8",
  "#80caed",
  "#809ded",
  "#9980ed",
  "#ca80ed",
  "#ed80e4",
  "#ed80a4"
].map((e) => fromHex(e)).toList();

Color getPastelColorByIndex(int index) {
  return pastelColors[index % (pastelColors.length - 1)];
}
