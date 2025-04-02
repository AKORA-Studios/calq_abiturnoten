import 'package:calq_abiturnoten/database/database.dart';
import 'package:calq_abiturnoten/ui/components/util.dart';
import 'package:flutter/material.dart';

import '../../database/Data_Subject.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<double> _points = [0, 0, 0, 0, 0];
  double _block1Value = 0.5;
  double _block2Value = 0.3;
  bool _shouldUpdate = false;

  List<Data_Subject> examOptions = [];

  @override
  void initState() {
    getExamOptions().then((value) {
      setState(() {
        examOptions = value;
      });
    });
  }

  void chooseExam(int year, Data_Subject sub) {
    // TODO: udpate database
    setState(() {
      examOptions =
          examOptions.where((element) => element.id != sub.id).toList();
    });
  }

  void updateBlock2Values() {
    _block2Value = 0.3;
    // TODO: update blockpoints
  }

  Widget examView(int i) {
    return FutureBuilder(
      builder: (ctx, snap) {
        if (snap.hasData) {
          // Subject set
          var sub = snap.data!;
          return Card(
              child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("${sub.name} $i [${_points[i].toInt()}]"),
                ElevatedButton(
                    onPressed: () {},
                    child: Text("X")) // TODO: remove exam subject
              ],
            ),
            Slider(
                thumbColor: sub.color,
                activeColor: sub.color, // TODO:
                min: 0,
                label: '${_points[i].round()}',
                divisions: 15,
                max: 15,
                value: _points[i],
                onChanged: (value) {
                  updateBlock2Values();
                  setState(() {
                    _points[i] = value;
                  });
                }),
          ]));
        }
        if (!snap.hasError) {
          // No error -> no subject set

          return Card(
            child: Column(children: [
              ElevatedButton(
                  onPressed: () {
                    print("Naviagte pls");
                    _showModal(i);
                  },
                  child: Text("Fach asuwählen")),
              Slider(
                //  activeColor: widget.sub.color, // TODO:
                min: 0,
                label: '${_points[i].round()}',
                divisions: 15,
                max: 15,
                value: _points[i],
                onChanged: null,
              )
            ]),
          );
        }
        return Text("Smth went wrong ${snap.error}");
      },
      future: getExam(i + 1),
    );
  }

  void _showModal(int type) {
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      //isDismissible: false,
      builder: (BuildContext context) {
        return SizedBox(
          height: 260.0,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text("Exam NR: $type"),
                ...examOptions
                    .map((e) => ElevatedButton(
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(e.name),
                          ),
                          onPressed: () {
                            DatabaseClass.Shared.updateSubjectExam(e, type + 1);

                            Navigator.pop(
                              context,
                              "This string will be passed back to the parent",
                            );
                          },
                        ))
                    .toList(),
              ],
            ),
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    print('modal closed');
    setState(() {
      _shouldUpdate = !_shouldUpdate;
    });
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
              FutureBuilder(
                builder: (ctx, snap) {
                  if (snap.hasData && snap.data!.hasFiveexams) {
                    return Column(
                      children:
                          [0, 1, 2, 3, 4].map((i) => examView(i)).toList(),
                    );
                  } else {
                    return Column(
                      children: [0, 1, 2, 3].map((i) => examView(i)).toList(),
                    );
                  }
                },
                future: DatabaseClass.Shared.getSettings(),
              )
            ],
          ),
        ));
  }
}
