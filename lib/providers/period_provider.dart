import 'package:flutter/material.dart';
import 'package:munshi/core/models/period_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the user's default dashboard period type and persists it.
class PeriodProvider extends ChangeNotifier {
  /// Creates a PeriodProvider and loads the period synchronously from SharedPreferences.
  PeriodProvider(this.prefs) {
    _loadPeriodFromPrefs();
  }
  static const String _defaultPeriodKey = 'default_period';

  PeriodType _defaultPeriod = PeriodType.monthly;

  /// The user's preferred default period type.
  PeriodType get defaultPeriod => _defaultPeriod;

  /// Human-readable display name for the current default period.
  String get defaultPeriodDisplayName => _defaultPeriod.displayName;

  /// The [SharedPreferences] instance used to persist the period.
  final SharedPreferences prefs;

  /// Sets the default period type and persists the change.
  void setDefaultPeriod(PeriodType period) {
    if (_defaultPeriod != period) {
      _defaultPeriod = period;
      _savePeriodToPrefs();
      notifyListeners();
    }
  }

  /// Sets the default period by matching [displayName] to a [PeriodType].
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
