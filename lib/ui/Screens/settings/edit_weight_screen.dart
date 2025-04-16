import 'package:calq_abiturnoten/ui/Screens/settings/edit_weight_vm.dart';
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
  EditWeightViewModel _viewmodel = EditWeightViewModel();
  bool _shouldUpdate = false;
  bool _notInitialized = true;

  @override
  void initState() {
    super.initState();
    _viewmodel.updateData().then((value) {
      setState(() {});
    });
  }

  void saveWeightChanges() {
    _viewmodel.saveWeightChanges();

    DatabaseClass.Shared.editTypeWeights(_viewmodel.mappedWeights)
        .then((value) {
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
                  Column(
                      children:
                          _viewmodel.types.map((e) => typeRow(e)).toList()),
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
    _viewmodel.segments.asMap().forEach((index, value) {
      buttons.add(ButtonSegment<int>(
        value: index,
        label: Text(value),
      ));
    });

    return [
      SegmentedButton<int>(
        showSelectedIcon: false,
        style: calqSegmentedButtonStyle(),
        segments: buttons,
        selected: <int>{_viewmodel.selectedWeightIndex},
        onSelectionChanged: (Set<int> newSelection) {
          _viewmodel.selectedWeightIndex = newSelection.first;
          setState(() {});
        },
      ),
      typeRows(),
      _viewmodel.currentSum.roundToDouble() != 100.0
          ? Text("Gesamt: ${_viewmodel.currentSum}%",
              style: TextStyle(color: Colors.red))
          : Text("Gesamt: ${_viewmodel.currentSum}%"),
      ElevatedButton(
          onPressed: () {
            saveWeightChanges();
          },
          child: const Text("Save Weight Changes")),
      Text(
        _viewmodel.errorText,
        style: const TextStyle(color: Colors.red),
      )
    ];
  }

  Widget typeRows() {
    List<Widget> children = [];
    _viewmodel.types.asMap().forEach((index, e) {
      if (_notInitialized) {
        _viewmodel.mappedWeights[e.assignedID] = e.weigth;
      }

      children.add(typeEditRow(e));
    });
    // setState(() {
    _notInitialized = false;
    //   });

    return Column(children: children);
  }

  Widget typeEditRow(Data_Type type) {
    return card(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("${type.name} [${type.assignedID}]"),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text((_viewmodel.mappedWeights[type.assignedID] ?? 0.0)
                .toStringAsFixed(1)),
            IconButton(
                onPressed: () {
                  _viewmodel.removeWeight(type);
                  setState(() {});
                },
                icon: const Icon(Icons.remove)),
            IconButton(
                onPressed: () {
                  _viewmodel.addWeight(type);
                  setState(() {});
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
                      _viewmodel.favoriteType(type);
                      setState(() {});
                    },
                    icon: Icon(Icons.star,
                        color: _viewmodel.primaryType == type.assignedID
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
            return deleteTypeAlert(typeID);
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
              _viewmodel.createType();
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

  Widget deleteTypeAlert(int typeID) {
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
            _viewmodel.removeType(typeID);
            Navigator.of(context).pop();
            setState(() {});
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
