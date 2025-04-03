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
  final List<double> _points = [0, 0, 0, 0, 0];
  final double _block1Value = 0.5;
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

  void chooseExam(Data_Subject sub) {
    setState(() {
      examOptions =
          examOptions.where((element) => element.id != sub.id).toList();
    });
  }

  void updateBlock2Values() {
    _block2Value = 0.3;
    // TODO: update blockpoints
  }

  void removeExam(Data_Subject sub, int i) async {
    await DatabaseClass.Shared.removeExam(i + 1);
    setState(() {
      _shouldUpdate = !_shouldUpdate;
      examOptions.add(sub);
    });
  }

  void updateSlider(int value, Data_Subject sub) async {
    // TODO: save points

    await DatabaseClass.Shared.updateExamPoints(value, sub);
    updateBlock2Values();
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
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    onPressed: () async {
                      removeExam(sub, i);
                    },
                    child: const Text("X"))
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
                    _showModal(i);
                  },
                  child: const Text("Fach asuwählen")),
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
              child: SingleChildScrollView(
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
                                DatabaseClass.Shared.updateSubjectExam(
                                    e, type + 1);
                                chooseExam(e);

                                Navigator.pop(
                                  context,
                                  "This string will be passed back to the parent",
                                );
                              },
                            ))
                        .toList(),
                  ],
                ),
              )),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    setState(() {
      _shouldUpdate = !_shouldUpdate;
    });
  }

  Widget blockView() {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text("Block 1"),
              ),
              Expanded(
                flex: 1,
                child: Text("Block 2"),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: LinearProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                  value: _block1Value,
                ),
              ),
              Expanded(
                flex: 1,
                child: LinearProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                  value: _block2Value,
                ),
              ),
            ],
          ),
          const Row(
            children: [
              //    LinearProgressIndicator(),
              Expanded(
                flex: 2,
                child: Text("? von 600"),
              ),
              Expanded(
                flex: 1,
                child: Text("? von 300"),
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
                padding: const EdgeInsets.all(8),
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
