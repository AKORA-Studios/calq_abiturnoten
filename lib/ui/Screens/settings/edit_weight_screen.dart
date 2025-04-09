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
                      child: const Text("Typ hinzufügen"))
                ]))));
  }

  Widget typeRow(Data_Type type) {
    return card(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("${type.name} [${type.assignedID}]: ${type.weigth}"),
        IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return deleteAlert(type.assignedID);
                  });
            },
            icon: const Icon(Icons.delete, color: Colors.red))
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
              content:
                  const Text("Type is still used by gardes so it cant be deleted"),
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
