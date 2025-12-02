import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation/app_router.dart';
import 'navigation/navigation_service.dart';
import 'navigation/app_navigation.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
// import 'screen/payment_provider.dart'; // File missing - commented out for theme update
import 'screen/airline_interface.dart';
import 'utils/keyboard_shortcuts.dart';

void main() {
  // Initialize centralized navigation service
  AppNavigation.setNavigatorKey(NavigationService.navigatorKey);
  runApp(const PayGlocalProdDemoApp());
}

class PayGlocalProdDemoApp extends StatelessWidget {
  const PayGlocalProdDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => PaymentProvider()), // Commented out - file missing
        ChangeNotifierProvider(create: (_) => AirlineBookingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'PayGlocal Product Showcase',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppRouter.overview,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
                  ),
                ),
                child: KeyboardShortcuts(child: child!),
              );
            },
          );
        },
      ),
    );
  }
}
