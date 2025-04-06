import 'package:intl/intl.dart';

final calqDateformatter = DateFormat('yyyy-MM-dd hh:mm');

String formatDate(DateTime date) {
  var inputFormat = DateFormat('yyyy-MM-dd hh:mm:ss');
  var inputDate = inputFormat.parse(date.toString().split(".")[0]);

  var outputFormat = DateFormat('dd.MM.yyyy');
  var outputDate = outputFormat.format(inputDate);
  return outputDate;
}

DateTime dateFromString(String str) {
  if (str.isEmpty) {
    return DateTime.now();
  }
  return DateTime.parse(str);
}

String stringFromDate(DateTime date) {
  return formatDate(date);
}
