import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:calq_abiturnoten/database/Data_Test.dart';
import 'package:flutter/material.dart';

import '../../../database/Data_Type.dart';
import '../../../util/date_formatter.dart';
import '../../components/styling.dart';
import '../../components/widget_components.dart';
import 'new_grade_vn.dart';

class NewGradeScreen extends StatefulWidget {
  const NewGradeScreen({super.key, required this.sub, required this.tests});

  final Data_Subject sub;
  final List<Data_Test> tests;

  @override
  State<NewGradeScreen> createState() => _NewGradeScreenState();
}

class _NewGradeScreenState extends State<NewGradeScreen> {
  NewGradeScreenViewModel _viewmodel = NewGradeScreenViewModel();

  @override
  void initState() {
    super.initState();
    _viewmodel.updateData(widget.tests).then((value) {
      setState(() {});
    });
  }

  Future _selectDate(BuildContext context) async => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
      ).then((DateTime? selected) {
        if (selected != null && selected != _viewmodel.selectedDate) {
          _viewmodel.selectedDate = selected;
          setState(() {});
        }
      });

  Future<void> addGrade() async {
    _viewmodel.addGrade(widget.sub).then((value) {
      if (_viewmodel.errorText.isNotEmpty) {
        setState(() {});
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Neue Note"),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    card(Column(
                      children: [
                        Text(
                          _viewmodel.errorText,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        const Text("Notenname"),
                        TextField(
                          onChanged: (value) {
                            _viewmodel.gradeName = value;
                            setState(() {});
                          },
                          decoration: const InputDecoration(
                            //  border: OutlineInputBorder(),
                            hintText: 'Neuer Notenname',
                          ),
                        )
                      ],
                    )),
                    card(Column(
                      children: [const Text("Typ"), typeSelection()],
                    )),
                    card(Column(
                      children: [
                        const Text("Halbjahr"),
                        SegmentedButton<int>(
                          style: calqSegmentedButtonStyle(),
                          showSelectedIcon: false,
                          segments: [1, 2, 3, 4]
                              .map((e) => ButtonSegment<int>(
                                    value: e,
                                    label: Text('$e',
                                        style: TextStyle(
                                            decoration:
                                                _viewmodel.selectedYear == e
                                                    ? TextDecoration.underline
                                                    : TextDecoration.none)),
                                  ))
                              .toList(),
                          selected: <int>{_viewmodel.selectedYear},
                          onSelectionChanged: (Set<int> newSelection) {
                            _viewmodel.updateImpactSegment(widget.tests);
                            _viewmodel.selectedYear = newSelection.first;
                            setState(() {});
                          },
                        ),
                        Row(
                          children: [
                            const Text("Datum"),
                            ElevatedButton(
                                onPressed: () => _selectDate(context),
                                child:
                                    Text(formatDate(_viewmodel.selectedDate)))
                          ],
                        )
                      ],
                    )),
                    card(Column(
                      children: [
                        Text("Punkte (${_viewmodel.testPoints.toInt()})"),
                        Slider(
                          activeColor: widget.sub.getColor(),
                          min: 0.0,
                          label: '${_viewmodel.testPoints.round()}',
                          divisions: 15,
                          max: 15.0,
                          value: _viewmodel.testPoints,
                          onChanged: (value) {
                            _viewmodel.testPoints = value;
                            setState(() {});
                          },
                        )
                      ],
                    )),
                    card(Column(
                      children: [
                        const Text("Noteneinfluss"),
                        impactSegment(_viewmodel.impactSegmentData)
                      ],
                    )),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  widget.sub.getColor().withOpacity(0.5)),
                          onPressed: addGrade,
                          child: const Text("Note hinzufügen")),
                    )
                  ],
                ))));
  }

  Widget typeSelection() {
    List<Data_Type> arr = _viewmodel.types;
    List<ButtonSegment<int>> buttons = [];

    if (arr.isEmpty) {
      return const Text("No Data :c");
    }

    arr.asMap().forEach((index, e) {
      buttons.add(ButtonSegment<int>(
        value: e.assignedID,
        label: Text('${e.name} \n[${e.assignedID}]',
            style: TextStyle(
                decoration: _viewmodel.selectedTypeIndex == index
                    ? TextDecoration.underline
                    : TextDecoration.none)),
      ));
    });

    if (_viewmodel.selectedTypeIndex < 0) {
      _viewmodel.selectedTypeIndex = arr.first.assignedID;
      _viewmodel.updateImpactSegment(widget.tests).then((value) {
        setState(() {});
      });
    }

    return SegmentedButton<int>(
      showSelectedIcon: false,
      style: calqSegmentedButtonStyle(),
      segments: buttons,
      selected: <int>{_viewmodel.selectedTypeIndex},
      onSelectionChanged: (Set<int> newSelection) {
        _viewmodel.selectedTypeIndex = newSelection.first;
        _viewmodel.updateImpactSegment(widget.tests).then((value) {
          setState(() {});
        });
      },
    );
  }
}
