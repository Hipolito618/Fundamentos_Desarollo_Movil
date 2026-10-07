import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';

class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

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

