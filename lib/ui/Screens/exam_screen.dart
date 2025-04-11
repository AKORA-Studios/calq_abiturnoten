import 'package:calq_abiturnoten/database/database.dart';
import 'package:calq_abiturnoten/ui/components/styling.dart';
import 'package:calq_abiturnoten/ui/components/util.dart';
import 'package:flutter/material.dart';

import '../../database/Data_Subject.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  double _block1Value = 0.0;
  double _block2Value = 0.0;
  int _maxBlock1Value = 600;
  bool _shouldUpdate = false;

  List<Data_Subject> _examOptions = [];

  @override
  void initState() {
    super.initState();
    getExamOptions().then((value) {
      setState(() {
        _examOptions = value;
      });
    });
    updateBlock2Values();
    updateBlock1Values();
  }

  void chooseExam(Data_Subject sub) {
    setState(() {
      _examOptions =
          _examOptions.where((element) => element.id != sub.id).toList();
    });
  }

  void updateBlock2Values() {
    setState(() {
      _block2Value = calculateBlock2();
    });
  }

  void updateBlock1Values() {
    generatePossibleBlockOne().then((value) {
      setState(() {
        _maxBlock1Value = value;
      });
    });

    generateBlockOne().then((value) {
      var newValue = (value / _maxBlock1Value);
      if (newValue.isNaN || newValue.isFinite) {
        return;
      }

      setState(() {
        _block1Value = newValue;
      });
    });
  }

  void removeExam(Data_Subject sub, int i) async {
    await DatabaseClass.Shared.removeExam(i + 1);
    setState(() {
      _shouldUpdate = !_shouldUpdate;
      _examOptions.add(sub);
    });
    updateBlock2Values();
  }

  void updateSlider(double value, Data_Subject sub) async {
    await DatabaseClass.Shared.updateExamPoints(value.round(), sub);
    updateBlock2Values();
  }

  Widget examView(int i) {
    return FutureBuilder(
      builder: (ctx, snap) {
        if (snap.hasData) {
          // Subject set
          var sub = snap.data!;
          // updateBlock1Values(); // update them regularly
          return Card(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sub.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                            onPressed: () async {
                              removeExam(sub, i);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(sub.exampoints.toString()),
                          ),
                        ),
                        Expanded(
                          flex: 19,
                          child: Slider(
                              thumbColor: sub.color,
                              activeColor: sub.color,
                              min: 0,
                              label: '${sub.exampoints}',
                              divisions: 15,
                              max: 15,
                              value: sub.exampoints + 0.0,
                              onChangeEnd: (value) {
                                updateSlider(value, sub);
                                setState(() {
                                  _shouldUpdate = !_shouldUpdate;
                                });
                              },
                              onChanged: (value) {}),
                        )
                      ],
                    ),
                  ])));
        }
        if (!snap.hasError) {
          // No error -> no subject set
          return Card(
            child: Column(children: [
              ElevatedButton(
                  onPressed: () {
                    _showModal(i);
                  },
                  child: const Text("Prüfung hinzufügen")),
              const Slider(
                min: 0,
                divisions: 15,
                max: 15,
                value: 0.0,
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
                    ..._examOptions
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
              SizedBox(width: 20),
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
                  valueColor: const AlwaysStoppedAnimation(calqColor),
                  value: _block1Value.isNaN ? 0.0 : _block1Value,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: LinearProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation(calqColor),
                  value: _block2Value,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                    "${((_block1Value * _maxBlock1Value).isNaN ? 0.0 : (_block1Value * _maxBlock1Value)).round().toString()} von $_maxBlock1Value"),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: Text("${(_block2Value * 300).round()} von 300"),
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
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children:
                            [0, 1, 2, 3, 4].map((i) => examView(i)).toList(),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          0,
                          1,
                          2,
                          3,
                        ].map((i) => examView(i)).toList(),
                      ),
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
