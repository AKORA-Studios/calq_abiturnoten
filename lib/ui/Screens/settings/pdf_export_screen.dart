import 'dart:io';

import 'package:calq_abiturnoten/util/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class PDFExportScreen extends StatefulWidget {
  const PDFExportScreen({super.key});

  @override
  State<PDFExportScreen> createState() => _PDFExportScreenState();
}

class _PDFExportScreenState extends State<PDFExportScreen> {
  String _newContent = "";
  final String _fileName = "a.html";

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
      share();
    });
  }

  void share() {
    getTemporaryDirectory().then((tempDir) {
      final File file = File('${tempDir.path}/$_fileName');
      file.writeAsString(_newContent);

      Share.shareFiles(['${tempDir.path}/$_fileName'], text: 'Great picture');
    });
  }

  void createTempFile(String content) {
    getTemporaryDirectory().then((tempDir) {
      final File file = File('${tempDir.path}/$_fileName');
      return file.writeAsString(content);
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
