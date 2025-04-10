import 'dart:io';

import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

void test1(String _newContent, String _fileName) {
  getTemporaryDirectory().then((tempDir) {
    final File file = File('${tempDir.path}/$_fileName');

    final newpdf = Document();
    HTMLToPdf().convert(_newContent).then((widgets) {
      newpdf.addPage(MultiPage(
          maxPages: 200,
          build: (context) {
            return widgets;
          }));
      newpdf.save().then((value) {
        file.writeAsBytes(value);
        Share.shareFiles(['${file.path}'], text: 'Great picture');
      });
    });
  });
}
