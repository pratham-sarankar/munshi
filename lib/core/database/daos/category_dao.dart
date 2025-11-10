import 'package:drift/drift.dart';
import 'package:munshi/core/database/app_database.dart';
import 'package:munshi/core/database/tables/categories.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  // Get all categories
  Future<List<Category>> getAllCategories() => select(categories).get();

  // Get categories by type
  Future<List<Category>> getCategoriesByType(String type) =>
      (select(categories)..where((tbl) => tbl.type.equals(type))).get();

  // Get expense categories
  Future<List<Category>> getExpenseCategories() =>
      getCategoriesByType('expense');

  // Get income categories
  Future<List<Category>> getIncomeCategories() => getCategoriesByType('income');

  // Get category by id
  Future<Category?> getCategoryById(int id) =>
      (select(categories)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  // Insert category
  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  // Update category
  Future<bool> updateCategory(Category category) =>
      update(categories).replace(category);

  // Delete category
  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((tbl) => tbl.id.equals(id))).go();

  // Check if category name exists
  Future<bool> categoryNameExists(
    String name,
    String type, {
    int? excludeId,
  }) async {
    final query = select(categories)
      ..where((tbl) => tbl.name.equals(name) & tbl.type.equals(type));

    if (excludeId != null) {
      query.where((tbl) => tbl.id.equals(excludeId).not());
    }

    final result = await query.getSingleOrNull();
    return result != null;
  }
}
