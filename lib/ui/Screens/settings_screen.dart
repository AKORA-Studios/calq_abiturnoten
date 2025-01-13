import 'package:flutter/material.dart';

import '../../database/database.dart';
import '../components/util.dart';
import 'add_subject_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Settings"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              const ListTile(
                title: Text("Anzahl Prüfungen"),
                tileColor: Colors.orange,
              ),
              const ListTile(
                title: Text("Anzahl Prüfungen"),
                tileColor: Colors.orange,
              ),
              const ListTile(
                title: Text("Regenbogen"),
                tileColor: Colors.orange,
              ),
              const Text("Noten importieren"),
              const Text("Noten exportieren"),
              Column(
                children: [
                  const Text("Alle Fächer"),
                  const Divider(),
                  FutureBuilder(
                      future: DatabaseClass.Shared.getSubjectsList(),
                      builder: (ctx, snap) {
                        if (snap.hasData) {
                          return Column(
                              children: snap.data!
                                  .map((e) => subjectRow(e))
                                  .toList());
                        } else {
                          return const SizedBox();
                        }
                      }),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddSubjectScreen()));
                      },
                      child: const Text("Neues Fach hinzufügen"))
                ],
              ),
            ],
          ),
        ));
  }
}
