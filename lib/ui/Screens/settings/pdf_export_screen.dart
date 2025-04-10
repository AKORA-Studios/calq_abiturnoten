import 'dart:convert';

import 'package:calq_abiturnoten/util/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class PDFExportScreen extends StatefulWidget {
  const PDFExportScreen({super.key});

  @override
  State<PDFExportScreen> createState() => _PDFExportScreenState();
}

class _PDFExportScreenState extends State<PDFExportScreen> {
  String _newContent = "";

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
    Share.shareXFiles(
      [
        XFile.fromData(
          utf8.encode(_newContent),
          name: 'flutter_logo.html',
          mimeType: 'text/plain',
        ),
      ],
      //  sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    ).then((value) {});

    /*
         Share.shareXFiles([
      XFile.fromData(utf8.encode(_newContent), mimeType: 'text/plain')
    ]); // fileNameOverrides: ['myfile.txt']
    * */
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
/*
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }*/
}
