import 'package:calq_abiturnoten/database/Data_Test.dart';
import 'package:flutter/material.dart';

import '../../../database/database.dart';
import '../../../util/date_formatter.dart';
import '../../components/util.dart';

class EditGradeScreen extends StatefulWidget {
  const EditGradeScreen({super.key, required this.test, required this.color});
  final Data_Test test;
  final Color color;

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

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedYear = widget.test.year;
      _selectedDate = widget.test.date;
      _gradeName = widget.test.name;
      _testPoints = widget.test.points.toDouble();
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
    widget.test.year = _selectedYear;
    widget.test.date = _selectedDate;
    widget.test.name = _gradeName;
    widget.test.points = _testPoints.toInt();

    await DatabaseClass.Shared.updateTest(widget.test).then((value) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                    card(const Text("Typ")),
                    card(Column(
                      children: [
                        const Text("Halbjahr"),
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
                              backgroundColor: widget.color),
                          onPressed: () async {
                            await saveChanges();
                            Navigator.pop(context);
                          },
                          child: const Text("Note aktualisieren")),
                    )
                  ],
                ))));
  }
}
