import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:munshi/core/theme.dart';
import 'package:munshi/screens/main_screen.dart';
import 'package:munshi/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const Munshi(),
    ),
  );
}

class Munshi extends StatelessWidget {
  const Munshi({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = MaterialTheme(
      GoogleFonts.manropeTextTheme(Typography.material2021().englishLike),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Munshi',
          debugShowCheckedModeBanner: false,
          theme: theme.light(),
          darkTheme: theme.dark(),
          highContrastTheme: theme.lightHighContrast(),
          highContrastDarkTheme: theme.darkHighContrast(),
          themeMode: themeProvider.themeMode,
          home: MainScreen(),
        );
      },
    );
  }
}
