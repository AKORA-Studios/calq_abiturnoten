import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:calq_abiturnoten/database/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditSubjectScreen extends StatefulWidget {
  const EditSubjectScreen({super.key, required this.sub});

  final Data_Subject sub;

  @override
  State<EditSubjectScreen> createState() => _EditSubjectScreenState();
}

// Edible: color, name, lk type
class _EditSubjectScreenState extends State<EditSubjectScreen> {
  Color _pickerColor = const Color(0xff443a49);

  void changeColor(Color color) {
    setState(() => _pickerColor = color);
  }

  String _subjectName = "";
  bool _isLK = false;
  String _errorText = "";

  Future<void> updateSubject() async {
    if (_subjectName.isEmpty) {
      setState(() {
        _errorText = "Invalid Subject Name";
      });
    }

    widget.sub.name = _subjectName;
    widget.sub.lk = _isLK;
    widget.sub.color = _pickerColor;

    DatabaseClass.Shared.updateSubject(widget.sub).then((value) {
      Navigator.pop(context);
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _subjectName = widget.sub.name;
      _isLK = widget.sub.lk;
      _pickerColor = widget.sub.color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Fach bearbeiten"),
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
                  hintText: 'Neuer Name des Fachs',
                ),
              ),
              ElevatedButton(
                  onPressed: updateSubject,
                  child: const Text("Fach aktualisieren"))
            ],
          ),
        )));
  }
}
