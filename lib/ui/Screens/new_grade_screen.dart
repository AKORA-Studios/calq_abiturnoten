import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:calq_abiturnoten/database/database.dart';
import 'package:calq_abiturnoten/ui/components/util.dart';
import 'package:flutter/material.dart';

import '../../util/date_formatter.dart';

class NewGradeScreen extends StatefulWidget {
  const NewGradeScreen({super.key, required this.sub});

  final Data_Subject sub;

  @override
  State<NewGradeScreen> createState() => _NewGradeScreenState();
}

class _NewGradeScreenState extends State<NewGradeScreen> {
  String gradeName = "";
  int selectedYear = 0; // TODO: int current halfyear
  DateTime _selectedDate = DateTime.now();
  String errorText = "";

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
    if (gradeName.isEmpty) {
      setState(() {
        errorText = "Invalid Grade Name";
        return;
      });
    }
    await DatabaseClass.Shared.createTest(widget.sub.id, gradeName, 12);
    // TODO: implement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Neue Note"),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    card(Column(
                      children: [
                        Text(errorText),
                        const Text("Notenname"),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              gradeName = value;
                            });
                          },
                          decoration: const InputDecoration(
                            //  border: OutlineInputBorder(),
                            hintText: 'Neuer Notenname',
                          ),
                        )
                      ],
                    )),
                    card(Text("Typ")),
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
                                            decoration: selectedYear == e
                                                ? TextDecoration.underline
                                                : TextDecoration.none)),
                                  ))
                              .toList(),
                          selected: <int>{selectedYear},
                          onSelectionChanged: (Set<int> newSelection) {
                            setState(() {
                              selectedYear = newSelection.first;
                            });
                          },
                        ),
                        Row(
                          children: [
                            Text("Datum"),
                            ElevatedButton(
                                onPressed: () => _selectDate(context),
                                child: Text(formatDate(_selectedDate)))
                          ],
                        )
                      ],
                    )),
                    card(Text("Punkte")),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: widget.sub.color),
                        onPressed: addGrade,
                        child: Text("Note hinzufügen"))
                  ],
                ))));
  }
}
