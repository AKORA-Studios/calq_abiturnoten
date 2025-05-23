import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:calq_abiturnoten/ui/Screens/settings/edit_subject_screen.dart';
import 'package:calq_abiturnoten/ui/Screens/settings/edit_weight_screen.dart';
import 'package:calq_abiturnoten/ui/Screens/settings/pdf_export_screen.dart';
import 'package:calq_abiturnoten/util/JSON_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share/share.dart';

import '../../database/database.dart';
import '../components/widget_components.dart';
import 'settings/add_subject_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey _alertKey = GlobalKey();
  final GlobalKey _deleteAlertKey = GlobalKey();

  bool _rainbowEnabled = false;
  bool _hasFiveExams = false;
  bool _shouldUpdateView = false;
  String _versionString = "Version: ?? (Build: ??)";
  bool _isLoading = false;

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
        body: IgnorePointer(
            ignoring: _isLoading,
            child: Stack(
              children: [
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox(),
                settingsRow()
              ],
            )));
  }

  Widget settingsRow() {
    return Padding(
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
              settingsOption(
                  "Noten importieren (WIP)", Colors.blue, Icons.folder_open,
                  () {
                // TODO: alert?
                _pickFile();
              }),
              settingsOption("Noten exportieren", Colors.green, Icons.share,
                  () {
                JSONUtil().exportJSON();
              }),
              settingsOption(
                  "Wertung ändern", Colors.amber, Icons.filter_frames, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditWeightScreen()));
              }),
              settingsOption(
                  "Demo Daten laden", Colors.orange, Icons.warning_amber, () {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return loadDemoDataAlert();
                    });
              }),
              settingsOption("Daten löschen", Colors.red, Icons.delete, () {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return deleteDataAlert();
                    });
              }),
              settingsOption("Github", Colors.pink, Icons.info, () {
                Share.share("https://github.com/AKORA-Studios/calq_abiturnoten",
                    subject: "Calq Github Link");
              }),
              settingsOption(
                  "PDF Export (WIP)", Colors.purple, Icons.file_copy_outlined,
                  () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PDFExportScreen()));
              })
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
                                      _shouldUpdateView = !_shouldUpdateView;
                                    });
                                  },
                                )));
                  },
                  child: const Text("Neues Fach hinzufügen"))
            ],
          ),
          Column(
            children: [
              const Text("Sonstiges"),
              const Divider(),
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
    );
  }

  Widget deleteDataAlert() {
    return AlertDialog(
      key: _deleteAlertKey,
      title: const Text('Delete all Data'),
      content: const Text('Do you really want to delete all data?'),
      actions: [
        TextButton(
          onPressed: () {
            if (_alertKey.currentContext != null) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('No!!!'),
        ),
        TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            DatabaseClass.Shared.deleteData().then((value) {
              if (_alertKey.currentContext != null) {
                Navigator.of(context).pop();
              }
              setState(() {
                _shouldUpdateView = !_shouldUpdateView;
              });
            });
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Widget loadDemoDataAlert() {
    return AlertDialog(
      key: _alertKey,
      title: const Text('Demo Daten laden?'),
      content:
          const Text('Loading the demo data will delete all your current data'),
      actions: [
        TextButton(
          onPressed: () {
            if (_isLoading) {
              return;
            }
            if (_alertKey.currentContext != null) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('No!!!'),
        ),
        TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            setState(() {
              _isLoading = true;
            });
            DatabaseClass.Shared.deleteData().then((value) async {
              await JSONUtil().loadDemoData(context);
              if (_alertKey.currentContext != null) {
                Navigator.of(context).pop();
              }
              setState(() {
                _isLoading = false;
                _shouldUpdateView = !_shouldUpdateView;
              });
            });
          },
          child: const Text('Load'),
        ),
      ],
    );
  }

  void _pickFile() async {
    DatabaseClass.Shared.deleteData().then((value) async {
      final result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.custom,
          allowedExtensions: ['json']);

      if (result == null) return;
      final file = result.files.first;
      if (file.path == null) {
        return;
      }

      await JSONUtil().loadFromPath(context, file.path!);
    });
  }
}
