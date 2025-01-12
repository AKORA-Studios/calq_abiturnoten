import 'package:calq_abiturnoten/util/color_extension.dart';
import 'package:flutter/material.dart';

class Data_Subject {
  late int id;
  late String name;
  late Color color;
  late int exampoints;
  late int examtype;
  late bool lk;
  late String inactiveYears;
  late bool showinlinegraph;

  Data_Subject(this.id, this.name, this.color, this.exampoints, this.examtype,
      this.lk, this.inactiveYears, this.showinlinegraph);

  Data_Subject.fromMap(Map<String, Object?> map) {
    id = int.parse(map["id"].toString());
    name = map["name"].toString();
    color = fromHex(map["color"].toString()); //map["color"]
    exampoints = int.parse(map["exampoints"].toString());
    examtype = int.parse(map["examtype"].toString());
    lk = map["lk"] == 1;
    inactiveYears = map["inactiveYears"].toString();
    showinlinegraph = map["showinlinegraph"] == 1;
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

  @override
  String toString() {
    return 'Data_Subject{name: $name, id: $id}';
  }
}
