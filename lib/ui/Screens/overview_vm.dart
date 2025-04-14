import 'package:calq_abiturnoten/ui/Screens/overview_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pair/pair.dart';

import '../../database/Data_Subject.dart';
import '../../database/database.dart';
import '../../util/averages.dart';
import '../components/styling.dart';
import '../components/util.dart';

class OverViewViewModel with ChangeNotifier {
  List<LineChartBarData> _lineChartData = [];
  List<BarChartEntry> _barChartData = [];
  List<BarChartGroupData> _termChartData = [];
  List<Data_Subject> _subjects = [];

  // Circular Charts
  double _blockPercent = 0.0;
  double _averagePercent = 0.0;
  String _gradeText = "?.??";
  String _blockCircleText = "?.??";
  String _averageText = "??.?";

  // Term barChart
  List<double> _termValues = [0, 0, 0, 0];

  Future<void> updateData() async {
    _subjects = await DatabaseClass.Shared.getSubjects();

    _lineChartData = await fetchLineChartData(_subjects);
    _barChartData = await fetchOverviewChartData();
    await updateBlocks();
    _termChartData = await fetchTermChartData();

    notifyListeners();
  }

  Future<List<BarChartEntry>> fetchOverviewChartData() async {
    List<BarChartEntry> data = [];
    var subjects = await DatabaseClass.Shared.getSubjects();

    for (Data_Subject sub in subjects) {
      data.add(BarChartEntry(
          sub.name,
          await Averages.getSubjectAverageWithoutYear(sub),
          await getSubjectRainbowColor(sub)));
    }
    return data;
  }

  Future<List<BarChartGroupData>> fetchTermChartData() async {
    return [
      BarChartGroupData(x: 1, barRods: [
        BarChartRodData(
            backDrawRodData: backgroundBar(),
            toY: _termValues[0],
            width: 60,
            color: calqColor,
            borderRadius: barRadiusTerms())
      ]),
      BarChartGroupData(x: 2, barRods: [
        BarChartRodData(
            backDrawRodData: backgroundBar(),
            toY: _termValues[1],
            width: 60,
            color: calqColor,
            borderRadius: barRadiusTerms())
      ]),
      BarChartGroupData(x: 3, barRods: [
        BarChartRodData(
            backDrawRodData: backgroundBar(),
            toY: _termValues[2],
            width: 60,
            color: calqColor,
            borderRadius: barRadiusTerms())
      ]),
      BarChartGroupData(x: 4, barRods: [
        BarChartRodData(
            backDrawRodData: backgroundBar(),
            toY: _termValues[3],
            width: 60,
            color: calqColor,
            borderRadius: barRadiusTerms())
      ])
    ];
  }

  Future<List<LineChartBarData>> fetchLineChartData(
      List<Data_Subject> subjects) async {
    List<LineChartBarData> arr = [];

    for (Data_Subject sub in subjects) {
      var value = await DatabaseClass.Shared.getSubjectTests(sub);
      Pair<int, int> subjectBounds = getDateBounds(value);
      var spotData = value.map((test) {
        var date = (test.date.millisecondsSinceEpoch - subjectBounds.key) /
            subjectBounds.value;
        return FlSpot(1 - date, test.points + 0.0);
      }).toList();

      arr.add(LineChartBarData(
          spots: spotData.length < 2 ? [] : spotData,
          color: await getSubjectRainbowColor(sub),
          dotData: const FlDotData(show: false)));
    }
    return arr.length < 2 ? [] : arr;
  }

  Future<void> updateBlocks() async {
    double blockPoints =
        (await generateBlockOne() + await generateBlockTwo()).toDouble();
    double blockGrade = grade((blockPoints * 15 / 900));
    String gradeData = blockGrade.toStringAsFixed(2);
    double generalAverageValue = (await generalAverage()).roundToDouble();
    List<double> termValues = [
      await generalAverage(year: 1),
      await generalAverage(year: 2),
      await generalAverage(year: 3),
      await generalAverage(year: 4)
    ];

    _averagePercent = generalAverageValue / 15.0;
    _blockPercent = (blockPoints / 900.0);
    _averageText = generalAverageValue.toStringAsFixed(2);
    _gradeText = grade(generalAverageValue).toStringAsFixed(2);
    print(blockPoints); // TODO: 7.88 should be 7,34
    _blockCircleText = gradeData;
    _termValues = termValues;
  }

  // Chart Util
  BackgroundBarChartRodData backgroundBar() {
    return BackgroundBarChartRodData(
        toY: 14.6, color: Colors.grey.withOpacity(0.3), show: true, fromY: 0);
  }

  BorderRadius barRadiusTerms() {
    return const BorderRadius.only(
        topRight: Radius.circular(8), topLeft: Radius.circular(8));
  }

  // TODO: test different sizes
  double barWidth(int length) {
    if (length > 10) {
      return 20;
    }
    return 60;
  }

// Getter
  List<LineChartBarData> get lineChartData => _lineChartData;

  List<BarChartEntry> get barChartData => _barChartData;

  List<double> get termValues => _termValues;

  String get averageText => _averageText;

  String get blockCircleText => _blockCircleText;

  String get gradeText => _gradeText;

  double get averagePercent => _averagePercent;

  double get blockPercent => _blockPercent;

  List<BarChartGroupData> get termChartData => _termChartData;
}
