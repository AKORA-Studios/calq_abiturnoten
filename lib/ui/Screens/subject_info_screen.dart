import 'package:flutter/material.dart';

import '../../database/Data_Subject.dart';
import '../../database/database.dart';

class SubjectInfoScreen extends StatefulWidget {
  const SubjectInfoScreen({super.key, required this.sub});

  final Data_Subject sub;

  @override
  State<SubjectInfoScreen> createState() => _SubjectInfoScreenState();
}

class _SubjectInfoScreenState extends State<SubjectInfoScreen> {
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
          title: Text(widget.sub.name),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text("${widget.sub.tests.length} Tests"),
              Column(
                children: widget.sub.tests
                    .map((e) => Text(e.name + " ${e.points}"))
                    .toList(),
              )
            ],
          ),
        ));
  }
}
