import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../database/database.dart';
import '../components/util.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  String subs = "xx";
  List<Data_Subject> subjects = [];
  late List<String> xAxisList;
  late List<double> yAxisList;

  // Circular Charts
  double _blockPercent = 0.0;
  double _averagePercent = 0.0;
  String _gradeText = "?.??";
  String _blockCircleText = "?.??";
  String _averageText = "??.?";

  @override
  void initState() {
    super.initState();
    updateBlocks();

    DatabaseClass.Shared.getSubjects().then((value) {
      setState(() {
        subjects = value;
        subs = value.toString().replaceAll("Data_Subject", "\nData_Subject");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Overview"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              //  Text(subs),
              Center(
                  child: Container(
                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width - 20,
                      height: 250)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                height: 150,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 15,
                    gridData: const FlGridData(
                        drawVerticalLine: false, horizontalInterval: 5),
                    titlesData: const FlTitlesData(
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                interval: 5,
                                showTitles: true,
                                reservedSize: 30)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false))),
                    borderData: FlBorderData(show: true),
                    lineBarsData: subjects
                        .map((sub) => LineChartBarData(
                            spots: sub.tests.asMap().entries.map((entry) {
                              int idx =
                                  entry.key; // TODO: later replace with date

                              return FlSpot(
                                  idx + 0.0, entry.value.points + 0.0);
                            }).toList(),
                            color: sub.color,
                            dotData: const FlDotData(show: false)))
                        .toList(),
                  ),
                ),
              ),

              Center(
                  child: Container(
                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width - 20,
                      height: 150)),
              const SizedBox(height: 20),
              circularCharts(),
              const SizedBox(height: 20),
            ],
          ),
        ));
  }

  Widget circularCharts() {
    return FutureBuilder(
        future: updateBlocks(),
        builder: (ctx, snap) {
          if (!snap.hasError) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.square(
                        dimension: 112,
                        child: CircularProgressIndicator(
                          value: _averagePercent,
                          color: Colors.green,
                          strokeWidth: 20.0,
                          backgroundColor: Colors.grey,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '$_averageText\n$_gradeText',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.square(
                        dimension: 112,
                        child: CircularProgressIndicator(
                          value: _blockPercent,
                          color: Colors.green,
                          strokeWidth: 20.0,
                          backgroundColor: Colors.grey,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '$_blockCircleText\nØ',
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          } else {
            return Text("g${snap.error}");
          }
        });
  }

  Future<void> updateBlocks() async {
    double blockPoints =
        (await generateBlockOne() + await generateBlockTwo()).toDouble();
    double blockGrade = grade((blockPoints * 15 / 900));
    String gradeData = blockGrade.toStringAsFixed(2);
    double generalAverageValue = await generalAverage();

    setState(() {
      _averagePercent = generalAverageValue / 15.0;
      _blockPercent = (blockPoints / 900.0);
      _averageText = generalAverageValue.toStringAsFixed(2);
      _gradeText = grade(generalAverageValue).toStringAsFixed(2);
      _blockCircleText = gradeData;
    });
  }
}
//Circle1: _averageText + _gradeText [_averagePercent]
//Circle2: _blockCircleText [_blockPercent]
