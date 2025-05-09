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
    String str = "{\"formatVersion\": 0, \"usersubjects\": $data}";
    importJSON(str);
  }

  Future<void> loadFromPath(BuildContext context, String path) async {
    String data = await DefaultAssetBundle.of(context).loadString(path);
    importJSON(data);
  }

  Future<void> exportJSON() async {
    var str =
        "{\"formatVersion\": 3, \"colorfulCharts\": ${DatabaseClass.Shared.rainbowEnabled}, \"hasFiveExams\": ${DatabaseClass.Shared.hasFiveexams},";
    str +=
        "\"highlightedType\": (primaryType), \"gradeTypes\": (getTypesJSONData()), (getExamJSONData()) \"usersubjects\": [";
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

  // MARK: Import JSON
  /// Import Version 3 JSON files - with Types
  void importJSON(String data, {bool shouldAddData = true}) async {
    Map<String, dynamic> jsonResult = jsonDecode(data);
    int version = 0;

    if (jsonResult.containsKey("formatVersion")) {
      version = tryCast(jsonResult["formatVersion"]) ?? 0;
    }
    if (version >= 3) {
      importJSONV3(jsonResult, shouldAddData: shouldAddData);
    }
    // Version 1& 2 not supported
    else {
      importJSONV0(jsonResult);
    }
  }

  void importJSONV3(dynamic jsonResult, {bool shouldAddData = true}) async {
    final Map<String, dynamic> data = jsonResult as Map<String, dynamic>;
    JSONV3 userSubjectsResponse = JSONV3.fromJson(data);

    if (!shouldAddData) {
      return;
    }
    DatabaseClass.Shared.hasFiveexams = userSubjectsResponse.hasFiveExams;
    DatabaseClass.Shared.rainbowEnabled = userSubjectsResponse.colorfulCharts;
    DatabaseClass.Shared.primaryType = userSubjectsResponse.highlightedType;

    // types
    List<int> ids = [];
    int i = 0;
    double typeWeights = 0.0;

    for (JSONV3Types type in userSubjectsResponse.gradeTypes) {
      int id = i;
      double weight = type.weight;
      i += 1;

      if (weight < 0.0) {
        weight = 0.0;
      }
      if (weight + typeWeights >= 100.0) {
        weight = 0.0;
      }
      typeWeights += weight;

      await DatabaseClass.Shared.createType(type.name, weight, id);
      ids.add(id);
    }

    int fallbackID = ids.isEmpty ? 0 : ids.last;
    for (JSONV3Subs sub in userSubjectsResponse.usersubjects) {
      await DatabaseClass.Shared.createSubject(
              sub.name, sub.color, sub.lk ? 1 : 0,
              inactiveYears: sub.inactiveYears)
          .then((subID) async {
        for (JSONV3Tests test in sub.subjecttests) {
          await DatabaseClass.Shared.createTest(
              subID,
              test.name,
              test.grade,
              test.year,
              DateTime.fromMillisecondsSinceEpoch(
                  (double.parse(test.date)).round() * 1000),
              !ids.contains(test.type) ? fallbackID : test.type);
        }
      });
    }
  }

  /// Import default JSON File - just Subjects
  void importJSONV0(dynamic jsonResult) async {
    JSONV0 data = JSONV0.fromJson(jsonResult);

    DatabaseClass.Shared.hasFiveexams = true;
    DatabaseClass.Shared.rainbowEnabled = true;

    for (JSONV0Subs sub in data.usersubjects) {
      await DatabaseClass.Shared.createSubject(
              sub.name, sub.color, sub.lk ? 1 : 0,
              inactiveYears: sub.inactiveYears)
          .then((subID) async {
        for (JSONV0Tests test in sub.subjecttests) {
          await DatabaseClass.Shared.createTest(
              subID,
              test.name,
              test.grade,
              test.year,
              DateTime.fromMillisecondsSinceEpoch(int.parse(test.date) * 1000),
              test.type);
        }
      });
    }
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

// Data Classes
class JSONV3 {
  final int formatVersion;
  final bool colorfulCharts;
  final bool hasFiveExams;
  final int highlightedType;
  final List<JSONV3Types> gradeTypes;
  final List<JSONV3Subs> usersubjects;

  const JSONV3({
    required this.formatVersion,
    required this.colorfulCharts,
    required this.hasFiveExams,
    required this.highlightedType,
    required this.gradeTypes,
    required this.usersubjects,
  });

  factory JSONV3.fromJson(Map<String, dynamic> json) {
    var userSubjectsFromJson = json['usersubjects'] as List;
    List<JSONV3Subs> userSubjectsList =
        userSubjectsFromJson.map((i) => JSONV3Subs.fromJson(i)).toList();

    var userTypesFromJson = json['gradeTypes'] as List;
    List<JSONV3Types> userTypesList =
        userTypesFromJson.map((i) => JSONV3Types.fromJson(i)).toList();

    return JSONV3(
        formatVersion: json['formatVersion'] as int,
        colorfulCharts: json['colorfulCharts'] as bool,
        hasFiveExams: json['hasFiveExams'] as bool,
        highlightedType: json['highlightedType'] as int,
        gradeTypes: userTypesList,
        usersubjects: userSubjectsList);
  }
}

class JSONV3Types {
  final String name;
  final int id;
  final double weight;

  const JSONV3Types(
      {required this.name, required this.id, required this.weight, r});

  factory JSONV3Types.fromJson(Map<String, dynamic> json) {
    return JSONV3Types(
        name: json['name'] as String,
        id: json['id'] as int,
        weight: json['weight'] as double);
  }
}

class JSONV3Subs {
  final String name;
  final bool lk;
  final String color;
  final String inactiveYears;
  final List<JSONV3Tests> subjecttests;

  const JSONV3Subs(
      {required this.name,
      required this.lk,
      required this.color,
      required this.inactiveYears,
      required this.subjecttests});

  factory JSONV3Subs.fromJson(Map<String, dynamic> json) {
    var userTestsFromJson = json['subjecttests'] as List;
    List<JSONV3Tests> userTestList =
        userTestsFromJson.map((i) => JSONV3Tests.fromJson(i)).toList();

    return JSONV3Subs(
        name: json['name'] as String,
        lk: json['lk'] as bool,
        color: json['color'] as String,
        inactiveYears: json['inactiveYears'] as String,
        subjecttests: userTestList);
  }
}

class JSONV3Tests {
  final String name;
  final int year;
  final int grade;
  final String date;
  final int type;

  const JSONV3Tests(
      {required this.name,
      required this.year,
      required this.grade,
      required this.date,
      required this.type});

  factory JSONV3Tests.fromJson(Map<String, dynamic> json) {
    return JSONV3Tests(
        name: json['name'] as String,
        year: json['year'] as int,
        grade: json['grade'] as int,
        date: json['date'] as String,
        type: json['type'] as int);
  }
}

class JSONV0 {
  final int formatVersion;
  final List<JSONV0Subs> usersubjects;

  const JSONV0({
    required this.formatVersion,
    required this.usersubjects,
  });

  factory JSONV0.fromJson(Map<String, dynamic> json) {
    var userSubjectsFromJson = json['usersubjects'] as List;
    List<JSONV0Subs> userSubjectsList =
        userSubjectsFromJson.map((i) => JSONV0Subs.fromJson(i)).toList();

    return JSONV0(
        formatVersion: json['formatVersion'] as int,
        usersubjects: userSubjectsList);
  }
}

class JSONV0Subs {
  final String name;
  final bool lk;
  final String color;
  final String inactiveYears;
  final List<JSONV0Tests> subjecttests;

  const JSONV0Subs(
      {required this.name,
      required this.lk,
      required this.color,
      required this.inactiveYears,
      required this.subjecttests});

  factory JSONV0Subs.fromJson(Map<String, dynamic> json) {
    var userTestsFromJson = json['subjecttests'] as List;
    List<JSONV0Tests> userTestList =
        userTestsFromJson.map((i) => JSONV0Tests.fromJson(i)).toList();

    return JSONV0Subs(
        name: json['name'] as String,
        lk: json['lk'] as bool,
        color: json['color'] as String,
        inactiveYears: json['inactiveYears'] as String,
        subjecttests: userTestList);
  }
}

class JSONV0Tests {
  final String name;
  final int year;
  final int grade;
  final String date;
  final int type;

  const JSONV0Tests(
      {required this.name,
      required this.year,
      required this.grade,
      required this.date,
      required this.type});

  factory JSONV0Tests.fromJson(Map<String, dynamic> json) {
    return JSONV0Tests(
        name: json['name'] as String,
        year: json['year'] as int,
        grade: json['grade'] as int,
        date: json['date'] as String,
        type: (json['big'] as bool) ? 1 : 0);
  }
}
