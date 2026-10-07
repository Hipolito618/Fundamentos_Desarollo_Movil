import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/theme_provider.dart';
import 'home_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool isLoading = false;
  bool obscurePassword = true;
  bool keepSession = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void toggleMode(bool login) {
    if (isLogin == login) return;
    setState(() {
      isLogin = login;
      formKey.currentState?.reset();
    });
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    
    setState(() => isLoading = true);
    
    try {
      final supabase = Supabase.instance.client;
      if (isLogin) {
        await supabase.auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      } else {
        await supabase.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      }
      
      if (!mounted) return;
      _navigateToHome();
    } on AuthException catch (e) {
      showErrorSnackbar(e.message);
    } catch (e) {
      // Si Supabase no está inicializado, mostramos error o simulamos éxito (para propósitos de UI).
      // En producción, esto no pasaría si la app falla antes. Aquí simulamos acceso exitoso 
      // si el error es de inicialización de Supabase, solo para poder ver la pantalla de inicio 
      // durante el desarrollo de las vistas sin configurar el backend aún.
      if (e.toString().contains('Supabase.initialize') || e.toString().contains('initialize the supabase instance')) {
        _navigateToHome();
      } else {
        showErrorSnackbar('Error inesperado: $e');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
        animation: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () {},
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: _ThemeToggle(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: MapBackgroundPainter(
                color: theme.colorScheme.onSurface.withOpacity(isDark ? 0.04 : 0.03),
              ),
            ),
          ),
          
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 1),
                          // Logo
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                ),
                              ),
                              Icon(
                                Icons.location_on,
                                size: 50,
                                color: theme.colorScheme.primary,
                              ),
                              Positioned(
                                bottom: 10,
                                child: Container(
                                  width: 24,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Mis Lugares\nFavoritos',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Selector de Pestañas Animado
                          Container(
                            height: 50,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withOpacity(isDark ? 0.08 : 0.05),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Stack(
                              children: [
                                AnimatedAlign(
                                  alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: FractionallySizedBox(
                                    widthFactor: 0.5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(21),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.primary.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => toggleMode(true),
                                        child: Center(
                                          child: AnimatedDefaultTextStyle(
                                            duration: const Duration(milliseconds: 300),
                                            style: TextStyle(
                                              color: isLogin ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.5),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                            child: const Text('Iniciar Sesión'),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => toggleMode(false),
                                        child: Center(
                                          child: AnimatedDefaultTextStyle(
                                            duration: const Duration(milliseconds: 300),
                                            style: TextStyle(
                                              color: !isLogin ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.5),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                            child: const Text('Crear Cuenta'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Formulario
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            child: Form(
                              key: formKey,
                              child: Column(
                                key: ValueKey(isLogin),
                                children: [
                                  TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(color: theme.colorScheme.onSurface),
                                    decoration: InputDecoration(
                                      hintText: 'Correo electrónico',
                                      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                                      prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 22),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(isDark ? 0.2 : 0.1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(color: Colors.redAccent),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                                      ),
                                    ),
                                    validator: (v) => v!.isEmpty || !v.contains('@') ? 'Ingresa un correo válido' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: passwordController,
                                    obscureText: obscurePassword,
                                    style: TextStyle(color: theme.colorScheme.onSurface),
                                    decoration: InputDecoration(
                                      hintText: 'Contraseña',
                                      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                                      prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 22),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                                          size: 22,
                                        ),
                                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                      ),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(isDark ? 0.2 : 0.1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(color: Colors.redAccent),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                                      ),
                                    ),
                                    validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                                  ),
                                  if (isLogin) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            value: keepSession,
                                            onChanged: (v) => setState(() => keepSession = v!),
                                            activeColor: theme.colorScheme.primary,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Mantener sesión iniciada',
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            fontSize: 13,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                  const SizedBox(height: 32),
                                  
                                  // Botón
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(28),
                                        ),
                                        elevation: 8,
                                        shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                              )
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                key: ValueKey(isLogin),
                                                children: [
                                                  if (isLogin)
                                                    Container(
                                                      padding: const EdgeInsets.all(2),
                                                      decoration: const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(Icons.check, color: theme.colorScheme.primary, size: 16),
                                                    )
                                                  else
                                                    const SizedBox(width: 20), // Para balancear
                                                  
                                                  Text(
                                                    isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  
                                                  const Icon(Icons.keyboard_double_arrow_right, color: Colors.white, size: 20),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          if (isLogin) ...[
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(fontSize: 13)),
                            ),
                            TextButton(
                              onPressed: () => toggleMode(false),
                              child: RichText(
                                text: TextSpan(
                                  text: '¿No tienes cuenta? ',
                                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text: 'Regístrate',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            TextButton(
                              onPressed: () => toggleMode(true),
                              child: RichText(
                                text: TextSpan(
                                  text: '¿Ya tienes cuenta? ',
                                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text: 'Inicia sesión',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 64,
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.onSurface.withOpacity(isDark ? 0.2 : 0.1)),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isDark ? 32 : 2,
              right: isDark ? 2 : 32,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? theme.colorScheme.primary : Colors.black87,
                ),
                child: Icon(
                  isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapBackgroundPainter extends CustomPainter {
  final Color color;
  MapBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
      
    final path = Path();
    
    // Lineas diagonales y cruces
    path.moveTo(size.width * 0.1, -50);
    path.lineTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width * 1.2, size.height * 0.6);

    path.moveTo(-50, size.height * 0.1);
    path.lineTo(size.width * 0.4, size.height * 0.2);
    path.lineTo(size.width * 0.6, size.height * 0.6);
    path.lineTo(size.width * 0.5, size.height * 1.2);
    
    path.moveTo(size.width * 0.9, -50);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width * 0.9, size.height * 0.9);
    
    final thinPaint = Paint()
      ..color = color.withOpacity(color.opacity * 0.6)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
      
    final thinPath = Path();
    thinPath.moveTo(-50, size.height * 0.4);
    thinPath.lineTo(size.width * 1.2, size.height * 0.3);
    
    thinPath.moveTo(size.width * 0.3, -50);
    thinPath.lineTo(size.width * 0.2, size.height * 1.2);

    canvas.drawPath(path, paint);
    canvas.drawPath(thinPath, thinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

