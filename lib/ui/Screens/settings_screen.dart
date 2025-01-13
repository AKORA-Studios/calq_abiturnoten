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
          title: Text("Settings"),
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: ListView(
            children: [
              ListTile(
                title: Text("Anzahl Prüfungen"),
                tileColor: Colors.orange,
              ),
              ListTile(
                title: Text("Anzahl Prüfungen"),
                tileColor: Colors.orange,
              ),
              ListTile(
                title: Text("Regenbogen"),
                tileColor: Colors.orange,
              ),
              Text("Noten importieren"),
              Text("Noten exportieren"),
              Column(
                children: [
                  Text("Alle Fächer"),
                  Divider(),
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
                                builder: (context) => AddSubjectScreen()));
                      },
                      child: Text("Neues Fach hinzufügen"))
                ],
              ),
            ],
          ),
        ));
  }
}
