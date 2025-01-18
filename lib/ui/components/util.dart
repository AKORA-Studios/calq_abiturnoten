import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:calq_abiturnoten/database/Data_Test.dart';
import 'package:flutter/material.dart';

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
      Text(sub.name)
    ],
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
            child: Text(b),
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
      Spacer(),
      IconButton(
          onPressed: () {
            onDelete();
          },
          icon: Icon(Icons.delete, color: Colors.red))
    ],
  );
}

// TODO: color test different if favorised GradeType
Widget testRow(Data_Test test, Data_Subject sub) {
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
      Text(test.name),
      Spacer(),
      Text("${test.points}")
    ],
  );
}
