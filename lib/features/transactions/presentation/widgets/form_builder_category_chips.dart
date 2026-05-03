import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/features/categories/providers/category_provider.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';
import 'package:provider/provider.dart';

/// A [flutter_form_builder] field that displays categories as choice chips.
class FormBuilderCategoryChips extends StatelessWidget {
  /// Creates a [FormBuilderCategoryChips] field.
  const FormBuilderCategoryChips({
    required this.name,
    required this.type,
    super.key,
    this.initialValue,
  });

  /// The form field name used by [flutter_form_builder].
  final String name;

  /// The transaction type (expense/income) whose categories are shown.
  final TransactionType type;

  /// The initially selected category, or `null` if none.
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
          showCheckmark: false,
          options:
              (type == TransactionType.expense
                      ? categoryProvider.expenseCategories
                      : categoryProvider.incomeCategories)
                  .map(
                    (category) => FormBuilderChipOption<TransactionCategory>(
                      value: category,
                      avatar: Icon(category.icon),
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}
