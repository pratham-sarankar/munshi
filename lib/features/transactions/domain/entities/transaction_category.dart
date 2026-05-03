import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:munshi/core/enums/transaction_type.dart';

/// Represents a transaction category.
///
/// Contains category metadata like name, icon, color, and type.
class TransactionCategory extends Equatable {
  /// Creates a new [TransactionCategory] instance.
  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isDefault,
    required this.createdAt,
  });

  final int id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;
  final bool isDefault;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    color,
    type,
    isDefault,
    createdAt,
  ];

  TransactionCategory copyWith({
    int? id,
    String? name,
    IconData? icon,
    Color? color,
    TransactionType? type,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return TransactionCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
