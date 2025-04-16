import 'package:calq_abiturnoten/database/database.dart';
import 'package:flutter/material.dart';

import '../../../database/Data_Subject.dart';

class SubjectsScreenViewModel with ChangeNotifier {
  int _inactiveCount = 0;
  int _subjectCount = 0;
  List<Data_Subject> _subjects = [];

  Future<void> updateData() async {
    _subjects = await DatabaseClass.Shared.getSubjects();
    _inactiveCount = (_subjects.length * 4) - calcInactiveYearsCount(subjects);
    _subjectCount = _subjects.length * 4;

    notifyListeners();
  }

  int calcInactiveYearsCount(List<Data_Subject> subjects) {
    if (subjects.isEmpty) {
      return 0;
    }
    int count = 0;

    for (Data_Subject sub in subjects) {
      var arr = sub.getInactiveTerms();
      for (String num in arr) {
        if (num == "") {
          continue;
        }
        if (!int.parse(num).isNaN) {
          count += 1;
        }
      }
    }
    return count;
  }

  // Getter
  int get subjectCount => _subjectCount;

  int get inactiveCount => _inactiveCount;

  List<Data_Subject> get subjects => _subjects;
}
