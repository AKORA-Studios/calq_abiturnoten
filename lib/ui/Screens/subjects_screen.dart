import 'package:calq_abiturnoten/ui/Screens/subejctDetails/subject_info_screen.dart';
import 'package:calq_abiturnoten/ui/components/util.dart';
import 'package:calq_abiturnoten/util/averages.dart';
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
          title: const Text("Subjects"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                FutureBuilder(
                    future: DatabaseClass.Shared.getSubjects(),
                    builder: (ctx, snap) {
                      if (snap.hasData) {
                        return Column(
                            children: snap.data!
                                .map((e) => TextButton(
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 0)),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SubjectInfoScreen(sub: e)));
                                    },
                                    child: Card(
                                      child: FutureBuilder(
                                        future: Averages.averageString(e),
                                        builder: (ctx, snap) {
                                          if (snap.hasData) {
                                            return subjectRowWithTerms(
                                                e, snap.data ?? "?");
                                          } else {
                                            return const SizedBox();
                                          }
                                        },
                                      ),
                                    )))
                                .toList());
                      } else {
                        return const SizedBox();
                      }
                    }),
                Center(
                    child: FutureBuilder(
                        future: getActiveTermsGeneral(),
                        builder: (ctx, snap) {
                          if (snap.hasData) {
                            return Text(snap.data!);
                          } else {
                            return const Text("? von ? Halbjahren aktiv");
                          }
                        }))
              ],
            ),
          ),
        ));
  }
}
