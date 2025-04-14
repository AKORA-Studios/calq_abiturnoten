import 'package:calq_abiturnoten/database/Data_Test.dart';
import 'package:flutter/material.dart';

import '../../../database/Data_Type.dart';
import '../../../database/database.dart';
import '../../../util/date_formatter.dart';
import '../../components/styling.dart';

class EditGradeScreen extends StatefulWidget {
  const EditGradeScreen(
      {super.key,
      required this.test,
      required this.color,
      required this.callbackFunc});
  final Data_Test test;
  final Color color;
  final VoidCallback callbackFunc;

  @override
  State<EditGradeScreen> createState() => _EditGradeScreenState();
}

class _EditGradeScreenState extends State<EditGradeScreen> {
  String _gradeName = "";
  int _selectedYear = 1;
  DateTime _selectedDate = DateTime.now();
  String errorText = "";
  double _testPoints = 0;
  bool _shouldUpdate = false;
  int _selectedTypeIndex = -1;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedYear = widget.test.year;
      _selectedDate = widget.test.date;
      _gradeName = widget.test.name;
      _testPoints = widget.test.points.toDouble();
      _selectedTypeIndex = widget.test.type;
    });
    setState(() {
      _shouldUpdate = !_shouldUpdate;
    });
  }

  Future _selectDate(BuildContext context) async => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
      ).then((DateTime? selected) {
        if (selected != null && selected != _selectedDate) {
          setState(() => _selectedDate = selected);
        }
      });

  Future<void> saveChanges() async {
    if (_gradeName.isEmpty) {
      setState(() {
        errorText = "Invalid Grade Name";
      });
      return;
    }

    if (_selectedTypeIndex < 0) {
      setState(() {
        errorText = "Pls select a grade type";
      });
      return;
    }

    widget.test.year = _selectedYear;
    widget.test.date = _selectedDate;
    widget.test.name = _gradeName;
    widget.test.points = _testPoints.toInt();
    widget.test.type = _selectedTypeIndex;

    await DatabaseClass.Shared.updateTest(widget.test).then((value) {
      widget.callbackFunc();
      Navigator.pop(context);
    });
  }

  Future<void> deleteGrade() async {
    await DatabaseClass.Shared.deleteTest(widget.test.id, widget.test.subject)
        .then((value) {
      widget.callbackFunc();
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Note bearbeiten"),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    card(Column(
                      children: [
                        Text(
                          errorText,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        const Text("Notenname"),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _gradeName = value;
                            });
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
                          showSelectedIcon: false,
                          style: calqSegmentedButtonStyle(),
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
                        Row(
                          children: [
                            const Text("Datum"),
                            ElevatedButton(
                                onPressed: () => _selectDate(context),
                                child: Text(formatDate(_selectedDate)))
                          ],
                        )
                      ],
                    )),
                    card(Column(
                      children: [
                        Text("Punkte (${_testPoints.toInt()})"),
                        Slider(
                          activeColor: widget.color,
                          min: 0.0,
                          label: '${_testPoints.round()}',
                          divisions: 15,
                          max: 15.0,
                          value: _testPoints,
                          onChanged: (value) {
                            setState(() {
                              _testPoints = value;
                            });
                          },
                        )
                      ],
                    )),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: widget.color.withOpacity(0.5)),
                          onPressed: () async {
                            await saveChanges();
                          },
                          child: const Text("Note aktualisieren")),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: destructiveButton(),
                          onPressed: () async {
                            await deleteGrade();
                          },
                          child: const Text("Note löschen")),
                    )
                  ],
                ))));
  }

  Widget typeSelection() {
    return FutureBuilder(
        future: DatabaseClass.Shared.getTypes(),
        builder: (ctx, snap) {
          if (snap.hasError) {
            return const Text("Smth went wrong ");
          } else {
            List<Data_Type> arr = snap.hasData ? snap.data! : [];
            List<ButtonSegment<int>> buttons = [];
            if (arr.isEmpty) {
              return const Text("No Data :c");
            }

            arr.asMap().forEach((index, e) {
              buttons.add(ButtonSegment<int>(
                value: e.assignedID,
                label: Text('${e.name} \n[${e.assignedID}]',
                    style: TextStyle(
                        decoration: _selectedTypeIndex == index
                            ? TextDecoration.underline
                            : TextDecoration.none)),
              ));
            });

            return SegmentedButton<int>(
              showSelectedIcon: false,
              style: calqSegmentedButtonStyle(),
              segments: buttons,
              selected: <int>{_selectedTypeIndex},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _selectedTypeIndex = newSelection.first;
                });
              },
            );
          }
        });
  }
}
