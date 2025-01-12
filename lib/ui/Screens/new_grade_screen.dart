import 'package:flutter/material.dart';

class NewGradeScreen extends StatefulWidget {
  const NewGradeScreen({super.key});

  @override
  State<NewGradeScreen> createState() => _NewGradeScreenState();
}

class _NewGradeScreenState extends State<NewGradeScreen> {
  String gradeName = "";
  int selectedYear = 0; // TODO: int current halfyear

  Widget card(Widget content) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: SizedBox(
        width: double.infinity,
        child: Padding(padding: const EdgeInsets.all(5), child: content),
      ),
    );
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
                    card(Text("f")),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          gradeName = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Neuer Notenname',
                      ),
                    ),
                    card(Text("Typ")),
                    card(Column(
                      children: [
                        Text("Halbjahr"),
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
                      ],
                    )),
                    card(Text("Punkte")),
                    ElevatedButton(
                        onPressed: () {}, child: Text("Note hinzufügen"))
                  ],
                ))));
  }
}
