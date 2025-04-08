import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:calq_abiturnoten/ui/Screens/settings/edit_subject_screen.dart';
import 'package:calq_abiturnoten/ui/Screens/settings/edit_weight_screen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../database/database.dart';
import '../components/util.dart';
import 'settings/add_subject_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _rainbowEnabled = false;
  bool _hasFiveExams = false;
  bool _shouldUpdateView = false;
  String _versionString = "Version: ?? (Build: ??)";

  @override
  void initState() {
    super.initState();
    // Sync app settings from Database
    _rainbowEnabled = DatabaseClass.Shared.rainbowEnabled;
    _hasFiveExams = DatabaseClass.Shared.hasFiveexams;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onAppear(); // TODO: maybe remove, maybe update subject list?
    });

    PackageInfo.fromPlatform().then((value) {
      String version = value.version;
      String buildNumber = value.buildNumber;

      setState(() {
        _versionString = "Version: $version (Build: $buildNumber)";
      });
      print(_versionString);
    });
  }

  Future<dynamic> createDialogue(Data_Subject sub) {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) => Dialog(
            child: Container(
                margin: const EdgeInsets.all(10),
                width: MediaQuery.sizeOf(context).width - 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${sub.name} löschen',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    const Text('Möchtest du dieses Fach wirklich löschen?'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Doch nicht')),
                        TextButton(
                            onPressed: () {
                              DatabaseClass.Shared.deleteSubject(sub.id);
                              setState(() {
                                _shouldUpdateView = !_shouldUpdateView;
                              });
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('Löschen'))
                      ],
                    )
                  ],
                ))));
  }

  void onAppear() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              Column(
                children: [
                  const Text("Allgemein"),
                  const Divider(),
                  settingsOptionWithWidget(
                      "Anzahl Abiturprüfungen",
                      Colors.deepPurple,
                      Icons.menu_book_sharp,
                      SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: [true, false]
                            .map((e) => ButtonSegment<bool>(
                                  value: e,
                                  label: Text(
                                    e ? "5" : "4",
                                  ),
                                ))
                            .toList(),
                        selected: <bool>{_hasFiveExams},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _hasFiveExams = newSelection.first;
                            DatabaseClass.Shared.updateSettings(
                                _rainbowEnabled, _hasFiveExams);
                          });
                        },
                      )),
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
                                  value, _hasFiveExams);
                            });
                          })),
                  settingsOption("Noten importieren", Colors.blue,
                      Icons.folder_open, () {}),
                  settingsOption(
                      "Noten exportieren", Colors.green, Icons.share, () {}),
                  settingsOption("Wertung ändern", Colors.yellow,
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
                                  .map((e) => subjectRowWith2Action(e, () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditSubjectScreen(
                                                        sub: e,
                                                        callbackFunc: () {
                                                          setState(() {
                                                            _shouldUpdateView =
                                                                !_shouldUpdateView;
                                                          });
                                                        })));
                                      }, () {
                                        createDialogue(e);
                                      }))
                                  .toList());
                        } else {
                          return const SizedBox();
                        }
                      }),
                  ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddSubjectScreen(
                                      callbackFunc: () {
                                        setState(() {
                                          _shouldUpdateView =
                                              !_shouldUpdateView;
                                        });
                                      },
                                    )));
                      },
                      child: const Text("Neues Fach hinzufügen"))
                ],
              ),
              Column(
                children: [
                  const Text("Notentypen"),
                  const Divider(),
                  FutureBuilder(
                      future: DatabaseClass.Shared.getTypes(),
                      builder: (ctx, snap) {
                        if (snap.hasError || !snap.hasData) {
                          return Text("smth went wrong fetching gradetypes");
                        } else {
                          return ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const EditWeightScreen()));
                              },
                              child: Text("Notentypen bearbeiten"));
                        }
                      }),
                ],
              ),
              Column(
                children: [
                  const Text("Sonstiges"),
                  const Divider(),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return deleteDataAlert();
                            });
                      },
                      child: Text("Alle Daten löschen")),
                  Text(_versionString),
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

  Widget deleteDataAlert() {
    // TODO: check if works
    return AlertDialog(
      // To display the title it is optional
      title: Text('Delete all Data'),
      // Message which will be pop up on the screen
      content: Text('Do you really want to delete all data?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('No!!!'),
        ),
        TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            DatabaseClass.Shared.deleteAllTypes().then((value) {
              Navigator.of(context).pop();
              setState(() {
                _shouldUpdateView = !_shouldUpdateView;
              });
            });
          },
          child: Text('Delete'),
        ),
      ],
    );
  }
}
