import 'package:calq_abiturnoten/ui/Screens/subject_info_screen.dart';
import 'package:calq_abiturnoten/ui/components/util.dart';
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
          title: const Text("Subjects"),
        ),
        body: ListView(
          children: [
            FutureBuilder(
                future: DatabaseClass.Shared.getSubjectsList(),
                builder: (ctx, snap) {
                  if (snap.hasData) {
                    return Column(
                        children: snap.data!
                            .map((e) => TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SubjectInfoScreen(sub: e)));
                                },
                                child: subjectRowWithHalfyears(e)))
                            .toList());
                  } else {
                    return const SizedBox();
                  }
                })
          ],
        ));
  }
}
