import 'package:flutter/material.dart';
import 'package:recall_bloom/theme.dart';
import 'package:recall_bloom/screens/onboarding_screen.dart';
import 'package:recall_bloom/screens/home_screen.dart';
import 'package:recall_bloom/services/local_storage_service.dart';
import 'package:recall_bloom/services/user_service.dart';
import 'package:recall_bloom/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyFlow',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final storage = await LocalStorageService.getInstance();
    final userService = UserService(storage);
    final hasOnboarded = await userService.hasCompletedOnboarding();

    setState(() {
      _hasCompletedOnboarding = hasOnboarded;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _hasCompletedOnboarding ? const HomeScreen() : const OnboardingScreen();
  }
}
