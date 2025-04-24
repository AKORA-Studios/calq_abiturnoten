import 'package:calq_abiturnoten/ui/Screens/overview_vm.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../components/styling.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final OverViewViewModel _viewModel = OverViewViewModel();
  bool _shouldUpdate = false;

  @override
  void initState() {
    super.initState();

    _viewModel.updateData().then((value) {
      setState(() {
        _shouldUpdate = !_shouldUpdate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Overview"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              card(SizedBox(height: 250, child: overviewChart())),
              const SizedBox(height: 10),
              card(Column(children: [
                SizedBox(
                    height: 20,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Notenverlauf"),
                          IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _showModal();
                              },
                              icon: const Icon(Icons.settings))
                        ])),
                lineChart()
              ])),
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

  // LineChart Settings
  void _showModal() {
    Future<void> future = showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
              height: 260.0,
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                      child: Column(children: [
                    const Text("LineChart Settings"),
                    ..._viewModel.subjects
                        .map((e) => SizedBox(
                              width: double.infinity,
                              child: Row(children: [
                                Checkbox(
                                    checkColor: Colors.black,
                                    activeColor: e.getColor(),
                                    value: e.showinlinegraph,
                                    onChanged: (val) {
                                      _viewModel
                                          .updateLineChart(e)
                                          .then((value) {
                                        Navigator.pop(
                                          context,
                                        );
                                      });
                                    }),
                                Text(e.name)
                              ]),
                            ))
                        .toList(),
                  ]))));
        });
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    setState(() {
      _shouldUpdate = !_shouldUpdate;
    });
  }

  // MARK: Subviews
  Widget overviewChart() {
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
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    String name = _viewModel.barChartData[value.toInt()].name;

                    return Text(
                        "${_viewModel.barChartData[value.toInt()].value.round()}\n${name.length > 3 ? name.substring(0, 3) : name}",
                        style: const TextStyle(height: 1),
                        textAlign: TextAlign.center);
                  }))),
      // add bars
      barGroups: _viewModel.barChartData
          .asMap()
          .entries
          .map((e) => BarChartGroupData(x: e.key, barRods: [
                BarChartRodData(
                    backDrawRodData: _viewModel.backgroundBar(),
                    // gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
                    toY: e.value.value,
                    width: _viewModel.barWidth(_viewModel.barChartData.length),
                    color: e.value.color,
                    borderRadius: _viewModel.barRadiusTerms())
              ]))
          .toList(),
    ));
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
              gridData: const FlGridData(
                  drawVerticalLine: false, horizontalInterval: 5),
              titlesData: const FlTitlesData(
                  bottomTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          interval: 5, showTitles: true, reservedSize: 30)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false))),
              borderData: FlBorderData(show: true),
              lineBarsData: _viewModel.lineChartData),
        ));
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
                          _viewModel.termValues[value.toInt() - 1]
                              .round()
                              .toString(),
                          textAlign: TextAlign.center);
                    }))),
        // add bars
        barGroups: _viewModel.termChartData));
  }

  Widget circularCharts() {
    return Column(
      children: [
        const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [Text("Fächerschnitt"), Text("Abischnitt")]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                flex: 1,
                child: SizedBox(
                    height: 150,
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox.square(
                        dimension: 112,
                        child: CircularProgressIndicator(
                          value: _viewModel.averagePercent,
                          color: calqColor,
                          strokeWidth: 20.0,
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                          '${_viewModel.averageText}\n ${_viewModel.gradeText}',
                          style: const TextStyle(
                            fontSize: 20.0,
                          ))
                    ]))),
            Expanded(
                flex: 1,
                child: SizedBox(
                    height: 150,
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox.square(
                          dimension: 112,
                          child: CircularProgressIndicator(
                              value: _viewModel.blockPercent,
                              color: calqColor,
                              strokeWidth: 20.0,
                              backgroundColor: Colors.grey.withOpacity(0.3),
                              strokeCap: StrokeCap.round)),
                      Text('${_viewModel.blockCircleText}\n  Ø ',
                          style: const TextStyle(fontSize: 18.0)),
                    ])))
          ],
        )
      ],
    );
  }
}

class BarChartEntry {
  String name = "???";
  double value = 0.0;
  Color color = calqColor;

  BarChartEntry(this.name, this.value, this.color);
}
//Circle1: _averageText + _gradeText [_averagePercent]
//Circle2: _blockCircleText [_blockPercent]
