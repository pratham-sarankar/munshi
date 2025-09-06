import 'package:flutter/material.dart';

class Transaction {
  final String merchant;
  final double amount;
  final String date;
  final String time;
  final String category;
  final IconData icon;
  final Color color;

  Transaction({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.time,
    required this.category,
    required this.icon,
    required this.color,
  });
}
