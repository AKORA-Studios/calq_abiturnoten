import 'dart:convert';
import 'dart:io';

import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:calq_abiturnoten/database/Data_Test.dart';
import 'package:calq_abiturnoten/database/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class JSONUtil {
  Future<void> loadDemoData(BuildContext context) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/json/demo_data.json");
    final jsonResult = jsonDecode(data);

    DatabaseClass.Shared.hasFiveexams = true;
    DatabaseClass.Shared.rainbowEnabled = true;

    for (dynamic sub in jsonResult) {
      String name = tryCast(sub["name"]) ?? "???";
      String color = tryCast(sub["color"]) ?? "ededed";
      bool lk = tryCast(sub["lk"]) ?? false;
      String inactiveYears = tryCast(sub["inactiveYears"]) ?? "";

      await DatabaseClass.Shared.createSubject(name, color, lk ? 1 : 0,
              inactiveYears: inactiveYears)
          .then((subID) async {
        for (dynamic test in sub["subjecttests"]) {
          String name = tryCast(test["name"]) ?? "???";
          int points = tryCast(test["grade"]) ?? 0;
          int year = tryCast(test["year"]) ?? 0;
          bool big = tryCast(test["big"]) ?? false;
          String dateString = tryCast(test["date"]) ?? "";
          int date = int.parse(dateString);

          await DatabaseClass.Shared.createTest(subID, name, points, year,
              DateTime.fromMillisecondsSinceEpoch(date * 1000), big ? 1 : 0);
        }
      });
    }
  }

  Future<void> exportJSON() async {
    var str =
        "{\"formatVersion\": 3, \"colorfulCharts\": ${DatabaseClass.Shared.rainbowEnabled}, \"hasFiveExams\": ${DatabaseClass.Shared.hasFiveexams},";
    str +=
        "\"highlightedType\": \(primaryType), \"gradeTypes\": \(getTypesJSONData()), \(getExamJSONData()) \"usersubjects\": [";
// TODO: include types+ json verison
    List<Data_Subject> subjects = await DatabaseClass.Shared.getSubjects();
    int subCount = 0;
    for (Data_Subject sub in subjects) {
      int testCount = 0;
      String testString = "";
      List<Data_Test> subTests =
          await DatabaseClass.Shared.getSubjectTests(sub);
      for (Data_Test test in subTests) {
        testCount += 1;
        str += "${test.toJSON()}${subTests.length == testCount ? "" : ","}";
      }

      str += sub.toJSON(testString);

      subCount += 1;
      str += "]} ${subjects.length == subCount ? "" : ","}";
    }

    str += "]}";

    getTemporaryDirectory().then((tempDir) {
      final File file = File('${tempDir.path}/exportedJSON.json');

      file.writeAsString(str);
      Share.shareFiles([(file.path)], text: 'Exported JSON Data');
    });
  }
}

T? tryCast<T>(dynamic x, {T? fallback}) {
  try {
    return (x as T);
  } catch (e) {
    print('CastError when trying to cast $x to $T!');
    return fallback;
  }
}
