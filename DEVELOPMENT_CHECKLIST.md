# Flutter Development Best Practices Checklist

Use this checklist when writing or reviewing Flutter code to prevent common issues.

## 🎯 Resource Management

- [ ] **Controllers Disposed**: All AnimationControllers, TextEditingControllers, TabControllers, etc. have matching `dispose()` calls
- [ ] **Listeners Removed**: All `addListener()` calls have corresponding `removeListener()` in dispose()
- [ ] **Streams Closed**: All StreamControllers and subscriptions are properly closed
- [ ] **Timers Cancelled**: All Timer instances are cancelled in dispose()

## 🔒 Type Safety

- [ ] **Null Checks**: Added null checks before type casting (use `as Type?` then validate)
- [ ] **Type Validation**: Validate types before unsafe casting (use `is` checks)
- [ ] **Parse Safety**: Wrap parse operations in try-catch or validate input first
- [ ] **Map Access**: Always check if map keys exist before accessing values

## ⚡ Performance

- [ ] **No shrinkWrap**: Avoid `ListView` with `shrinkWrap: true` inside scrollable parents - use `Column` instead
- [ ] **Efficient Listeners**: Use `ValueListenableBuilder` instead of `addListener()` + `setState()`
- [ ] **Const Widgets**: Mark widgets as `const` when possible
- [ ] **No Rebuilds**: Ensure setState() only rebuilds necessary parts

## 🎨 UI Best Practices

- [ ] **Use Constants**: Extract magic numbers to constants (durations, spacing, radii)
- [ ] **Theme Colors**: Use `Theme.of(context).colorScheme` instead of hardcoded colors
- [ ] **Responsive**: Test on different screen sizes
- [ ] **Accessibility**: Add semantic labels where appropriate

## 🛡️ Error Handling

- [ ] **Try-Catch**: Wrap risky operations in try-catch blocks
- [ ] **User Messages**: Show user-friendly error messages, not raw exceptions
- [ ] **Logging**: Log errors with context for debugging
- [ ] **Fallbacks**: Provide fallback values/states when errors occur

## 📝 Code Quality

- [ ] **No Hardcoded Values**: Move configuration to constants file
- [ ] **Descriptive Names**: Use clear, descriptive variable and function names
- [ ] **Single Responsibility**: Each function/class should do one thing well
- [ ] **Comments**: Add comments for complex logic, not obvious code

## 🔐 Security

- [ ] **No Secrets**: Never commit API keys, passwords, or tokens
- [ ] **Input Validation**: Validate and sanitize all user input
- [ ] **Safe WebView**: Restrict JavaScript and validate URLs in WebView
- [ ] **Environment Variables**: Use `.env` files for sensitive configuration

## 🧪 Testing

- [ ] **Unit Tests**: Write tests for business logic and utilities
- [ ] **Widget Tests**: Test critical user flows
- [ ] **Edge Cases**: Test with null, empty, and extreme values
- [ ] **Memory Tests**: Use Flutter DevTools to check for memory leaks

## 📱 State Management

- [ ] **Mounted Check**: Check `if (mounted)` before calling setState() after async operations
- [ ] **NotifyListeners**: Call `notifyListeners()` after state changes in ChangeNotifier
- [ ] **Immutable State**: Prefer immutable state objects
- [ ] **State Scoping**: Keep state as local as possible

## 🔄 Async Operations

- [ ] **Await Properly**: Always await async operations or handle Future
- [ ] **Error Handling**: Add try-catch to async operations
- [ ] **Loading States**: Show loading indicators during async operations
- [ ] **Cancellation**: Cancel async operations if widget is disposed

## 📦 Dependencies

- [ ] **Version Lock**: Use specific version ranges in pubspec.yaml
- [ ] **Security Scan**: Check dependencies for vulnerabilities
- [ ] **Minimal Deps**: Only add necessary dependencies
- [ ] **Update Regularly**: Keep dependencies up to date

## 🚀 Before Committing

- [ ] **Run Analyze**: `flutter analyze` passes with no warnings
- [ ] **Run Format**: `flutter format .` applied
- [ ] **Run Tests**: All tests pass with `flutter test`
- [ ] **Manual Test**: Manually tested the changed functionality
- [ ] **Code Review**: Self-review changes in diff view

## 📚 Code Review Checklist (for Reviewers)

- [ ] **Functionality**: Code does what it's supposed to do
- [ ] **Edge Cases**: Handles null, empty, and error cases
- [ ] **Performance**: No obvious performance issues
- [ ] **Security**: No security vulnerabilities
- [ ] **Maintainability**: Code is readable and maintainable
- [ ] **Tests**: Adequate test coverage
- [ ] **Documentation**: Complex logic is documented

## 💡 Pro Tips

1. **Use Lint Rules**: Configure `analysis_options.yaml` with strict lint rules
2. **DevTools**: Use Flutter DevTools regularly to check performance and memory
3. **Hot Reload**: Take advantage of hot reload during development
4. **Code Snippets**: Create IDE snippets for common patterns (dispose, initState, etc.)
5. **Pair Review**: Have someone else review critical code changes

## 🔗 Resources

- [Flutter Best Practices](https://docs.flutter.dev/cookbook)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Performance](https://docs.flutter.dev/perf/best-practices)
- [Material Design Guidelines](https://m3.material.io/)

---

**Remember**: It's easier to write code correctly the first time than to fix issues later!
