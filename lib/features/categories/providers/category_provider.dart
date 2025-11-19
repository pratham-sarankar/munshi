import 'package:flutter/material.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/database/daos/category_dao.dart';
import 'package:munshi/core/service_locator.dart';
import 'package:munshi/features/transactions/models/transaction_type.dart';

class CategoryProvider extends ChangeNotifier {

  CategoryProvider() {
    loadCategories();
  }
  final CategoriesDao _categoriesDao = locator<AppDatabase>().categoriesDao;

  List<TransactionCategory> _expenseCategories = [];
  List<TransactionCategory> _incomeCategories = [];
  bool _isLoading = false;

  List<TransactionCategory> get expenseCategories => _expenseCategories;
  List<TransactionCategory> get incomeCategories => _incomeCategories;
  bool get isLoading => _isLoading;

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

  Future<void> addCategory(TransactionCategoriesCompanion category) async {
    await _categoriesDao.insertCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(TransactionCategory category) async {
    await _categoriesDao.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _categoriesDao.deleteCategory(id);
    await loadCategories();
  }

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
