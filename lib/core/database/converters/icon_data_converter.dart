import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

class IconDataConverter extends TypeConverter<IconData, String> {
  const IconDataConverter();

  @override
  IconData fromSql(String fromDb) {
    final parts = fromDb.split(',');
    if (parts.length != 3) throw const FormatException('Invalid icon data format');
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
