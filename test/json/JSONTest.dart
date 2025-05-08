import 'dart:io';

import 'package:calq_abiturnoten/util/JSON_util.dart';
import 'package:flutter_test/flutter_test.dart';
/*
class JSONTest {
  final sut = JSONUtil();

  void main() async {
    testImport();
  }

  void testImport() async {
    final file = new File('test_resources/data.json');
    String data = await file.readAsString();
    sut.importJSON(data);
    return;
  }
}

* */

void main() {
  group("[JSON Tests]", () {
    final sut = JSONUtil();

    test("importV3", () async {
      final file = File('test_resources/data.json');
      String data = await file.readAsString();
      //  print(data);
      sut.importJSON(data, shouldAddData: false);
      //    when(sut.importJSON(data)).thenAnswer((_) => Future.value());
    });
  });
}
