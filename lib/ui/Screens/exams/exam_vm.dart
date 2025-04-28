import 'package:calq_abiturnoten/ui/components/util.dart';
import 'package:flutter/material.dart';

import '../../../database/Data_Subject.dart';
import '../../../database/database.dart';

class ExamViewViewModel with ChangeNotifier {
  double _block1Value = 0.0;
  double _block2Value = 0.0;
  int _maxBlock1Value = 600;

  List<Data_Subject> _examOptions = [];
  Map<int, Data_Subject> _exams = {};
  Map<int, int> _examPoints = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  Future<void> updateData() async {
    _examOptions = await getExamOptions();
    for (int i = 1; i < 6; i++) {
      Data_Subject? sub = await getExam(i);
      if (sub != null) {
        _exams[i] = sub;
        _examPoints[i] = sub.exampoints;
      }
    }

    updateBlock2Values();
    updateBlock1Values();

    notifyListeners();
  }

  void updateBlock2Values() {
    _block2Value = calculateBlock2();
    notifyListeners();
  }

  void updateBlock1Values() {
    generateBlockOne().then((value) {
      _block1Value = value + 0.0;
      notifyListeners();
    });
  }

  void chooseExam(Data_Subject sub, int type) async {
    _examOptions =
        _examOptions.where((element) => element.id != sub.id).toList();
    _exams[type] = sub;

    if (sub.examtype == 0) {
      await DatabaseClass.Shared.updateSubjectExam(sub, type);
    } else {
      await DatabaseClass.Shared.updateExamPoints(0, sub);
    }

    sub.exampoints = 0;
    sub.examtype = type;
    _exams[type] = sub;

    notifyListeners();
  }

  void removeExam(Data_Subject sub, int i) async {
    _exams.remove(i);
    await DatabaseClass.Shared.removeExam(i);
    _examOptions.add(sub);
    updateBlock2Values();

    notifyListeners();
    _examPoints[i] = 0;
  }

  void updateSlider(double value, Data_Subject sub) async {
    await DatabaseClass.Shared.updateExamPoints(value.round(), sub);
    updateBlock2Values();
    sub.exampoints = value.round();
    _exams[sub.examtype] = sub;
    _examPoints[sub.examtype] = value.round();
    notifyListeners();
    notifyListeners();
  }

  // Getter
  List<Data_Subject> get examOptions => _examOptions;

  int get maxBlock1Value => _maxBlock1Value;

  double get block2Value => _block2Value;

  double get block1Value => _block1Value;

  Map<int, Data_Subject> get exams => _exams;

  Map<int, int> get examPoints => _examPoints;
}
