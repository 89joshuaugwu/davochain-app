import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/brand_splash_screen.dart';

class DavochainApp extends StatelessWidget {
  const DavochainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Davochain',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const BrandSplashScreen(),
    );
  }
}
