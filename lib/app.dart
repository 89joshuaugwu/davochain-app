import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/navigation/app_page_route.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/appearance_controller.dart';
import 'features/auth/presentation/create_password_screen.dart';
import 'features/auth/presentation/login_flow.dart';
import 'features/auth/presentation/signup_flow.dart';
import 'features/auth/presentation/verification_flow.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/onboarding/presentation/brand_splash_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

class DavochainApp extends StatelessWidget {
  const DavochainApp({super.key, this.firstFrameReady});
  final Future<void>? firstFrameReady;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppearanceController.instance,
      builder: (context, _) => MaterialApp(
      title: 'Davochain',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: AppearanceController.instance.mode,
      themeAnimationDuration: Duration.zero,
      builder: (context, child) => Listener(
        onPointerDown: (event) {
          final focused = FocusManager.instance.primaryFocus;
          final box = focused?.context?.findRenderObject();
          if (box is RenderBox &&
              box.hasSize &&
              !(box.localToGlobal(Offset.zero) & box.size)
                  .contains(event.position)) {
            focused?.unfocus();
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
            statusBarBrightness: Theme.of(context).brightness,
            systemNavigationBarColor: DavoColors.of(context).surface,
            systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          ),
          child: MediaQuery.disableAnimationsOf(context)
            ? Theme(
                data: Theme.of(context)
                    .copyWith(splashFactory: NoSplash.splashFactory),
                child: child!,
              )
            : child!,
        ),
      ),
      scrollBehavior:
          const MaterialScrollBehavior().copyWith(overscroll: false),
      home: BrandSplashScreen(firstFrameReady: firstFrameReady),
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
          case AppRoutes.emailVerification:
            builder =
                (_) => const VerificationScreen(kind: VerificationKind.email);
            break;
          case AppRoutes.smsVerification:
            builder =
                (_) => const VerificationScreen(kind: VerificationKind.sms);
            break;
          case AppRoutes.transactionPin:
            builder = (_) => const TransactionPinScreen();
            break;
          case AppRoutes.dashboard:
            builder = (_) => const DavochainDashboardScreen();
            break;
        }
        if (builder == null) return null;
        return AppPageRoute<void>(
            builder: builder,
            settings: settings,
            authHandoff: settings.arguments is AuthHandoff);
      },
    ));
  }
}
