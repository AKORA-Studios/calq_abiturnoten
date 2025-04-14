import 'package:calq_abiturnoten/database/database.dart';
import 'package:calq_abiturnoten/ui/components/styling.dart';
import 'package:flutter/material.dart';

import 'exam_vm.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  ExamViewViewModel _viewModel = ExamViewViewModel();
  bool _shouldUpdate = false;
  List<double> _sliderValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

  @override
  void initState() {
    super.initState();

    _viewModel.updateData().then((value) {
      setState(() {
        for (int i in [1, 2, 3, 4, 5]) {
          _sliderValues[i] = (_viewModel.examPoints[i]! + 0.0);
        }
        _shouldUpdate = !_shouldUpdate;
      });
    });
  }

  Widget examView(int i) {
    var sub = _viewModel.exams[i];
    if (sub != null) {
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
                          _viewModel.removeExam(sub, i);
                        },
                        icon: const Icon(
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
                        child: Text(_viewModel.examPoints[i].toString()),
                      ),
                    ),
                    Expanded(
                      flex: 19,
                      child: Slider(
                          thumbColor: sub.getColor(),
                          activeColor: sub.getColor(),
                          min: 0,
                          label: '${_viewModel.examPoints[i]}',
                          divisions: 15,
                          max: 15,
                          value: _sliderValues[i],
                          // value: (_viewModel.examPoints[i] ?? 0) + 0.0,
                          onChangeEnd: (value) {
                            setState(() {
                              _sliderValues[i] = value;
                            });
                            _viewModel.updateSlider(value, sub);
                            // TODO: can set state be removed?
                            /*  setState(() {
                                  _shouldUpdate = !_shouldUpdate;
                                });*/
                          },
                          onChanged: (value) {}),
                    )
                  ],
                ),
              ])));
    } else {
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
                    ..._viewModel.examOptions
                        .map((e) => ElevatedButton(
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(e.name),
                              ),
                              onPressed: () {
                                DatabaseClass.Shared.updateSubjectExam(e, type);
                                _viewModel.chooseExam(e, type);

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
                  value: _viewModel.block1Value.isNaN
                      ? 0.0
                      : _viewModel.block1Value,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: LinearProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation(calqColor),
                  value: _viewModel.block2Value,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                    "${((_viewModel.block1Value * _viewModel.maxBlock1Value).isNaN ? 0.0 : (_viewModel.block1Value * _viewModel.maxBlock1Value)).round().toString()} von ${_viewModel.maxBlock1Value}"),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child:
                    Text("${(_viewModel.block2Value * 300).round()} von 300"),
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
                            [1, 2, 3, 4, 5].map((i) => examView(i)).toList(),
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
