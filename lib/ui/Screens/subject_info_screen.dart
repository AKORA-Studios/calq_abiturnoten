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
      result.add(Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(children: [
                Text("$e. Halbjahr"),
                const Divider(),
                ...tests.map((e) => testRow(e, widget.sub)).toList()
              ]))));
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
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text("${widget.sub.tests.length} Tests"),
                const Text("Notenverlauf"),
                Center(
                    child: Container(
                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width - 20,
                        height: 150)),
                Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    // Define how the card's content should be clipped
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text("?. Halbjahr"), Text("Aktiv")],
                        ),
                        const Text("TODO Hier Segmentpicker"),
                        ElevatedButton(
                            onPressed: () {
                              print("TODO Deactivate Term");
                            },
                            child: const Text("Halbjahr deaktivieren"))
                      ],
                    )),
                ...halfYearWidget(),
                TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(color: Colors.red))),
                    ),
                    onPressed: () {
                      print("TODO: delete all grades");
                    },
                    child: const Text("Alle Noten löschen")),
              ],
            ),
          ),
        ));
  }
}
