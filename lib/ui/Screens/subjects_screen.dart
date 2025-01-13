import 'package:calq_abiturnoten/ui/Screens/subject_info_screen.dart';
import 'package:flutter/material.dart';

import '../../database/database.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Subjects"),
        ),
        body: ListView(
          children: [
            FutureBuilder(
                future: DatabaseClass.Shared.getSubjectsList(),
                builder: (ctx, snap) {
                  if (snap.hasData) {
                    return Column(
                        children: snap.data!
                            .map((e) => ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SubjectInfoScreen(sub: e)));
                                },
                                child: Text(e.name + " ${e.tests.length}")))
                            .toList());
                  } else {
                    return const SizedBox();
                  }
                })
          ],
        ));
  }
}
