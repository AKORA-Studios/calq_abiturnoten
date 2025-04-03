import 'dart:math';

import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:calq_abiturnoten/database/Data_Test.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';

String dateFormater(DateTime inputDate) {
  //var inputFormat = DateFormat('yyyy-MM-dd hh:mm:ss a');
  //var inputDate = inputFormat.parse('31/12/2000 23:59'); // <-- dd/MM 24H format

  var outputFormat = DateFormat('dd.MM.yy');
  var outputDate = outputFormat.format(inputDate);
  return outputDate; // 12/31/2000 11:59 PM <-- MM/dd 12H format
}

Widget card(Widget content) {
  return Container(
    decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: const BorderRadius.all(Radius.circular(8))),
    child: SizedBox(
      width: double.infinity,
      child: Padding(padding: const EdgeInsets.all(5), child: content),
    ),
  );
}

Widget settingsOption(
    String title, Color color, IconData icon, Function onTap) {
  // TODO: realize on tap
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
      Text(title)
    ],
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

Widget subjectRowWithHalfyears(Data_Subject sub) {
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
Widget testRow(Data_Test test, Data_Subject sub) {
  bool result = Random().nextDouble() <= 0.7;

  var isPrimaryTpe = result; // TODO
  return TextButton(
      onPressed: () {
        print("TODO go to edit grade");
      },
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
          Text(test.name),
          const Spacer(),
          Text(dateFormater(test.date))
        ],
      ));
}

// Terms

Future<String> getActiveTermsGeneral() async {
  var subjects = await DatabaseClass.Shared.getSubjects();

  var inactiveCount = 0;
  if (subjects.isNotEmpty) {
    for (var sub in subjects) {
      var arr = getinactiveYears(sub);
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

List<String> getinactiveYears(Data_Subject sub) {
  List<String> result = [];
  if (sub.inactiveYears.isEmpty) {
    return result;
  }
  result = sub.inactiveYears.split(" ");
  return result;
}

// Final Exams
Future<Data_Subject?> getExam(int type) async {
  List<Data_Subject> subjects = await DatabaseClass.Shared.getSubjects();
  return subjects.where((element) => element.examtype == type).firstOrNull;
}

Future<List<Data_Subject>> getExamOptions() async {
  List<Data_Subject> subjects = await DatabaseClass.Shared.getSubjects();
  return subjects.where((element) => element.examtype == 0).toList();
}

Future<double> calculateBlock2() async {
  return 0.0;
}
