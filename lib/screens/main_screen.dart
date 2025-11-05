import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/features/dashboard/screens/home_screen.dart';
import 'package:munshi/features/settings/screens/settings_screen.dart';
import 'package:munshi/features/transactions/screens/transactions_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Cache screens to avoid recreation on every build
  late final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    const SizedBox(),
    const Scaffold(),
    const SettingsScreen(),
  ];

  // Cache navigation destinations to avoid recreation
  late final List<Widget> _destinations = [
    const NavigationDestination(
      icon: Icon(Iconsax.home_outline),
      selectedIcon: Icon(Iconsax.home_1_bold),
      label: "Home",
    ),
    const NavigationDestination(
      icon: Icon(Iconsax.receipt_item_outline),
      selectedIcon: Icon(Iconsax.receipt_item_bold),
      label: "Transactions",
    ),
    const SizedBox(),
    const NavigationDestination(
      icon: Icon(Iconsax.category_outline),
      selectedIcon: Icon(Iconsax.category_bold),
      label: "Categories",
    ),
    const NavigationDestination(
      icon: Icon(Iconsax.setting_2_outline),
      selectedIcon: Icon(Iconsax.setting_2_bold),
      label: "Settings",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle floating action button press
        },
        shape: const CircleBorder(),
        elevation: 2,
        child: const Icon(Iconsax.add_outline),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 10,
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
    );
  }
}
