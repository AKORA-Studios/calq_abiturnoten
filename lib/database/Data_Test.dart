import 'package:calq_abiturnoten/util/date_formatter.dart';

class Data_Test {
  late int id;
  late String name;
  late int points;
  late int type;
  late DateTime date;
  late int year;

  Data_Test(this.id, this.name);

  Data_Test.fromMap(Map<String, Object?> map) {
    id = int.parse(map["id"].toString());
    name = map["name"].toString();
    points = int.parse(map["points"].toString());
    type = int.parse(map["type"].toString());
    date = dateFromString(map["date"].toString());
    year = int.parse(map["year"].toString());
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      "id": id,
      "name": name,
      "points": points,
      "type": type,
      "date": stringFromDate(date),
      "year": year
    };
    return map;
  }

  @override
  String toString() {
    return 'Data_Test{name: $name, id: $id type: $type points: $points year: $year}';
  }
}
