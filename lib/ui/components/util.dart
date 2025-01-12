import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

final calqDateformatter = new DateFormat('yyyy-MM-dd hh:mm');

String formatDate(DateTime date) {
  var inputFormat = DateFormat('yy-mm-dd hh:mm:ss');
  var inputDate = inputFormat.parse(date.toString().split(".")[0]);

  var outputFormat = DateFormat('dd.MM.yyyy');
  var outputDate = outputFormat.format(inputDate);
  return outputDate;
}
