import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/library_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Reemplaza con tu URL y anonKey de Supabase
  await Supabase.initialize(
    url:  'https://aimkhsacvkushibkicml.supabase.co',
    anonKey: 'sb_publishable_SfUiPkUWNsQJ9RXfPnpl0g_nRvyKZkO',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const InitialRoute(),
    );
  }
}

class InitialRoute extends StatelessWidget {
  const InitialRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const LibraryScreen();
    }
    return const OnboardingScreen();
  }
}

