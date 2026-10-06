import 'package:flutter/material.dart';

import 'core/navigation/app_page_route.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/create_password_screen.dart';
import 'features/auth/presentation/login_flow.dart';
import 'features/auth/presentation/signup_flow.dart';
import 'features/onboarding/presentation/brand_splash_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

class DavochainApp extends StatelessWidget {
  const DavochainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Davochain',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const BrandSplashScreen(),
      onGenerateRoute: (settings) {
        WidgetBuilder? builder;
        switch (settings.name) {
          case AppRoutes.onboarding:
            builder = (_) => const OnboardingScreen();
            break;
          case AppRoutes.signup:
            builder = (_) => const CountrySelectionScreen();
            break;
          case AppRoutes.createPassword:
            builder = (_) => const CreatePasswordScreen();
            break;
          case AppRoutes.login:
            builder = (_) => const LoginScreen();
            break;
          case AppRoutes.forgotPassword:
            builder = (_) => const ForgotPasswordScreen();
            break;
        }
        if (builder == null) return null;
        return AppPageRoute<void>(builder: builder, settings: settings);
      },
    );
  }
}
