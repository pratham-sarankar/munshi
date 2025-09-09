import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/transactions/widgets/expense_form.dart';
import 'package:munshi/features/transactions/widgets/income_form.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({
    super.key,
    required this.onSubmit,
    this.transaction,
  });
  final Transaction? transaction;
  final Function(Insertable<Transaction> transaction) onSubmit;
  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      animationDuration: const Duration(milliseconds: 500),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Iconsax.arrow_left_outline),
          ),
          title: Text("Add Transaction"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Expense"),
              Tab(text: "Income"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 20, left: 20, top: 20),
              child: ExpenseForm(
                transaction: widget.transaction,
                onSubmit: widget.onSubmit,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20, left: 20, top: 20),
              child: IncomeForm(),
            ),
          ],
        ),
      ),
    );
  }
}
