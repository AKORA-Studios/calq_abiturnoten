import 'package:calq_abiturnoten/database/database.dart';
import 'package:calq_abiturnoten/ui/Screens/subejctDetails/edit_grade_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pair/pair.dart';

import '../../../database/Data_Subject.dart';
import '../../../database/Data_Test.dart';
import '../../components/styling.dart';
import '../../components/util.dart';

class SubjectInfoScreen extends StatefulWidget {
  const SubjectInfoScreen({super.key, required this.sub});

  final Data_Subject sub;

  @override
  State<SubjectInfoScreen> createState() => _SubjectInfoScreenState();
}

class _SubjectInfoScreenState extends State<SubjectInfoScreen> {
  int _selectedYear = 1;
  bool _shouldUpdate = false;
  List<Data_Test> _tests = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      _selectedYear = widget.sub.lastActiveYear();
    });

    DatabaseClass.Shared.getSubjectTests(widget.sub).then((value) {
      setState(() {
        _tests = value;
      });
    });
  }

  List<Widget> halfYearWidget() {
    List<Widget> result = [];
    [1, 2, 3, 4].map((e) {
      var tests = _tests.where((element) => element.year == e).toList();
      if (tests.isEmpty) {
        return;
      }
      result.add(Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(children: [
                Text("$e. Halbjahr"),
                const Divider(),
                ...tests
                    .map((e) => testRow(e, widget.sub, () async {
                          Data_Test t = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditGradeScreen(
                                        test: e,
                                        color: widget.sub.color,
                                        callbackFunc: () async {
                                          var x = await DatabaseClass.Shared
                                              .getSubjectTests(widget.sub);
                                          setState(() {
                                            _tests = x;
                                            _shouldUpdate = !_shouldUpdate;
                                          });
                                        },
                                      )));
                        }))
                    .toList()
              ]))));
    }).toList();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.sub.name),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text("${widget.sub.tests.length} Tests"),
                card(Column(
                  children: [
                    const Text("Notenverlauf"),
                    SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: lineChart(),
                    ),
                  ],
                )),
                Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    // Define how the card's content should be clipped
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${_selectedYear.toString()}. Halbjahr"),
                            Text(widget.sub.inactiveYears
                                    .contains(_selectedYear.toString())
                                ? "No"
                                : "Aktiv")
                          ],
                        ),
                        SegmentedButton<int>(
                          showSelectedIcon: false,
                          segments: [1, 2, 3, 4]
                              .map((e) => ButtonSegment<int>(
                                    value: e,
                                    label: Text('$e',
                                        style: TextStyle(
                                            decoration: _selectedYear == e
                                                ? TextDecoration.underline
                                                : TextDecoration.none)),
                                  ))
                              .toList(),
                          selected: <int>{_selectedYear},
                          onSelectionChanged: (Set<int> newSelection) {
                            setState(() {
                              _selectedYear = newSelection.first;
                            });
                          },
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              await widget.sub.toggleTerm(_selectedYear);
                              setState(() {
                                _shouldUpdate = !_shouldUpdate;
                              });
                            },
                            child: Text(
                                "Halbjahr ${widget.sub.isTermInactive(_selectedYear) ? "aktivieren" : "deaktivieren"}"))
                      ],
                    )),
                ...halfYearWidget(),
                TextButton(
                    style: destructiveButton(),
                    onPressed: () {
                      print("TODO: delete all grades");
                    },
                    child: const Text("Alle Noten löschen")),
              ],
            ),
          ),
        ));
  }

  Widget lineChart() {
    return LineChart(
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
          lineBarsData: [
            LineChartBarData(
                spots: chartData(),
                color: widget.sub.color,
                dotData: const FlDotData(show: false))
          ]),
    );
  }

  List<FlSpot> chartData() {
    Pair<int, int> subjectBounds = widget.sub.getDateBounds();

    return _tests.where((element) => element.year == _selectedYear).map((test) {
      var date = (test.date.millisecondsSinceEpoch - subjectBounds.key) /
          subjectBounds.value;

      return FlSpot(date, test.points + 0.0);
    }).toList();
  }
}
