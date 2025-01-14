import 'package:flutter/material.dart';

import '../../database/database.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  String subs = "xx";

  @override
  void initState() {
    // TODO: implement initState

    DatabaseClass.Shared.getSubjects().then((value) {
      print(value);
      /*
       DatabaseClass.Shared.createTest(1).then((value) {
        print("ffffff");
      });*/
      setState(() {
        subs = value.toString().replaceAll("Data_Subject", "\nData_Subject");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Overview"),
        ),
        body: ListView(
          children: [Text(subs)],
        ));
  }
}
