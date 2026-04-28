import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_provider.dart';
import 'services/push_notification_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'theme/glass_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    await PushNotificationService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // We continue so the app still works without FCM
  }
  
  await Hive.initFlutter();
  await Hive.openBox<String>('cached_exams');
  await Hive.openBox<String>('pending_sync_queue');
  
  // Note: Replace with actual credentials from .env
  await Supabase.initialize(
    url: 'https://qcluejszrldmvllslzng.supabase.co',
    anonKey: 'sb_publishable_-VTcEwtff1ujQpM5nu2ROQ_3_N8viw-',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const PrepGenZApp(),
    ),
  );
}


class PrepGenZApp extends StatelessWidget {
  const PrepGenZApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrepGenZ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: GlassTheme.primaryColor,
        scaffoldBackgroundColor: GlassTheme.backgroundColor,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: GlassTheme.primaryColor,
          selectionColor: GlassTheme.primaryColor.withOpacity(0.3),
          selectionHandleColor: GlassTheme.primaryColor,
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return auth.user != null ? DashboardScreen() : LoginScreen();
        },
      ),
    );
  }
}
