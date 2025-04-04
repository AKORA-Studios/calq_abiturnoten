import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pair/pair.dart';

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

  // Term barChart
  List<double> _termValues = [0, 0, 0, 0];

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
              const SizedBox(height: 10),
              //  Text(subs),
              card(SizedBox(
                  width: MediaQuery.of(context).size.width - 20,
                  height: 250,
                  child: overviewChart())),
              const SizedBox(height: 10),
              card(lineChart()),
              card(Center(
                  child: SizedBox(
                height: 150,
                child: termChart(),
              ))),
              const SizedBox(height: 10),
              card(circularCharts()),
              const SizedBox(height: 10),
            ],
          ),
        ));
  }

  // MARK: Subviews
  Widget overviewChart() {
    return FutureBuilder(
        future: getOverviewChartData(),
        builder: (ctx, snap) {
          if (snap.hasError) {
            return const Text("Smth went wrong :c");
          } else {
            return BarChart(BarChartData(
              maxY: 15,
              minY: 0,
              borderData: FlBorderData(show: false),
              //  groupsSpace: 10,
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  show: true,
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (snap.data == null) {
                              return const Text("?\n?");
                            }
                            return Text(
                                "${snap.data![value.toInt()].value.round()}\n${snap.data![value.toInt()].key.substring(0, 3)}",
                                style: const TextStyle(height: 1),
                                textAlign: TextAlign.center);
                          }))),
              // add bars
              barGroups: snap.data == null
                  ? []
                  : snap.data!
                      .asMap()
                      .entries
                      .map((e) => BarChartGroupData(x: e.key, barRods: [
                            BarChartRodData(
                                backDrawRodData: backgroundBar(),
                                gradient: const LinearGradient(
                                    colors: [Colors.blue, Colors.purple]),
                                toY: e.value.value,
                                width: 60,
                                color: Colors.amber,
                                borderRadius: barRadiusTerms())
                          ]))
                      .toList(),
            ));
          }
        });
  }

  Widget lineChart() {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      height: 150,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 15,
          gridData:
              const FlGridData(drawVerticalLine: false, horizontalInterval: 5),
          titlesData: const FlTitlesData(
              bottomTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      interval: 5, showTitles: true, reservedSize: 30)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false))),
          borderData: FlBorderData(show: true),
          lineBarsData: subjects
              .map((sub) => LineChartBarData(
                  spots: sub.tests.asMap().entries.map((entry) {
                    int idx = entry.key; // TODO: later replace with date

                    return FlSpot(idx + 0.0, entry.value.points + 0.0);
                  }).toList(),
                  color: sub.color,
                  dotData: const FlDotData(show: false)))
              .toList(),
        ),
      ),
    );
  }

  Widget termChart() {
    return BarChart(BarChartData(
        maxY: 15,
        minY: 0,
        borderData: FlBorderData(show: false),
        //  groupsSpace: 10,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            show: true,
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 15,
                    getTitlesWidget: (value, meta) {
                      return Text(
                          _termValues[value.toInt() - 1].round().toString(),
                          textAlign: TextAlign.center);
                    }))),
        // add bars
        barGroups: [
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(
                backDrawRodData: backgroundBar(),
                gradient:
                    const LinearGradient(colors: [Colors.blue, Colors.purple]),
                toY: _termValues[0],
                width: 60,
                color: Colors.amber,
                borderRadius: barRadiusTerms())
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(
                backDrawRodData: backgroundBar(),
                toY: _termValues[1],
                width: 60,
                color: Colors.amber,
                borderRadius: barRadiusTerms())
          ]),
          BarChartGroupData(x: 3, barRods: [
            BarChartRodData(
                backDrawRodData: backgroundBar(),
                toY: _termValues[2],
                width: 60,
                color: Colors.amber,
                borderRadius: barRadiusTerms())
          ]),
          BarChartGroupData(x: 4, barRods: [
            BarChartRodData(
                backDrawRodData: backgroundBar(),
                toY: _termValues[3],
                width: 60,
                color: Colors.amber,
                borderRadius: barRadiusTerms())
          ]),
        ]));
  }

  BackgroundBarChartRodData backgroundBar() {
    return BackgroundBarChartRodData(
        toY: 14.6, color: Colors.grey.withOpacity(0.5), show: true, fromY: 0);
  }

  BorderRadius barRadiusTerms() {
    return const BorderRadius.only(
        topRight: Radius.circular(8), topLeft: Radius.circular(8));
  }

  Widget circularCharts() {
    return FutureBuilder(
        future: updateBlocks(),
        builder: (ctx, snap) {
          if (!snap.hasError) {
            return Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [Text("Fächerschnitt"), Text("Abischnitt")],
                ),
                Row(
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
                              backgroundColor: Colors.grey.withOpacity(0.5),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Text(
                            '$_averageText\n$_gradeText',
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
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
                              backgroundColor: Colors.grey.withOpacity(0.5),
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
                )
              ],
            );
          } else {
            return Text("g${snap.error}");
          }
        });
  }

  // MARK: Functions
  Future<void> updateBlocks() async {
    double blockPoints =
        (await generateBlockOne() + await generateBlockTwo()).toDouble();
    double blockGrade = grade((blockPoints * 15 / 900));
    String gradeData = blockGrade.toStringAsFixed(2);
    double generalAverageValue = await generalAverage();
    List<double> termValues = [
      await generalAverage(year: 1),
      await generalAverage(year: 2),
      await generalAverage(year: 3),
      await generalAverage(year: 4)
    ];

    setState(() {
      _averagePercent = generalAverageValue / 15.0;
      _blockPercent = (blockPoints / 900.0);
      _averageText = generalAverageValue.toStringAsFixed(2);
      _gradeText = grade(generalAverageValue).toStringAsFixed(2);
      _blockCircleText = gradeData;
      _termValues = termValues;
    });
  }

  Future<List<Pair<String, double>>> getOverviewChartData() async {
    List<Pair<String, double>> data = [];
    var subjects = await DatabaseClass.Shared.getSubjects();

    for (Data_Subject sub in subjects) {
      //let color = getSubjectColor(sub)
      data.add(Pair(sub.name, await sub.getSubjectAverage()));
    }
    return data;
  }
}
//Circle1: _averageText + _gradeText [_averagePercent]
//Circle2: _blockCircleText [_blockPercent]
