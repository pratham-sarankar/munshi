import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

/// A Drift [TypeConverter] that maps Flutter [Color] values to/from integers.
///
/// Stores the color as a 32-bit ARGB integer in the database.
class ColorConverter extends TypeConverter<Color, int> {
  /// Creates a const [ColorConverter].
  const ColorConverter();

  @override
  Color fromSql(int fromDb) {
    return Color(fromDb);
  }

  @override
  int toSql(Color value) {
    return value.toARGB32();
  }
}
