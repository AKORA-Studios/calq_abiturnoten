import 'package:calq_abiturnoten/database/database.dart';
import 'package:calq_abiturnoten/util/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key, required this.callbackFunc});
  final VoidCallback callbackFunc;

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  Color _pickerColor = const Color(0xff443a49);

  void changeColor(Color color) {
    setState(() => _pickerColor = color);
  }

  String _subjectName = "";
  bool _isLK = false;
  String _errorText = "";

  Future<void> addSubject() async {
    if (_subjectName.isEmpty) {
      setState(() {
        _errorText = "Invalid Subject Name";
      });
      return;
    }

    DatabaseClass.Shared.createSubject(_subjectName,
            toHex(_pickerColor).replaceAll("#", ""), _isLK ? 1 : 0)
        .then((value) {
      widget.callbackFunc();
      Navigator.pop(context);
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Neues Fach hinzufügen"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(_errorText),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Ist LK?"),
                    Switch(
                      activeColor: _pickerColor,
                      activeTrackColor: _pickerColor.withAlpha(100),
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
                                pickerColor: _pickerColor,
                                onColorChanged: changeColor,
                                colorPickerWidth: 300,
                                pickerAreaHeightPercent: 0.7,
                                enableAlpha: false,
                                labelTypes: const [],
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          color: _pickerColor,
                          child: const SizedBox(
                            width: 20,
                            height: 20,
                          ),
                        ),
                        const Text(
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
                    onPressed: addSubject, child: const Text("Fach hinzufügen"))
              ],
            ),
          ),
        ));
  }
}
