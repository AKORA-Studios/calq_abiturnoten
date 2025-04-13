import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:calq_abiturnoten/database/database.dart';
import 'package:calq_abiturnoten/ui/components/util.dart';
import 'package:calq_abiturnoten/util/averages.dart';
import 'package:calq_abiturnoten/util/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../util/PDF_util.dart';

class PDFExportScreen extends StatefulWidget {
  const PDFExportScreen({super.key});

  @override
  State<PDFExportScreen> createState() => _PDFExportScreenState();
}

class _PDFExportScreenState extends State<PDFExportScreen> {
  String _newContent = "";
  final String _fileName = "a.pdf";

  @override
  void initState() {
    super.initState();
    fillTemplate().then((value) {});
  }

  Future<void> fillTemplate() async {
    PDFData data = await fetchData();
    String template = await loadTemplate();

    String htmlFileContent = template;
    htmlFileContent =
        htmlFileContent.replaceAll("#DATE#", formatDate(DateTime.now()));
    htmlFileContent.replaceAll("#FINAL_GRADE#", data.toString());
    htmlFileContent.replaceAll("#FINAL_GRADE2#", data.finalgrade);

    // Header Localization
    htmlFileContent.replaceAll("#SUBJECT_HEADING#", "Subject");
    htmlFileContent.replaceAll("#TERMS_HEADING#", "Terms");
    htmlFileContent.replaceAll("#NUMBER_HEADING#", "Number");
    htmlFileContent.replaceAll("#POINTS_HEADING#", "Points");
    htmlFileContent.replaceAll("#CREATED_AT_HEADING#", "Created at");

    // table
    var allItems = "";
    for (int i = 0; i < data.items.length; i++) {
      String itemHTMLContent = await loadRowTemplate();

      itemHTMLContent =
          itemHTMLContent.replaceAll("#TITLE#", data.items[i].title);
      itemHTMLContent =
          itemHTMLContent.replaceAll("#CONTENT1#", data.items[i].content[0]);
      itemHTMLContent =
          itemHTMLContent.replaceAll("#CONTENT2#", data.items[i].content[1]);
      itemHTMLContent =
          itemHTMLContent.replaceAll("#CONTENT3#", data.items[i].content[2]);
      itemHTMLContent =
          itemHTMLContent.replaceAll("#CONTENT4#", data.items[i].content[3]);

      itemHTMLContent =
          itemHTMLContent.replaceAll("#AVERAGE#", data.items[i].average);
      itemHTMLContent =
          itemHTMLContent.replaceAll("#GRADE#", data.items[i].grade);

      allItems += itemHTMLContent;
    }

    // finals
    var finals = "";
    if (data.exams.isNotEmpty) {
      // show table
      htmlFileContent = htmlFileContent.replaceAll("hiddenTable", "");
      // add exams
      for (int i = 0; i < data.exams.length; i++) {
        String itemHTMLContent = await load2RowTemplate();

        itemHTMLContent =
            itemHTMLContent.replaceAll("#TITLE#", data.exams[i].title);
        itemHTMLContent =
            itemHTMLContent.replaceAll("#TYPE#", data.exams[i].num.toString());
        itemHTMLContent =
            itemHTMLContent.replaceAll("#POINTS#", data.exams[i].points);
        finals += itemHTMLContent;
      }
    }

    htmlFileContent = htmlFileContent.replaceAll("#EXAMITEMS#", finals);
    htmlFileContent = htmlFileContent.replaceAll("#ITEMS#", allItems);

    setState(() {
      _newContent = htmlFileContent;
    });
    tempSavePDF(_newContent, _fileName);
  }

  Future<PDFData> fetchData() async {
    PDFData data = PDFData();
    List<PDFItem> items = [];
    List<Data_Subject> subjects = await DatabaseClass.Shared.getSubjects();
    double genAverage = await generalAverage();
    data.subjectsgrade = grade(genAverage).toStringAsFixed(2);
    data.subjectpoints = genAverage.toStringAsFixed(2);
    data.finalgrade =
        genAverage.toStringAsFixed(2); // TODO: chekc if correct also on ios

    // Items
    for (Data_Subject subject in subjects) {
      var averageString = await Averages.getSubjectYearString(subject);
      int average = 0;
      for (var element in averageString) {
        average += int.tryParse(element) ?? 0;
      }
      data.items.add(PDFItem(subject.name, averageString, averageString[4],
          (average / 4).toString()));
    }

    // Exams
    for (int index = 1; index < 6; index++) {
      List<Data_Subject> exams =
          subjects.where((element) => element.examtype == index).toList();
      if (exams.isNotEmpty) {
        data.exams.add(PDFExam(exams[0].name, (index == 1 || index == 2),
            exams[0].exampoints.toString(), index));
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("PDF Export"),
        ),
        body: SingleChildScrollView(child: Text(_newContent)));
  }

  // MARK: File Util
  Future<String> loadTemplate() async {
    return await rootBundle.loadString('assets/pdf/template.html');
  }

  Future<String> loadRowTemplate() async {
    return await rootBundle.loadString('assets/pdf/row.html');
  }

  Future<String> load2RowTemplate() async {
    return await rootBundle.loadString('assets/pdf/row2.html');
  }
}

class PDFData {
  String subjectsgrade = "?";
  String subjectpoints = "?";
  String finalgrade = "?";
  List<PDFItem> items = [];
  List<PDFExam> exams = [];

  String toString() {
    return subjectsgrade + " (" + subjectpoints + ")";
  }
}

class PDFExam {
  String title = "?";
  bool primary = false;
  String points = "?";
  int num = -1;

  PDFExam(this.title, this.primary, this.points, this.num);
}

class PDFItem {
  String title = "?";
  List<String> content = [];
  String grade = "?";
  String average = "?";

  PDFItem(this.title, this.content, this.grade, this.average);
}
