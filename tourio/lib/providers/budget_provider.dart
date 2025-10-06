import 'package:flutter/material.dart';

class BudgetProvider with ChangeNotifier {
  double _totalBudget = 10000.0;
  double _accommodationPercent = 40.0;
  double _activitiesPercent = 40.0;
  double _foodPercent = 20.0;

  double get totalBudget => _totalBudget;
  double get accommodationPercent => _accommodationPercent;
  double get activitiesPercent => _activitiesPercent;
  double get foodPercent => _foodPercent;

  void setBudget({
    required double totalBudget,
    required double accommodationPercent,
    required double activitiesPercent,
    required double foodPercent,
  }) {
    _totalBudget = totalBudget;
    _accommodationPercent = accommodationPercent;
    _activitiesPercent = activitiesPercent;
    _foodPercent = foodPercent;
    notifyListeners();
  }
}
