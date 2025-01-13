import 'package:flutter/material.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<double> points = [0, 0, 0, 0, 0];

  Widget examView(int i) {
    return Column(children: [
      Text("Exam $i [${points[i]}]"),
      Slider(
        //  activeColor: widget.sub.color, // TODO:
        min: 0,
        label: '${points[i].round()}',
        divisions: 15,
        max: 15,
        value: points[i],
        onChanged: (value) {
          setState(() {
            points[i] = value;
          });
        },
      )
    ]);
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
            children: [0, 1, 2, 3, 4].map((i) => examView(i)).toList(),
          ),
        ));
  }
}
