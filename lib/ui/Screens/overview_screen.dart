import 'package:flutter/material.dart';

import '../../database/database.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  String subs = "xx";
  late List<String> xAxisList;
  late List<double> yAxisList;

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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text(subs),
              Center(
                  child: Container(
                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width - 20,
                      height: 250)),
              const SizedBox(height: 20),
              Center(
                  child: Container(
                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width - 20,
                      height: 150)),
              const SizedBox(height: 20),
              Center(
                  child: Container(
                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width - 20,
                      height: 150)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      color: Colors.grey,
                      width: (MediaQuery.of(context).size.width / 2) - 20,
                      height: 150),
                  Container(
                      color: Colors.grey,
                      width: (MediaQuery.of(context).size.width / 2) - 20,
                      height: 150)
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ));
  }
}
