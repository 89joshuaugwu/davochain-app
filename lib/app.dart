import 'core/preview/local_preview_profile.dart';
import 'features/auth/presentation/returning_unlock_screen.dart';
import 'core/providers/account_services.dart';
import 'core/providers/account_scope.dart';
import 'core/providers/account_bootstrap.dart';
import 'core/providers/app_providers.dart';
import 'shared/widgets/davo_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/navigation/app_page_route.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
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
  Widget build(BuildContext context) => DavoAccountScope(
    child: AccountBootstrap(child: Builder(builder: _buildApp)),
  );
  Widget _buildApp(BuildContext context) {
    AppProviders.validateCurrentEntrypoint();
    return AccountConsumer(
      builder: (context, ref) => MaterialApp(
        title: 'Davochain',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ref.watch(appearanceModeProvider),
        themeAnimationDuration: Duration.zero,
        // Let field and suffix controls win their tap gestures before
        // dismissing focus. Pointer-down dismissal closes the input
        // connection while a tap is still transferring between fields.
        builder: (context, child) => GestureDetector(
          excludeFromSemantics: true,
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: Theme.of(context).brightness,
              systemNavigationBarColor: DavoColors.of(context).surface,
              systemNavigationBarIconBrightness:
                  Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
            ),
            child: MediaQuery.disableAnimationsOf(context)
                ? Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(splashFactory: NoSplash.splashFactory),
                    child: child!,
                  )
                : child!,
          ),
        ),
        scrollBehavior: const DavoScrollBehavior(),
        home: BrandSplashScreen(
          firstFrameReady: firstFrameReady,
          destinationBuilder: LocalPreviewProfile.instance.hasRestoredAccount
              ? (_) => const ReturningUnlockScreen()
              : null,
        ),
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
              builder = (_) =>
                  const VerificationScreen(kind: VerificationKind.email);
              break;
            case AppRoutes.smsVerification:
              builder = (_) =>
                  const VerificationScreen(kind: VerificationKind.sms);
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
            authHandoff: settings.arguments is AuthHandoff,
          );
        },
      ),
    );
  }
}
