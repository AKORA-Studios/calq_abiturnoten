import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../database/database.dart';

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

  @override
  void initState() {
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
              Center(
                  child: Container(
                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width - 20,
                      height: 150)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      color: Colors.grey,
                      width: (MediaQuery.of(context).size.width / 2) - 20,
                      height: 150),
                  Container(
                      color: Colors.grey,
                      width: (MediaQuery.of(context).size.width / 2) - 20,
                      height: 150)
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ));
  }
}
