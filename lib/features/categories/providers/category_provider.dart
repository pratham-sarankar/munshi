import 'package:flutter/material.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/enums/transaction_type.dart';
import 'package:munshi/core/service_locator.dart';
import 'package:munshi/features/transactions/data/datasources/category_local_datasource.dart';
import 'package:munshi/features/transactions/domain/entities/transaction_category.dart';

/// Manages the list of expense and income categories and exposes
/// CRUD operations to the UI.
class CategoryProvider extends ChangeNotifier {
  /// Creates a [CategoryProvider] and immediately loads all categories.
  CategoryProvider() {
    loadCategories();
  }
  final CategoryLocalDataSource _categoriesDao =
      locator<AppDatabase>().categoryLocalDataSource;

  List<TransactionCategory> _expenseCategories = [];
  List<TransactionCategory> _incomeCategories = [];
  bool _isLoading = false;

  /// All expense categories loaded from the database.
  List<TransactionCategory> get expenseCategories => _expenseCategories;

  /// All income categories loaded from the database.
  List<TransactionCategory> get incomeCategories => _incomeCategories;

  /// Whether categories are currently being loaded.
  bool get isLoading => _isLoading;

  /// Loads all expense and income categories from the database.
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenseCategories = await _categoriesDao.getExpenseCategories();
      _incomeCategories = await _categoriesDao.getIncomeCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Inserts a new [category] into the database and refreshes the list.
  Future<void> addCategory(TransactionCategoriesCompanion category) async {
    await _categoriesDao.insertCategory(category);
    await loadCategories();
  }

  /// Updates an existing [category] in the database and refreshes the list.
  Future<void> updateCategory(TransactionCategory category) async {
    await _categoriesDao.updateCategory(category);
    await loadCategories();
  }

  /// Deletes the category with the given [id] and refreshes the list.
  Future<void> deleteCategory(int id) async {
    await _categoriesDao.deleteCategory(id);
    await loadCategories();
  }

  /// Returns `true` if a category named [name] of [type] already exists.
  ///
  /// Pass [excludeId] to ignore a specific category (useful when editing).
  Future<bool> categoryNameExists(
    String name,
    TransactionType type, {
    int? excludeId,
  }) async {
    return _categoriesDao.categoryNameExists(
      name,
      type,
      excludeId: excludeId,
    );
  }
}
