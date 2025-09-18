import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inventoryproductapp/views/dashboard/dashboard_screen.dart';
import 'core/constants/app_constants.dart';
import 'firebase_options.dart';
import 'viewmodels/theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'), // add more locales like Locale('hi'), Locale('fr')
      ],
      path: 'assets', // <-- your JSON path
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'Inventory Dashboard',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      themeMode: themeMode,
      theme: ThemeData(
        primarySwatch: themeGreen,
        brightness: Brightness.light,
        scaffoldBackgroundColor: themeGreen.shade50,
        appBarTheme: AppBarTheme(backgroundColor: themeGreen.shade700),
        floatingActionButtonTheme:
        FloatingActionButtonThemeData(backgroundColor: themeGreen.shade700),
        cardColor: themeGreen.shade100,
      ),
      darkTheme: ThemeData(
        primarySwatch: themeGreen,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[800],
        appBarTheme: const AppBarTheme(backgroundColor: Colors.green),
        floatingActionButtonTheme:
        const FloatingActionButtonThemeData(backgroundColor: Colors.green),
      ),
      home: const DashboardScreen(),
    );
  }
}
