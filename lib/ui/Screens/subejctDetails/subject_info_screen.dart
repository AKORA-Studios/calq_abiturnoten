import 'package:calq_abiturnoten/ui/Screens/subejctDetails/edit_grade_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pair/pair.dart';

import '../../../database/Data_Subject.dart';
import '../../../database/database.dart';
import '../../components/util.dart';

class SubjectInfoScreen extends StatefulWidget {
  const SubjectInfoScreen({super.key, required this.sub});

  final Data_Subject sub;

  @override
  State<SubjectInfoScreen> createState() => _SubjectInfoScreenState();
}

class _SubjectInfoScreenState extends State<SubjectInfoScreen> {
  List<String> subs = ["x", "y"]; // TODO: remove?
  int _selectedYear = 1;
  bool _shouldUpdate = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _selectedYear = widget.sub.lastActiveYear();
    });

    DatabaseClass.Shared.getSubjects().then((value) {
      setState(() {
        subs[0] = value.toString();
      });
    });
  }

  List<Widget> halfYearWidget() {
    List<Widget> result = [];
    [1, 2, 3, 4].map((e) {
      var tests =
          widget.sub.tests.where((element) => element.year == e).toList();
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
                    .map((e) => testRow(e, widget.sub, () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EditGradeScreen(test: e)));
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
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(color: Colors.red))),
                    ),
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
                spots: chartData()

                /*widget.sub.tests.asMap().forEach(
                                  (index, test) =>
                                      FlSpot(index + 0.0, test.points + 0.0))*/
                ,
                color: widget.sub.color,
                dotData: const FlDotData(show: false))
          ]),
    );
  }

  List<FlSpot> chartData() {
    Pair<int, int> subjectBounds = widget.sub.getDateBounds();

    return widget.sub.getTermTests(_selectedYear).map((test) {
      var date = (test.date.millisecondsSinceEpoch - subjectBounds.key) /
          subjectBounds.value;

      return FlSpot(date, test.points + 0.0);
    }).toList();
  }
}
