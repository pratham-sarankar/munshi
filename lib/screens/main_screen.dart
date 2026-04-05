import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/features/categories/screens/categories_screen.dart';
import 'package:munshi/features/dashboard/providers/dashboard_provider.dart';
import 'package:munshi/features/dashboard/screens/home_screen.dart';
import 'package:munshi/features/settings/screens/settings_screen.dart';
import 'package:munshi/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:munshi/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:munshi/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:munshi/features/transactions/presentation/screens/transaction_form_screen.dart';
import 'package:munshi/features/transactions/presentation/screens/transactions_screen.dart';

/// The root scaffold that hosts bottom navigation and the floating action button.
///
/// It also listens for [TransactionState.transactionMutated] and refreshes the
/// [DashboardProvider] whenever a transaction is added, updated, or deleted.
class MainScreen extends StatefulWidget {
  /// Creates a [MainScreen].
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Cache navigation destinations to avoid recreation
  late final List<Widget> _destinations = [
    const NavigationDestination(
      icon: Icon(Iconsax.home_outline),
      selectedIcon: Icon(Iconsax.home_1_bold),
      label: 'Home',
    ),
    const NavigationDestination(
      icon: Icon(Iconsax.receipt_item_outline),
      selectedIcon: Icon(Iconsax.receipt_item_bold),
      label: 'History',
    ),
    const SizedBox(),
    const NavigationDestination(
      icon: Icon(Iconsax.category_outline),
      selectedIcon: Icon(Iconsax.category_bold),
      label: 'Categories',
    ),
    const NavigationDestination(
      icon: Icon(Iconsax.setting_2_outline),
      selectedIcon: Icon(Iconsax.setting_2_bold),
      label: 'Settings',
    ),
  ];

  // Build screens dynamically to reflect currency changes
  List<Widget> get _screens => [
    const HomeScreen(),
    const TransactionsScreen(),
    const SizedBox(),
    const CategoriesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (previous, current) =>
          !previous.transactionMutated && current.transactionMutated,
      listener: (context, state) {
        // Refresh the dashboard whenever a transaction is mutated.
        context.read<DashboardProvider>().refresh();
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) {
                  return TransactionFormScreen(
                    onSubmit: (transaction) {
                      context
                          .read<TransactionBloc>()
                          .add(TransactionAdded(transaction));
                    },
                  );
                },
              ),
            );
          },
          shape: const CircleBorder(),
          elevation: 2,
          child: const Icon(Iconsax.add_outline),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          notchMargin: 10,
          shape: const CircularNotchedRectangle(),
          elevation: 10,
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                _selectedIndex = value;
              });
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: _destinations,
          ),
        ),
        body: IndexedStack(
          alignment: Alignment.topCenter,
          index: _selectedIndex,
          children: _screens,
        ),
      ),
    );
  }
}

