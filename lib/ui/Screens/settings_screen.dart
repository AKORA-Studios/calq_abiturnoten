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
  bool _rainbowEnabled = false;
  bool _hasFiveexams = false;

  @override
  void initState() {
    super.initState();
    // Sync app settings from Database
    _rainbowEnabled = DatabaseClass.Shared.rainbowEnabled;
    _hasFiveexams = DatabaseClass.Shared.hasFiveexams;
  }

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
              Column(
                children: [
                  Text("Allgemein"),
                  Divider(),
                  settingsOptionWithWidget("Anzahl Abiturprüfungen",
                      Colors.deepPurple, Icons.menu_book_sharp, Text("hh")),
                  settingsOptionWithWidget(
                      "Regenbogen",
                      Colors.blue,
                      Icons.bar_chart,
                      Switch(
                          value: _rainbowEnabled,
                          onChanged: (value) {
                            // TODO update rainbow setting
                            setState(() {
                              _rainbowEnabled = value;
                              DatabaseClass.Shared.updateSettings(
                                  value, _hasFiveexams);
                            });
                          })),
                  settingsOption("Noten importieren", Colors.blue,
                      Icons.folder_open, () {}),
                  settingsOption(
                      "Noten exportieren", Colors.green, Icons.share, () {}),
                  settingsOption("Wertung änmdern", Colors.yellow,
                      Icons.filter_frames, () {}),
                  settingsOption("Demo Daten laden", Colors.orange,
                      Icons.warning_amber, () {}),
                  settingsOption(
                      "Daten löschen", Colors.red, Icons.delete, () {}),
                  settingsOption("Github", Colors.pink, Icons.info, () {}),
                  settingsOption("PDF Export", Colors.deepPurpleAccent,
                      Icons.file_copy_outlined, () {})
                ],
              ),
              Column(
                children: [
                  const Text("Alle Fächer"),
                  const Divider(),
                  FutureBuilder(
                      future: DatabaseClass.Shared.getSubjects(),
                      builder: (ctx, snap) {
                        if (snap.hasData) {
                          return Column(
                              children: snap.data!
                                  .map((e) => subjectRowWithAction(e, () {
                                        print("eee");
                                        // TODO: delete subject
                                      }))
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
                                builder: (context) =>
                                    const AddSubjectScreen()));
                      },
                      child: const Text("Neues Fach hinzufügen"))
                ],
              ),
              Column(
                children: [
                  const Text("Sonstiges"),
                  const Divider(),
                  const Text("Version: ??, Build: ??"),
                  TextButton(
                      onPressed: () {
                        showLicensePage(context: context);
                      },
                      child: const Text("Lizenzen"))
                ],
              )
            ],
          ),
        ));
  }
}
