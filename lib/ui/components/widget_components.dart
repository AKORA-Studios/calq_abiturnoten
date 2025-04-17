import 'package:calq_abiturnoten/ui/components/util.dart';
import 'package:flutter/material.dart';

import '../../database/Data_Subject.dart';
import '../../database/Data_Test.dart';
import '../../database/database.dart';

Widget settingsOption(
    String title, Color color, IconData icon, Function onTap) {
  return SizedBox(
    width: double.infinity,
    child: TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
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
          const SizedBox(width: 10),
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
      const SizedBox(width: 10),
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
              backgroundColor:
                  MaterialStateProperty.all<Color>(sub.getColor())),
          onPressed: null,
          icon: const Icon(
            Icons.ac_unit,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Text(sub.name)
      ],
    ),
  );
}

Widget subjectRowWithTerms(Data_Subject sub, String b) {
  return Row(
    children: [
      IconButton.filled(
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            backgroundColor: MaterialStateProperty.all<Color>(sub.getColor())),
        onPressed: null,
        icon: const Icon(
          Icons.ac_unit,
          color: Colors.white,
        ),
      ),
      const SizedBox(width: 10),
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
            backgroundColor: MaterialStateProperty.all<Color>(sub.getColor())),
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

Widget testRow(Data_Test test, Data_Subject sub, Function() action) {
  var isPrimaryTpe = test.type == DatabaseClass.Shared.primaryType;
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
                    color: isPrimaryTpe ? sub.getColor() : Colors.transparent,
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    border: Border.all(
                        color: sub.getColor(), width: isPrimaryTpe ? 0 : 2)),
                child: Center(child: Text("${test.points}")),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text("${test.name} [${test.type}]",
                  overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 10),
          Text(dateFormatter(test.date))
        ],
      ));
}
