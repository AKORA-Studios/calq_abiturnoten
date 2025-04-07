import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:calq_abiturnoten/database/database.dart';
import 'package:flutter/material.dart';

import '../../util/date_formatter.dart';
import '../components/styling.dart';

class NewGradeScreen extends StatefulWidget {
  const NewGradeScreen({super.key, required this.sub});

  final Data_Subject sub;

  @override
  State<NewGradeScreen> createState() => _NewGradeScreenState();
}

class _NewGradeScreenState extends State<NewGradeScreen> {
  String _gradeName = "";
  int _selectedYear = 1;
  DateTime _selectedDate = DateTime.now();
  String errorText = "";
  double _testPoints = 0; // TODO: init average points for this halfyear

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedYear = widget.sub.lastActiveYear();
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

  Future<void> addGrade() async {
    if (_gradeName.isEmpty) {
      setState(() {
        errorText = "Invalid Grade Name";
      });
      return;
    }
    await DatabaseClass.Shared.createTest(widget.sub.id, _gradeName,
            _testPoints.toInt(), _selectedYear, _selectedDate)
        .then((value) {
      Navigator.pop(context);
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
                          activeColor: widget.sub.color,
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
                              backgroundColor: widget.sub.color),
                          onPressed: addGrade,
                          child: const Text("Note hinzufügen")),
                    )
                  ],
                ))));
  }
}
