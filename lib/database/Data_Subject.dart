import 'package:calq_abiturnoten/util/color_extension.dart';
import 'package:flutter/material.dart';

import '../util/averages.dart';
import 'Data_Test.dart';

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

  @override
  String toString() {
    return 'Data_Subject{name: $name, id: $id [${tests.length}]}';
  }
}
