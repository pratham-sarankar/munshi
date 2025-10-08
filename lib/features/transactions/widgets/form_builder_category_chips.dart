import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:munshi/features/transactions/models/transaction_category.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';

class FormBuilderCategoryChips extends StatelessWidget {
  const FormBuilderCategoryChips({
    super.key,
    required this.name,
    required this.type,
  });
  final String name;
  final TransactionType type;
  @override
  Widget build(BuildContext context) {
    return FormBuilderChoiceChips<TransactionCategory>(
      name: name,
      spacing: 5,
      runSpacing: 5,
      decoration: InputDecoration(
        filled: false,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      validator: FormBuilderValidators.required(
        errorText: 'Please select a category',
      ),
      options:
          (type == TransactionType.expense
                  ? expenseCategories
                  : incomeCategories)
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
  }
}
