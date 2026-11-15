import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/recipe_library/recipe_library_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SynProdLiteApp(),
    ),
  );
}

class SynProdLiteApp extends StatelessWidget {
  const SynProdLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SynProd Lite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RecipeLibraryScreen(),
    );
  }
}
