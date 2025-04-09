import 'dart:math';

import 'package:calq_abiturnoten/database/Data_Settings.dart';
import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:calq_abiturnoten/database/Data_Test.dart';
import 'package:calq_abiturnoten/database/Data_Type.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';

String dateFormatter(DateTime inputDate) {
  var outputFormat = DateFormat('dd.MM.yy');
  var outputDate = outputFormat.format(inputDate);
  return outputDate; // 12/31/2000 11:59 PM <-- MM/dd 12H format
}

Widget settingsOption(
    String title, Color color, IconData icon, Function onTap) {
  return SizedBox(
    width: double.infinity,
    child: TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size.zero, // Set this
        padding: EdgeInsets.zero, // and this
      ),
      onPressed: () {
        onTap();
      },
      child: Row(
        children: [
          IconButton.filled(
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                backgroundColor: MaterialStateProperty.all<Color>(color)),
            onPressed: null,
            icon: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          Text(title)
        ],
      ),
    ),
  );
}

Widget settingsOptionWithWidget(
    String title, Color color, IconData icon, Widget child) {
  return Row(
    children: [
      IconButton.filled(
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all<Color>(color)),
        onPressed: null,
        icon: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      Text(title),
      const Spacer(),
      child
    ],
  );
}

Widget subjectRow(Data_Subject sub) {
  return Card(
    child: Row(
      children: [
        IconButton.filled(
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              backgroundColor: MaterialStateProperty.all<Color>(sub.color)),
          onPressed: null,
          icon: const Icon(
            Icons.ac_unit,
            color: Colors.white,
          ),
        ),
        Text(sub.name)
      ],
    ),
  );
}

Widget subjectRowWithTerms(Data_Subject sub) {
  return Row(
    children: [
      IconButton.filled(
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all<Color>(sub.color)),
        onPressed: null,
        icon: const Icon(
          Icons.ac_unit,
          color: Colors.white,
        ),
      ),
      Expanded(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(sub.name),
          const SizedBox(
            width: 100,
            child: Text("1 | 2 | 3 | 4"),
          )
        ],
      ))
    ],
  );
}

Widget subjectRowWithHalfyears2(Data_Subject sub, String b) {
  return Row(
    children: [
      IconButton.filled(
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all<Color>(sub.color)),
        onPressed: null,
        icon: const Icon(
          Icons.ac_unit,
          color: Colors.white,
        ),
      ),
      Expanded(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(sub.name),
          SizedBox(
            width: 100,
            child: Text(b.replaceAll(" ", "   ")),
          )
        ],
      ))
    ],
  );
}

Widget subjectRowWith2Action(
    Data_Subject sub, Function onTap, Function onDelete) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton.filled(
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all<Color>(sub.color)),
        onPressed: () {
          onTap();
        },
        icon: const Icon(
          Icons.ac_unit,
          color: Colors.white,
        ),
      ),
      TextButton(
          onPressed: () {
            onTap();
          },
          child: Row(
            children: [
              Text(sub.name),
            ],
          )),
      const Spacer(),
      IconButton(
          onPressed: () {
            onDelete();
          },
          icon: const Icon(Icons.delete, color: Colors.red))
    ],
  );
}

// TODO: color test different if favorised GradeType
Widget testRow(Data_Test test, Data_Subject sub, Function() action) {
  bool result = Random().nextDouble() <= 0.7;

  var isPrimaryTpe = result; // TODO
  return TextButton(
      onPressed: action,
      child: Row(
        children: [
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {},
            child: SizedBox(
              width: 40.0,
              height: 40.0,
              child: Container(
                decoration: BoxDecoration(
                    color: isPrimaryTpe ? sub.color : Colors.transparent,
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    border: Border.all(
                        color: sub.color, width: isPrimaryTpe ? 0 : 2)),
                child: Center(child: Text("${test.points}")),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text("${test.name} [${test.type}]"),
          const Spacer(),
          Text(dateFormatter(test.date))
        ],
      ));
}

// Terms

Future<String> getActiveTermsGeneral() async {
  var subjects = await DatabaseClass.Shared.getSubjects();

  var inactiveCount = 0;
  if (subjects.isNotEmpty) {
    for (var sub in subjects) {
      var arr = sub.inactiveYears.split("");
      for (var num in arr) {
        if (num == "") {
          continue;
        }
        if (int.parse(num) > 0 && int.parse(num) < 5) {
          inactiveCount += 1;
        }
      }
    }
  }
  var activeCount = subjects.length * 4 - inactiveCount;

  return "$activeCount von ${subjects.length * 4} Halbjahren aktiv";
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
    List<Data_Test> subTests =
        sub.getSortedTests(sortedBy: TestSortCriteria.onlyActiveTerms);
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
        tests.where((element) => element.type == type.id).toList();
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
    if (sub.tests.isEmpty) {
      continue;
    }
    List<Data_Test> tests = sub.tests;
    if (year > 0) {
      tests = sub
          .getSortedTests(sortedBy: TestSortCriteria.onlyActiveTerms)
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
