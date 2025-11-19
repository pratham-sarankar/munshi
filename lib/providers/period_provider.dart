import 'package:flutter/material.dart';
import 'package:munshi/core/models/period_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeriodProvider extends ChangeNotifier {

  /// Creates a PeriodProvider and loads the period synchronously from SharedPreferences.
  PeriodProvider(this.prefs) {
    _loadPeriodFromPrefs();
  }
  static const String _defaultPeriodKey = 'default_period';

  PeriodType _defaultPeriod = PeriodType.monthly;

  PeriodType get defaultPeriod => _defaultPeriod;
  String get defaultPeriodDisplayName => _defaultPeriod.displayName;

  final SharedPreferences prefs;

  void setDefaultPeriod(PeriodType period) {
    if (_defaultPeriod != period) {
      _defaultPeriod = period;
      _savePeriodToPrefs();
      notifyListeners();
    }
  }

  void setDefaultPeriodByDisplayName(String displayName) {
    final period = PeriodType.values.firstWhere(
      (p) => p.displayName == displayName,
      orElse: () => PeriodType.monthly,
    );
    setDefaultPeriod(period);
  }

  void _loadPeriodFromPrefs() {
    final periodName = prefs.getString(_defaultPeriodKey);
    if (periodName != null) {
      final period = PeriodType.values.firstWhere(
        (p) => p.name == periodName,
        orElse: () => PeriodType.monthly,
      );
      _defaultPeriod = period;
      notifyListeners();
    }
  }

  Future<void> _savePeriodToPrefs() async {
    await prefs.setString(_defaultPeriodKey, _defaultPeriod.name);
  }
}
