import 'package:calq_abiturnoten/util/color_extension.dart';
import 'package:flutter/material.dart';

import '../ui/components/util.dart';
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
  late List<Data_Test> tests;

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
    tests = testList.map((e) => Data_Test.fromMap(e)).toList();
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

  /// Returns last used term to auto select for new grades
  int lastActiveYear() {
    var num = 1;
    for (var i = 0; i < 5; i++) {
      var filteredTests = tests.where((element) => element.year == i);

      if (filteredTests.isNotEmpty) {
        num = i;
      }
    }
    return num;
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

  /// Returns all Tests sorted By Criteria // TODO: test if sorting works
  List<Data_Test> getSortedTests(
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
        return filterTests(sortedTests);
    }
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

  /// Returns the average of all grades from one subject
  Future<double> getSubjectAverage() async {
    if (tests.isEmpty) {
      return 0.0;
    }

    double count = 0.0;
    double subAverage = 0.0;

    for (int e in [1, 2, 3, 4]) {
      var yearTests = tests.where((element) => element.year == e).toList();
      if (yearTests.isEmpty) {
        continue;
      }
      count += 1;
      subAverage += await testAverage(yearTests);
    }
    double average = (subAverage / count);
    //var rounded = String(format: "%.2f", average)//.padding(toLength: 4, withPad: "0", startingAt: 0)
    return double.parse(average.toStringAsFixed(2)) ?? 0.0;
  }

  @override
  String toString() {
    return 'Data_Subject{name: $name, id: $id [${tests.length}]}';
  }
}
