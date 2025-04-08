import 'package:flutter/material.dart';

import '../../../database/Data_Type.dart';
import '../../../database/database.dart';

// TODO: reload data on change
class EditWeightScreen extends StatefulWidget {
  const EditWeightScreen(
      {super.key, required this.types, required this.callbackFunc});
  final List<Data_Type> types;
  final VoidCallback callbackFunc;
  @override
  State<EditWeightScreen> createState() => _EditWeightScreenState();
}

class _EditWeightScreenState extends State<EditWeightScreen> {
  bool _shouldUpdateView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Edit Weights"),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Text("huh"),
            ...widget.types.map((e) => typeRow(e)).toList(),
            ElevatedButton(
                onPressed: () {
                  print("Test");
                  DatabaseClass.Shared.addType().then((value) {
                    Navigator.pop(context);
                  });
                },
                child: Text("Typ hinzufügen"))
          ]),
        ));
  }

  Widget typeRow(Data_Type type) {
    return FutureBuilder(
        future: DatabaseClass.Shared.getTypeGrades(type.id),
        builder: (ctx, snap) {
          if (snap.hasError || !snap.hasData) {
            return Text("Smth went wrong with: ${type.name}");
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${type.name}[${type.assignedID}]: ${type.weigth}"),
                IconButton(
                    onPressed: snap.data!.isEmpty
                        ? () {
                            showDialog(
                                context: context,
                                builder: (ctx) {
                                  return gradeTypeAlert(type.id);
                                });
                          }
                        : null,
                    icon: Icon(Icons.delete,
                        color: snap.data!.isEmpty ? Colors.red : Colors.grey))
              ],
            );
          }
        });
  }

  // MARK: Functions
  Widget gradeTypeAlert(int typeID) {
    return AlertDialog(
      // To display the title it is optional
      title: Text('Delete Grade Type'),
      // Message which will be pop up on the screen
      content: Text('Do you really want to delete this Gradetype?'),
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
            DatabaseClass.Shared.deleteType(typeID).then((value) {
              Navigator.of(context).pop();
              widget.callbackFunc();
            });
          },
          child: Text('Delete'),
        ),
      ],
    );
  }
}
//Circle1: _averageText + _gradeText [_averagePercent]
//Circle2: _blockCircleText [_blockPercent]
