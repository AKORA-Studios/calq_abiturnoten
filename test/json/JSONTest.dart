import 'dart:io';

import 'package:calq_abiturnoten/util/JSON_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("[JSON Tests]", () {
    final sut = JSONUtil();

    test("importV3", () async {
      final file = File('test_resources/data.json');
      String data = await file.readAsString();
      sut.importJSON(data, shouldAddData: false);
    });
  });
}
