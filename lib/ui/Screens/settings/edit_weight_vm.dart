import 'package:calq_abiturnoten/database/Data_Type.dart';
import 'package:flutter/material.dart';

import '../../../database/database.dart';

class EditWeightViewModel with ChangeNotifier {
  List<Data_Type> _types = [];
  double _currentSum = 0.0;

  int _primaryType = -1;
  // Edit Weights
  int _selectedWeightIndex = 0;
  final List<String> _segments = ["10", "1", "0.1"];
  String _errorText = "";
  Map<int, double> _mappedWeights = {};

  Future<void> updateData() async {
    _primaryType = DatabaseClass.Shared.primaryType;
    _types = await DatabaseClass.Shared.getTypes();
    initSum();
    notifyListeners();
  }

  void initSum() {
    for (Data_Type type in _types) {
      _mappedWeights[type.assignedID] = type.weigth;
    }
    _currentSum = double.parse((_mappedWeights.values
            .fold(0.0, (previousValue, element) => previousValue + element))
        .toStringAsFixed(1));
  }

  void createType() async {
    _types = await DatabaseClass.Shared.getTypes();
  }

  void saveWeightChanges() {
    double finalValue = _currentSum;
    if (finalValue < 0.0 || finalValue > 100.0) {
      _errorText = "Value not in range 0...100";
      notifyListeners();
      return;
    }

    if (finalValue != 100.0) {
      _errorText = "Sum has to be 100.0";
      notifyListeners();
      return;
    }
  }

  void removeWeight(Data_Type type) {
    double value = double.parse(_segments[_selectedWeightIndex]);
    if (_currentSum - value < 0.0 ||
        (_mappedWeights[type.assignedID] ?? 0.0) - value < 0.0) {
      return;
    }

    _currentSum = _currentSum - value;
    _mappedWeights[type.assignedID] = _mappedWeights[type.assignedID]! - value;
    notifyListeners();
  }

  void addWeight(Data_Type type) {
    double value = double.parse(_segments[_selectedWeightIndex]);

    if (_currentSum + value > 100.0) {
      return;
    }

    _currentSum = _currentSum + value;
    _mappedWeights[type.assignedID] =
        (_mappedWeights[type.assignedID] ?? 0.0) + value;

    notifyListeners();
  }

  void favoriteType(Data_Type type) {
    DatabaseClass.Shared.updatePrimaryType(type.assignedID).then((value) {
      _primaryType = DatabaseClass.Shared.primaryType;
      notifyListeners();
    });
  }

  void removeType(int typeID) {
    DatabaseClass.Shared.deleteType(typeID).then((value) {
      notifyListeners();
    });
  }

  // Getter
  double get currentSum => _currentSum;

  Map<int, double> get mappedWeights => _mappedWeights;

  String get errorText => _errorText;

  List<String> get segments => _segments;

  int get selectedWeightIndex => _selectedWeightIndex;

  int get primaryType => _primaryType;

  List<Data_Type> get types => _types;

  // Setter
  set selectedWeightIndex(int value) {
    _selectedWeightIndex = value;
  }

  set mappedWeights(Map<int, double> value) {
    _mappedWeights = value;
  }
}
