class Data_Test {
  late int id;
  late String name;

  Data_Test(this.id, this.name);

  Data_Test.fromMap(Map<String, Object?> map) {
    id = int.parse(map["id"].toString());
    name = map["name"].toString();
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      "id": id,
      "name": name,
    };
    return map;
  }

  @override
  String toString() {
    return 'Data_Test{name: $name, id: $id}';
  }
}
