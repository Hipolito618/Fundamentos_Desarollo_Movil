import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/nfl_scoreboard.dart';

class EnVivoScreen extends StatelessWidget {
  final NflEvent event;

  const EnVivoScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final comp = event.competition;
    final situation = comp?.situation;
    
    NflCompetitor? homeTeam;
    NflCompetitor? awayTeam;
    if (comp != null && comp.competitors.isNotEmpty) {
      homeTeam = comp.competitors.firstWhere((c) => c.isHome, orElse: () => comp.competitors.last);
      awayTeam = comp.competitors.firstWhere((c) => !c.isHome, orElse: () => comp.competitors.first);
    }

    NflCompetitor? possessionTeam;
    if (situation != null && situation.possession.isNotEmpty) {
      if (homeTeam?.id == situation.possession) possessionTeam = homeTeam;
      if (awayTeam?.id == situation.possession) possessionTeam = awayTeam;
    }

    String headerTitle = possessionTeam?.teamName ?? (homeTeam?.teamName ?? 'Equipo');
    String headerSubtitle = situation != null ? 'En Posesión' : 'Esperando jugada...';

    String playText = situation?.lastPlayText.toLowerCase() ?? '';
    Widget? playBadge;
    if (playText.contains('touchdown')) {
      playBadge = const Text('¡TOUCHDOWN! 🏈', style: TextStyle(color: AppColors.neonLime, fontSize: 12, fontWeight: FontWeight.bold));
    } else if (playText.contains('interception') || playText.contains('fumble')) {
      playBadge = const Text('TURNOVER ⚠️', style: TextStyle(color: AppColors.alertRed, fontSize: 12, fontWeight: FontWeight.bold));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF070B12), // Deep dark gradient bg
      body: Stack(
        children: [
          // Background immersive elements
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Divider(color: Colors.white.withOpacity(0.1)),
                const Text('30', style: TextStyle(color: Colors.white24, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 100),
                const Text('30', style: TextStyle(color: Colors.white24, fontSize: 24, fontWeight: FontWeight.bold)),
                Divider(color: Colors.white.withOpacity(0.1)),
              ],
            ),
          ),
          // Player Avatar Illustration
          Center(
            child: Icon(Icons.person_pin, size: 150, color: AppColors.neonLime.withOpacity(0.8)),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text('18.4k', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.neonLime,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: event.state == 'in' ? AppColors.alertRed : Colors.black54, size: 10),
                            const SizedBox(width: 6),
                            Text(event.state == 'in' ? 'LIVE' : (event.state == 'post' ? 'FINAL' : 'UPCOMING'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        child: const Icon(Icons.fullscreen, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Glassmorphism Bottom Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.glassCardBg,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      // Player & Score Row
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade800,
                            backgroundImage: possessionTeam != null && possessionTeam.logo.isNotEmpty ? NetworkImage(possessionTeam.logo) : null,
                            child: (possessionTeam == null || possessionTeam.logo.isEmpty) ? const Icon(Icons.sports_football, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(headerTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(headerSubtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              CircleAvatar(radius: 10, backgroundColor: Colors.indigo, child: Text(awayTeam?.abbreviation ?? '-', style: const TextStyle(fontSize: 8, color: Colors.white))),
                              const SizedBox(width: 8),
                              Text('${awayTeam?.score ?? 0}  ${homeTeam?.score ?? 0}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFeatures: [FontFeature.tabularFigures()])),
                              const SizedBox(width: 8),
                              CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Text(homeTeam?.abbreviation ?? '-', style: const TextStyle(fontSize: 8, color: Colors.white))),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Field Tracker
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: situation != null ? (situation.yardLine / 100.0).clamp(0.0, 1.0) : 0.5,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.neonLime,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Positioned(
                            left: situation != null ? MediaQuery.of(context).size.width * 0.8 * (situation.yardLine / 100.0) : MediaQuery.of(context).size.width * 0.4,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.neonLime,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('PROPIA', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                          Text(situation?.possessionText ?? '50', style: const TextStyle(color: AppColors.neonLime, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('GOL', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Inner Tabs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInnerTab('En Vivo', true),
                          _buildInnerTab('Jugadas', false),
                          _buildInnerTab('Estadísticas', false),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Last Play Box
                      if (situation != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (situation.downDistanceText.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        situation.downDistanceText,
                                        style: const TextStyle(color: AppColors.neonLime, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Text(event.detail, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                situation.lastPlayText.isNotEmpty ? situation.lastPlayText : 'Sin información de jugada reciente.',
                                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                              ),
                              if (playBadge != null) ...[
                                const SizedBox(height: 8),
                                playBadge,
                              ],
                            ],
                          ),
                        )
                      else 
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Partido ${event.state == 'pre' ? 'por comenzar' : 'finalizado'}.',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerTab(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.neonLime : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? AppColors.darkSurface : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
