import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:flutter/material.dart';

import '../../../database/database.dart';
import '../../components/util.dart';
import 'new_grade_screen.dart';

class AddGradeScreen extends StatefulWidget {
  const AddGradeScreen({super.key});

  @override
  State<AddGradeScreen> createState() => _AddGradeScreenState();
}

class _AddGradeScreenState extends State<AddGradeScreen> {
  Widget subjectEntry(Data_Subject sub) {
    return TextButton(
        style: TextButton.styleFrom(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0)),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewGradeScreen(sub: sub)));
        },
        child: subjectRow(sub));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Neue Note hinzufügen"),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    FutureBuilder(
                        future: DatabaseClass.Shared.getSubjects(),
                        builder: (ctx, snap) {
                          if (snap.hasData) {
                            return Column(
                                children: snap.data!
                                    .map((e) => subjectEntry(e))
                                    .toList());
                          } else {
                            return const SizedBox();
                          }
                        }),
                  ],
                ))));
  }
}
