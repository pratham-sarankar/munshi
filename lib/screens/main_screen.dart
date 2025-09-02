import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:munshi/screens/home_screen.dart';
import 'package:munshi/screens/settings_screen.dart';
import 'package:munshi/screens/transactions_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Iconsax.home_outline),
            selectedIcon: Icon(Iconsax.home_1_bold),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Iconsax.receipt_item_outline),
            selectedIcon: Icon(Iconsax.receipt_item_bold),
            label: "Transactions",
          ),
          NavigationDestination(
            icon: Icon(Iconsax.setting_2_outline),
            selectedIcon: Icon(Iconsax.setting_2_bold),
            label: "Settings",
          ),
        ],
      ),
      body: [
        HomeScreen(),
        TransactionsScreen(),
        SettingsScreen(),
      ][_selectedIndex],
    );
  }
}
