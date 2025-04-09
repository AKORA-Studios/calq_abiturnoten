import 'package:calq_abiturnoten/ui/components/styling.dart';
import 'package:flutter/material.dart';

import '../../../database/Data_Type.dart';
import '../../../database/database.dart';

class EditWeightScreen extends StatefulWidget {
  const EditWeightScreen({super.key});

  @override
  State<EditWeightScreen> createState() => _EditWeightScreenState();
}

class _EditWeightScreenState extends State<EditWeightScreen> {
  bool _shouldUpdate = false;
  bool _notInitialized = true;
  int _primaryType = -1;
  // Edit Weights
  int _selectedWeightIndex = 0;
  final List<String> _segments = ["10", "1", "0.1"];
  String _errorText = "";
  Map<int, double> _mappedWeights = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      _primaryType = DatabaseClass.Shared.primaryType;
    });
  }

  double getCurrentValue() {
    return double.parse((_mappedWeights.values
            .fold(0.0, (previousValue, element) => previousValue + element))
        .toStringAsFixed(1));
  }

  void saveWeightChanges() {
    double finalValue = getCurrentValue();
    if (finalValue < 0.0 || finalValue > 100.0) {
      setState(() {
        _errorText = "Value not in range 0...100";
      });
      return;
    }

    if (finalValue != 100.0) {
      setState(() {
        _errorText = "Sum has to be 100.0";
      });
      return;
    }

    DatabaseClass.Shared.editTypeWeights(_mappedWeights).then((value) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Edit Weights"),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(children: [
                  FutureBuilder(
                      future: DatabaseClass.Shared.getTypes(),
                      builder: (ctx, snap) {
                        if (snap.hasError || snap.data == null) {
                          return const Text("Smth went wrong");
                        } else {
                          return Column(
                              children:
                                  snap.data!.map((e) => typeRow(e)).toList());
                        }
                      }),
                  //        ...widget.types.map((e) => typeRow(e)).toList(),
                  ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return newTypeAlert();
                            });
                      },
                      child: const Text("Typ hinzufügen")),
                  const Divider(),
                  const Text("Change Weights"),
                  ...editWeight()
                ]))));
  }

  List<Widget> editWeight() {
    List<ButtonSegment<int>> buttons = [];
    _segments.asMap().forEach((index, value) {
      buttons.add(ButtonSegment<int>(
        value: index,
        label: Text(value),
      ));
    });

    return [
      SegmentedButton<int>(
        showSelectedIcon: false,
        segments: buttons,
        selected: <int>{_selectedWeightIndex},
        onSelectionChanged: (Set<int> newSelection) {
          setState(() {
            _selectedWeightIndex = newSelection.first;
          });
        },
      ),
      FutureBuilder(
          future: DatabaseClass.Shared.getTypes(),
          builder: (ctx, snap) {
            if (snap.hasError || snap.data == null) {
              return const Text("Smth went wrong");
            } else {
              List<Widget> children = [];
              snap.data!.asMap().forEach((index, e) {
                if (_notInitialized) {
                  _mappedWeights[e.id] = e.weigth;
                }

                children.add(typeEditRow(e));
              });
              // setState(() {
              _notInitialized = false;
              //   });

              return Column(children: children);
            }
          }),
      Text("Gesamt: ${getCurrentValue()}%"),
      ElevatedButton(
          onPressed: () {
            saveWeightChanges();
          },
          child: const Text("Save Weight Changes")),
      Text(
        _errorText,
        style: const TextStyle(color: Colors.red),
      )
    ];
  }

  Widget typeEditRow(Data_Type type) {
    return card(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("${type.name} [${type.assignedID}]"),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text((_mappedWeights[type.id] ?? 0.0).toStringAsFixed(1)),
            IconButton(
                onPressed: () {
                  double value = double.parse(_segments[_selectedWeightIndex]);
                  if (getCurrentValue() - value < 0.0 ||
                      (_mappedWeights[type.id] ?? 0.0) - value < 0.0) {
                    return;
                  }
                  setState(() {
                    _mappedWeights[type.id] = _mappedWeights[type.id]! - value;
                  });
                },
                icon: const Icon(Icons.remove)),
            IconButton(
                onPressed: () {
                  double value = double.parse(_segments[_selectedWeightIndex]);

                  if (getCurrentValue() + value > 100.0) {
                    return;
                  }

                  setState(() {
                    _mappedWeights[type.id] =
                        (_mappedWeights[type.id] ?? 0.0) + value;
                  });
                },
                icon: const Icon(Icons.add))
          ],
        )
      ],
    ));
  }

  Widget typeRow(Data_Type type) {
    return card(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("${type.name} [${type.assignedID}]"),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                padding: const EdgeInsets.all(0.0),
                width: 30.0, // you can adjust the width as you need
                child: IconButton(
                    onPressed: () {
                      DatabaseClass.Shared.updatePrimaryType(type.assignedID)
                          .then((value) {
                        setState(() {
                          _primaryType = DatabaseClass.Shared.primaryType;
                        });
                      });
                    },
                    icon: Icon(Icons.star,
                        color: _primaryType == type.assignedID
                            ? calqColor
                            : Colors.grey))),
            Container(
                padding: const EdgeInsets.all(0.0),
                width: 30.0, // you can adjust the width as you need
                child: IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (ctx) {
                            return deleteAlert(type.assignedID);
                          });
                    },
                    icon: const Icon(Icons.delete, color: Colors.red)))
          ],
        )
      ],
    ));
  }

  Widget deleteAlert(int typeID) {
    return FutureBuilder(
        future: DatabaseClass.Shared.getTypeGrades(typeID),
        builder: (ctx, snap) {
          if (snap.hasError || !snap.hasData || snap.data!.isNotEmpty) {
            return AlertDialog(
              title: const Text("Type is still in use"),
              content: const Text(
                  "Type is still used by grades so it cant be deleted"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Oki'),
                ),
              ],
            );
          } else {
            return gradeTypeAlert(typeID);
          }
        });
  }

  final TextEditingController _textFieldController = TextEditingController();

  Widget newTypeAlert() {
    return AlertDialog(
      // To display the title it is optional
      title: const Text('Create new Grade Type'),
      // Message which will be pop up on the screen
      content: TextField(
        controller: _textFieldController..text = 'DefaultGradeName',
        //  controller: _textFieldController,
        decoration: const InputDecoration(hintText: "DefaultTypeName"),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('No!!!'),
        ),
        TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(calqColor),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            if (_textFieldController.text.isEmpty) {
              return;
            }
            DatabaseClass.Shared.addType(_textFieldController.text)
                .then((value) {
              setState(() {
                _shouldUpdate = !_shouldUpdate;
              });
              Navigator.of(context).pop();
            });
            _textFieldController.text = "DefaultGradeName";
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  Widget gradeTypeAlert(int typeID) {
    return AlertDialog(
      // To display the title it is optional
      title: const Text('Delete Grade Type'),
      // Message which will be pop up on the screen
      content: const Text('Do you really want to delete this Gradetype?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('No!!!'),
        ),
        TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            DatabaseClass.Shared.deleteType(typeID).then((value) {
              Navigator.of(context).pop();
              setState(() {
                _shouldUpdate = !_shouldUpdate;
              });
            });
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
