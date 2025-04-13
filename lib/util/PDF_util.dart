import 'dart:io';

import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

void tempSavePDF(String newContent, String fileName) {
  getTemporaryDirectory().then((tempDir) {
    final File file = File('${tempDir.path}/$fileName');

    final newPdf = Document();
    HTMLToPdf().convert(newContent).then((widgets) {
      newPdf.addPage(MultiPage(
          maxPages: 200,
          build: (context) {
            return widgets;
          }));
      newPdf.save().then((value) {
        file.writeAsBytes(value);
        Share.shareFiles([(file.path)], text: 'Great PDF Data!');
      });
    });
  });
}
