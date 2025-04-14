import 'package:calq_abiturnoten/database/database.dart';
import 'package:calq_abiturnoten/util/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../util/averages.dart';
import 'Data_Test.dart';

enum TestSortCriteria { name, grade, date, onlyActiveTerms }

class Data_Subject {
  late int id;
  late String name;
  late Color color;
  late int exampoints;
  late int examtype;
  late bool lk;
  late String inactiveYears;
  late bool showinlinegraph;
  // late List<Data_Test> tests;

  Data_Subject(this.id, this.name, this.color, this.exampoints, this.examtype,
      this.lk, this.inactiveYears, this.showinlinegraph);

  Data_Subject.fromMap(
      Map<String, Object?> map, List<Map<String, Object?>> testList) {
    id = int.parse(map["id"].toString());
    name = map["name"].toString();
    color = fromHex(map["color"].toString()); //map["color"]
    exampoints = int.parse(map["exampoints"].toString());
    examtype = int.parse(map["examtype"].toString());
    lk = map["lk"] == 1;
    inactiveYears = map["inactiveYears"].toString();
    showinlinegraph = map["showinlinegraph"] == 1;
    //   tests = testList.map((e) => Data_Test.fromMap(e)).toList();
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      "id": id,
      "name": name,
      "color": toHex(color),
      "exampoints": exampoints,
      "examtype": examtype,
      "lk": lk == true ? 1 : 0,
      "inactiveYears": inactiveYears,
      "showinlinegraph": showinlinegraph == true ? 1 : 0
    };
    return map;
  }

  List<dynamic> toMapUpdate() {
    return [
      toHex(color),
      exampoints,
      examtype,
      lk ? 1 : 0,
      inactiveYears,
      name,
      showinlinegraph ? 1 : 0,
      id
    ];
  }

  List<String> getinactiveYears() {
    if (inactiveYears.isEmpty) {
      return [];
    }
    return inactiveYears.split(" ");
  }

  void removeYear(int num) {
    inactiveYears = Averages.arrToString(getinactiveYears()
        .where((element) => element != num.toString())
        .toList());
  }

  void addYear(int num) {
    if (inactiveYears.contains(num.toString())) {
      return;
    }
    List<String> years = getinactiveYears();
    years.add(num.toString());
    inactiveYears = Averages.arrToString(years);
  }

  List<String> getInactiveTerms() {
    if (inactiveYears.isEmpty) {
      return [];
    }
    return inactiveYears.split(" ");
  }

  /// Check if year is inactive
  bool checkInactiveTerm(int term) {
    return !getInactiveTerms().contains(term.toString());
  }

  List<Data_Test> filterTests(List<Data_Test> tests) {
    var filteredTests = tests;

    for (int year in [1, 2, 3, 4]) {
      if (!checkInactiveTerm(year)) {
        filteredTests =
            filteredTests.where((element) => element.year != year).toList();
      }
    }
    return tests;
  }

  /// Activate Terms
  bool isTermInactive(int term) {
    return inactiveYears.contains(term.toString());
  }

  Future<void> toggleTerm(int term) async {
    if (isTermInactive(term)) {
      await activateTerm(term);
    } else {
      await deactivateTerm(term);
    }
  }

  Future<void> deactivateTerm(int term) async {
    inactiveYears = inactiveYears + term.toString();
    await DatabaseClass.Shared.updateSubject(this);
  }

  Future<void> activateTerm(int term) async {
    inactiveYears = inactiveYears.replaceAll(term.toString(), "");
    await DatabaseClass.Shared.updateSubject(this);
  }

  // UTIL
  String toJSON(String jsonTests) {
    return "{\"name\": \"$name\", \"color\": \"${color.toHexString}\",\"inactiveYears\": \"$inactiveYears\",  \"lk\": $lk, \"subjecttests\": $jsonTests}";
  }

  @override
  String toString() {
    return 'Data_Subject{name: $name, id: $id }';
  }
}
