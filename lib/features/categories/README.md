# Categories Feature

This directory contains the complete categories management feature for the Munshi app.

## 📁 Directory Structure

```
categories/
├── providers/
│   └── category_provider.dart        (55 lines)  - State management
├── screens/
│   └── categories_screen.dart        (240 lines) - Main screen with tabs
├── widgets/
│   ├── add_edit_category_dialog.dart (323 lines) - Add/edit form dialog
│   ├── category_list_tile.dart       (141 lines) - List item widget
│   ├── color_picker_dialog.dart      (187 lines) - Color picker
│   └── icon_picker_dialog.dart       (258 lines) - Icon picker
└── README.md                         (this file)
```

**Total:** 1,204 lines of production code

## 🎯 Purpose

Provides a complete categories management system allowing users to:
- Create custom expense and income categories
- Edit category names, icons, and colors
- Delete user-created categories
- View categories organized by type (expense/income)

## ✨ Features

### CategoryProvider (State Management)
- Manages lists of expense and income categories
- Provides CRUD operations
- Handles loading states
- Validates category names
- Automatically refreshes data after changes

### CategoriesScreen (Main UI)
- Tab-based interface for expense and income
- Beautiful Material Design 3 cards
- Floating action button for quick add
- Empty states with helpful messages
- Smooth animations and transitions

### AddEditCategoryDialog
- Form for creating/editing categories
- Name input with validation
- Icon selector (opens IconPickerDialog)
- Color selector (opens ColorPickerDialog)
- Real-time preview of selections
- Duplicate name detection

### IconPickerDialog
- Grid of 80+ curated Iconsax icons
- Search functionality (ready for enhancement)
- Visual selection highlighting
- Scrollable interface
- Icons organized by category

### ColorPickerDialog
- 35+ Material Design colors
- Large preview section
- Grid layout for easy browsing
- Visual selection feedback
- Checkmark on selected color

### CategoryListTile
- Icon container with category color
- Category name display
- "Default" badge for default categories
- Edit and delete action buttons
- Delete disabled for default categories
- Smooth animations on tap

## 🔌 Integration

### Dependencies
```dart
// In main.dart
ChangeNotifierProvider(
  create: (_) => CategoryProvider(),
)

// In screens
Consumer<CategoryProvider>(
  builder: (context, provider, child) {
    // Use provider.expenseCategories
    // Use provider.incomeCategories
  },
)
```

### Navigation
The CategoriesScreen is integrated into the main navigation via `main_screen.dart`.

### Database
Uses `CategoriesDao` from `core/database/daos/category_dao.dart` for all database operations.

## 📊 Data Model

Categories are stored in the database with:
- `id` - Primary key
- `name` - Category name
- `iconCodePoint` - Icon code point
- `iconFontFamily` - Font family (nullable)
- `iconFontPackage` - Package name (nullable)
- `colorValue` - Color as integer
- `type` - 'expense' or 'income'
- `isDefault` - Boolean flag
- `createdAt` - Timestamp

## 🎨 UI Guidelines

### Colors
- Icon container background: category color at 10% opacity
- Icon container border: category color at 30% opacity
- Icon: full category color
- Cards: Material Design 3 surface colors

### Spacing
- Card padding: 16px
- Icon container: 48x48px
- Border radius: 16px (cards), 12px (containers)
- List item margin: 8px bottom

### Typography
- Category name: Title Medium, SemiBold
- Default badge: Label Small, SemiBold
- Dialog title: Title Large, Bold

## 🔄 Usage Flow

### Adding a Category
```dart
// User taps FAB
showDialog(
  context: context,
  builder: (context) => AddEditCategoryDialog(type: 'expense'),
);

// After form submission
await context.read<CategoryProvider>().addCategory(category);
```

### Editing a Category
```dart
// User taps edit button
showDialog(
  context: context,
  builder: (context) => AddEditCategoryDialog(
    type: 'expense',
    category: existingCategory,
  ),
);

// After form submission
await context.read<CategoryProvider>().updateCategory(category);
```

### Deleting a Category
```dart
// User taps delete button → confirmation dialog
await context.read<CategoryProvider>().deleteCategory(categoryId);
```

## 🛠️ Development

### Adding New Features

**To add more icons:**
Edit `icon_picker_dialog.dart` and add icons to the `_icons` list.

**To add more colors:**
Edit `color_picker_dialog.dart` and add colors to the `_colors` list.

**To modify validation:**
Edit validation logic in `add_edit_category_dialog.dart` and `category_provider.dart`.

### Testing

Test scenarios:
1. Add category with valid data
2. Add category with duplicate name (should fail)
3. Edit category name, icon, and color
4. Delete user-created category
5. Try to delete default category (should be disabled)
6. Switch between expense and income tabs
7. Test empty states
8. Test loading states

## 📚 Documentation

See root documentation files:
- **QUICKSTART.md** - Quick setup guide
- **CATEGORIES_FEATURE.md** - Feature overview
- **CATEGORIES_IMPLEMENTATION.md** - Technical details
- **ARCHITECTURE.md** - System architecture
- **UI_MOCKUP.md** - Visual mockups

## 🎯 Best Practices

This feature follows:
- ✅ Flutter best practices
- ✅ Material Design 3 guidelines
- ✅ Provider pattern for state management
- ✅ Clean architecture principles
- ✅ Null safety
- ✅ Type safety with Drift
- ✅ Proper resource disposal
- ✅ Error handling
- ✅ User feedback (snackbars)
- ✅ Accessibility considerations

## 🔐 Security

- ✅ SQL injection protection (via Drift)
- ✅ Type-safe database operations
- ✅ Input validation
- ✅ Proper error handling

## ⚡ Performance

- ✅ Efficient database queries
- ✅ Minimal widget rebuilds
- ✅ Lazy loading of categories
- ✅ Optimized animations
- ✅ Proper state management

## 🐛 Known Limitations

- Icon search is placeholder (not yet functional)
- Cannot reorder categories
- Cannot add custom icons (from files/URLs)
- Cannot use custom colors (RGB picker)

## 🚀 Future Enhancements

Potential improvements:
- [ ] Icon search functionality
- [ ] Category reordering (drag & drop)
- [ ] Custom icons from files
- [ ] RGB/HSV color picker
- [ ] Category usage statistics
- [ ] Category groups/subcategories
- [ ] Import/export categories
- [ ] Category spending limits

---

**Built with ❤️ for Munshi**
