import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'pantalla_principal_screen.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Stack(
        children: [
          // Background Text
          Positioned(
            top: 100,
            left: 20,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BREAK',
                  style: TextStyle(
                    fontSize: 84,
                    fontWeight: FontWeight.w900,
                    color: AppColors.neonLime,
                    height: 0.9,
                    letterSpacing: -1.5,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Text(
                      'POINT',
                      style: TextStyle(
                        fontSize: 84,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        height: 0.9,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Central Image
          Positioned(
            bottom: 150,
            left: -20,
            right: -20,
            child: Image.asset(
              'assets/images/player.png',
              height: 520,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(height: 520),
            ),
          ),
          
          // Bottom Curvature Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.neonLime,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(44),
                  topRight: Radius.circular(44),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    const Text(
                      'Real-time Scores & Stats',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Follow Every Play In Depth',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.darkSurface.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // Floating Navigation Dock
                    Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.darkDock,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Inactive back button
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                          ),
                          
                          // Pagination dots
                          Row(
                            children: [
                              _buildDot(true),
                              const SizedBox(width: 8),
                              _buildDot(false),
                              const SizedBox(width: 8),
                              _buildDot(false),
                            ],
                          ),
                          
                          // Active Next Button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PantallaPrincipalScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: AppColors.neonLimeCard,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward_ios, color: AppColors.darkSurface, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}

