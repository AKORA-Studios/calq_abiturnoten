class Data_Type {
  late int assignedID;
  late int id;
  late String name;
  late double weigth;

  Data_Type(this.id, this.assignedID, this.name, this.weigth);

  Data_Type.fromMap(Map<String, Object?> map) {
    id = int.parse(map["id"].toString());
    assignedID = int.parse(map["assignedID"].toString());
    name = map["name"].toString();
    weigth = double.parse(map["weigth"].toString());
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      "id": id,
      "name": name,
      "weigth": weigth,
      "assignedID": assignedID
    };
    return map;
  }

  @override
  String toString() {
    return 'Data_Type{id: $id, name: $name, weigth: $weigth, assignedID: $assignedID}';
  }
}
