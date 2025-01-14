import 'package:flutter/material.dart';

import '../../database/Data_Subject.dart';
import '../../database/database.dart';
import '../components/util.dart';

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

    DatabaseClass.Shared.getSubjects().then((value) {
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

  List<Widget> halfYearWidget() {
    List<Widget> result = [];
    [1, 2, 3, 4].map((e) {
      var tests =
          widget.sub.tests.where((element) => element.year == e).toList();
      if (tests.isEmpty) {
        return;
      }
      result.add(Column(children: [
        Text("$e. Halbjahr"),
        Divider(),
        ...tests.map((e) => testRow(e, widget.sub)).toList()
      ]));
    }).toList();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.sub.name),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text("${widget.sub.tests.length} Tests"),
                ...halfYearWidget(),
              ],
            ),
          ),
        ));
  }
}
