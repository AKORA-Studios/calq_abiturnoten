import 'package:calq_abiturnoten/database/database.dart';
import 'package:calq_abiturnoten/util/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  Color currentColor = Color(0xff443a49);
  Color pickerColor = Color(0xff443a49);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  String _subjectName = "";
  bool _isLK = false;
  String _errorText = "";

  Future<void> addSubject() async {
    if (_subjectName.isEmpty) {
      setState(() {
        _errorText = "Invalid Subject Name";
      });
    }

    DatabaseClass.Shared.createSubject(
            _subjectName, toHex(pickerColor).replaceAll("#", ""), _isLK ? 1 : 0)
        .then((value) {
      Navigator.pop(context);
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Neues Fach hinzufügen"),
        ),
        body: ListView(
          children: [
            Text(_errorText),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Ist LK?"),
                Switch(
                  activeColor: pickerColor,
                  activeTrackColor: pickerColor.withAlpha(100),
                  value: _isLK,
                  onChanged: (value) => setState(() => _isLK = value),
                ),
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        titlePadding: const EdgeInsets.all(0),
                        contentPadding: const EdgeInsets.all(0),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: pickerColor,
                            onColorChanged: changeColor,
                            colorPickerWidth: 300,
                            pickerAreaHeightPercent: 0.7,
                            enableAlpha: false,
                            labelTypes: [],
                            displayThumbColor: true,
                            pickerAreaBorderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(2),
                              topRight: Radius.circular(2),
                            ),
                            hexInputBar: true,
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    Container(
                      color: pickerColor,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                      ),
                    ),
                    Text(
                      'Fach Farbe',
                    )
                  ],
                )),
            TextField(
              onChanged: (value) {
                setState(() {
                  _subjectName = value;
                });
              },
              decoration: const InputDecoration(
                //  border: OutlineInputBorder(),
                hintText: 'Name des neuen Fachs',
              ),
            ),
            ElevatedButton(
                onPressed: addSubject, child: Text("Fach hinzufügen"))
          ],
        ));
  }
}
