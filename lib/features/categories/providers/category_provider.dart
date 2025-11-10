import 'package:flutter/material.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/database/daos/category_dao.dart';
import 'package:munshi/core/service_locator.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoriesDao _categoriesDao = locator<AppDatabase>().categoriesDao;

  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];
  bool _isLoading = false;

  List<Category> get expenseCategories => _expenseCategories;
  List<Category> get incomeCategories => _incomeCategories;
  bool get isLoading => _isLoading;

  CategoryProvider() {
    loadCategories();
  }

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

  Future<void> addCategory(CategoriesCompanion category) async {
    await _categoriesDao.insertCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _categoriesDao.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _categoriesDao.deleteCategory(id);
    await loadCategories();
  }

  Future<bool> categoryNameExists(
    String name,
    String type, {
    int? excludeId,
  }) async {
    return await _categoriesDao.categoryNameExists(
      name,
      type,
      excludeId: excludeId,
    );
  }
}
