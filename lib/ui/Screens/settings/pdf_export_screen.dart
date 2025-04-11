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
    fillTemplate();
  }

  void fillTemplate() {
    loadTemplate().then((value) {
      String htmlFileContent = value;
      htmlFileContent =
          htmlFileContent.replaceAll("#DATE#", formatDate(DateTime.now()));

      setState(() {
        _newContent = htmlFileContent;
      });
      test1(_newContent, _fileName);
    });
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
