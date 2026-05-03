import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

/// A Drift [TypeConverter] that maps Flutter [IconData] values to/from strings.
///
/// Serialises the icon as `codePoint,fontFamily,fontPackage`.
class IconDataConverter extends TypeConverter<IconData, String> {
  /// Creates a const [IconDataConverter].
  const IconDataConverter();

  @override
  IconData fromSql(String fromDb) {
    final parts = fromDb.split(',');
    if (parts.length != 3) {
      throw const FormatException('Invalid icon data format');
    }
    return IconData(
      int.parse(parts[0]),
      fontFamily: parts[1].isEmpty ? null : parts[1],
      fontPackage: parts[2].isEmpty ? null : parts[2],
    );
  }

  @override
  String toSql(IconData value) {
    return '${value.codePoint},${value.fontFamily ?? ''},${value.fontPackage ?? ''}';
  }
}
