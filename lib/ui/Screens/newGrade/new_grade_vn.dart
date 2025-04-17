import 'package:calq_abiturnoten/database/Data_Subject.dart';
import 'package:flutter/material.dart';

import '../../../database/Data_Test.dart';
import '../../../database/Data_Type.dart';
import '../../../database/database.dart';
import '../../components/util.dart';
import '../../components/widget_components.dart';

class NewGradeScreenViewModel with ChangeNotifier {
  ImpactSegmentData _impactSegmentData = ImpactSegmentData();
  int _selectedTypeIndex = -1;
  String _gradeName = "";
  int _selectedYear = 1;
  DateTime _selectedDate = DateTime.now();
  String errorText = "";
  double _testPoints = 0; // TODO: init average points for this term
  List<Data_Type> _types = [];

  Future<void> updateData(List<Data_Test> tests) async {
    _types = await DatabaseClass.Shared.getTypes();
    await updateImpactSegment(tests);
    _selectedYear = lastActiveYear(tests);
  }

  Future<void> addGrade(Data_Subject sub) async {
    if (_gradeName.isEmpty) {
      errorText = "Invalid Grade Name";
      notifyListeners();
      return;
    }

    if (_selectedTypeIndex < 0) {
      errorText = "Pls select a grade type";
      notifyListeners();
      return;
    }

    errorText = "";

    await DatabaseClass.Shared.createTest(
            sub.id,
            _gradeName,
            _testPoints.toInt(),
            _selectedYear,
            _selectedDate,
            _selectedTypeIndex)
        .then((value) {});
  }

  Future<void> updateImpactSegment(List<Data_Test> tests) async {
    var data = ImpactSegmentData();
    if (tests.isEmpty) {
      _impactSegmentData = data;
      return;
    }

    List<Data_Test> countedTests =
        tests.where((element) => element.year == _selectedYear).toList();
    if (countedTests.isEmpty) {
      _impactSegmentData = data;
      return;
    }

    int oldAverage = (await testAverage(countedTests)).round();
    int worseLast = 99;
    int betterLast = 0;
    int sameLast = 99;

    // calculate new average
    for (int i = 0; i < 16; i++) {
      int newAverage = 0;
      double gradeWeigths = 0.0;
      List<double> avgArr = [];

      for (Data_Type x in _types) {
        List<int> filtered = countedTests
            .where((e) => e.type == x.assignedID)
            .map((e) => e.points)
            .toList();

        double weight = x.weigth / 100;
        gradeWeigths += weight;

        if (x.assignedID == _selectedTypeIndex) {
          filtered.add(i);
        }

        double avg = average(filtered);
        avgArr.add(avg * weight);
      }

      double num = (avgArr.reduce((a, b) => a + b)) / gradeWeigths;
      newAverage = num.round();

      // update values & colors
      var str = newAverage.toString();
      if (oldAverage > newAverage) {
        if (worseLast == newAverage) {
          str = " ";
        }
        data.colors[i] = Colors.red;
        data.values[i] = str;
        worseLast = newAverage;
      } else if (newAverage > oldAverage) {
        if (betterLast == newAverage) {
          str = " ";
        }
        data.colors[i] = Colors.green;
        data.values[i] = str;
        betterLast = newAverage;
      } else {
        if (sameLast == oldAverage) {
          str = " ";
        }
        sameLast = oldAverage;
        data.colors[i] = Colors.grey;
        data.values[i] = str;
      }
    }
    _impactSegmentData = data;
  }

  // Getter
  ImpactSegmentData get impactSegmentData => _impactSegmentData;

  double get testPoints => _testPoints;

  DateTime get selectedDate => _selectedDate;

  int get selectedYear => _selectedYear;

  String get gradeName => _gradeName;

  int get selectedTypeIndex => _selectedTypeIndex;

  List<Data_Type> get types => _types;

  // Setter
  set testPoints(double value) {
    _testPoints = value;
  }

  set selectedDate(DateTime value) {
    _selectedDate = value;
  }

  set selectedYear(int value) {
    _selectedYear = value;
  }

  set gradeName(String value) {
    _gradeName = value;
  }

  set selectedTypeIndex(int value) {
    _selectedTypeIndex = value;
  }
}
