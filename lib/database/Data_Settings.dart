class Data_Settings {
  late bool colorfulCharts;
  late bool hasFiveexams;
  late String weightBigGrades;
  late int primaryType;

  Data_Settings(this.colorfulCharts, this.hasFiveexams, this.weightBigGrades,
      this.primaryType);

  Data_Settings.fromMap(Map<String, Object?> map) {
    hasFiveexams = int.parse(map["hasFiveexams"].toString()) == 1;
    colorfulCharts = int.parse(map["colorfulCharts"].toString()) == 1;
    weightBigGrades = map["weightBigGrades"].toString();
    primaryType = int.parse(map["primaryType"].toString());
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      "hasFiveexams": hasFiveexams,
      "colorfulCharts": colorfulCharts,
      "weightBigGrades": weightBigGrades,
      "primaryType": primaryType
    };
    return map;
  }

  @override
  String toString() {
    return 'Data_Settings{colorfulCharts: $colorfulCharts, hasFiveexams: $hasFiveexams, weightBigGrades: $weightBigGrades}';
  }
}
