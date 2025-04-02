import 'package:flutter/material.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<double> _points = [0, 0, 0, 0, 0];
  double _block1Value = 0.5;
  double _block2Value = 0.3;

  Widget examView(int i) {
    return Column(children: [
      Text("Exam $i [${_points[i].toInt()}]"),
      Slider(
        //  activeColor: widget.sub.color, // TODO:
        min: 0,
        label: '${_points[i].round()}',
        divisions: 15,
        max: 15,
        value: _points[i],
        onChanged: (value) {
          setState(() {
            _points[i] = value;
          });
        },
      )
    ]);
  }

  Widget blockView() {
    return Card(
        child: Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text("Block 1"),
                flex: 2,
              ),
              Expanded(
                child: Text("Block 2"),
                flex: 1,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.green),
                  value: _block1Value,
                ),
              ),
              Expanded(
                flex: 1,
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.green),
                  value: _block2Value,
                ),
              ),
            ],
          ),
          const Row(
            children: [
              //    LinearProgressIndicator(),
              Expanded(
                child: Text("? von 600"),
                flex: 2,
              ),
              Expanded(
                child: Text("? von 300"),
                flex: 1,
              ),
            ],
          )
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Prüfungen"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: blockView(),
              ),
              ...[0, 1, 2, 3, 4].map((i) => examView(i)).toList()
            ],
          ),
        ));
  }
}
