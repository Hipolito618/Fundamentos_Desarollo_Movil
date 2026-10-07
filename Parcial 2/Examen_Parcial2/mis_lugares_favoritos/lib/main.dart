import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Inicializar Supabase con tus credenciales reales
   await Supabase.initialize(
     url: 'https://wgtxzxhlbinnljfzyrtf.supabase.co',
     anonKey: 'sb_publishable_DSD51eXpeUc5bONoGl-9lA_sxR3FNnY',
   );

  runApp(
    const ProviderScope(
      child: MisLugaresFavoritosApp(),
    ),
  );
}

class MisLugaresFavoritosApp extends ConsumerWidget {
  const MisLugaresFavoritosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Mis Lugares Favoritos',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const AuthScreen(),
    );
  }
}

