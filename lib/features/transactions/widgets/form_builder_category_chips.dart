import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/features/categories/providers/category_provider.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';
import 'package:provider/provider.dart';

class FormBuilderCategoryChips extends StatelessWidget {
  const FormBuilderCategoryChips({
    required this.name, required this.type, super.key,
    this.initialValue,
  });
  final String name;
  final TransactionType type;
  final TransactionCategory? initialValue;
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        return FormBuilderChoiceChips<TransactionCategory>(
          name: name,
          initialValue: initialValue,
          spacing: 5,
          runSpacing: 5,
          decoration: const InputDecoration(
            filled: false,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          options:
              (type == TransactionType.expense
                      ? categoryProvider.expenseCategories
                      : categoryProvider.incomeCategories)
                  .map(
                    (category) => FormBuilderChipOption<TransactionCategory>(
                      value: category,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(category.icon, size: 16),
                          const SizedBox(width: 4),
                          Text(category.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}
