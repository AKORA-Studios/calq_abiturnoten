import 'package:flutter/material.dart';

import '../../database/database.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  List<String> subs = ["x", "y"];

  @override
  void initState() {
    // TODO: implement initState

    DatabaseClass.Shared.getSubjectsList().then((value) {
      print(value);
      /*
       DatabaseClass.Shared.createTest(1).then((value) {
        print("ffffff");
      });*/
      setState(() {
        subs[0] = value.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Overview"),
        ),
        body: ListView(
          children: [
            Text(subs.join(", ")),
            Text("Anzahl Prüfungen"),
            Text("Regenbogen")
          ],
        ));
  }
}
