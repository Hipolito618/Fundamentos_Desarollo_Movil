import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/nfl_scoreboard.dart';
import '../screens/en_vivo_screen.dart';

class HeroMatchCard extends StatelessWidget {
  final NflEvent event;

  const HeroMatchCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    if (event.competition == null || event.competition!.competitors.length < 2) {
      return const SizedBox();
    }
    final comp = event.competition!;
    // Competitors [0] is usually Home, [1] is Away, but check isHome
    final awayTeam = comp.competitors.firstWhere((c) => !c.isHome, orElse: () => comp.competitors.last);
    final homeTeam = comp.competitors.firstWhere((c) => c.isHome, orElse: () => comp.competitors.first);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => EnVivoScreen(event: event)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neonLimeCard,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            // Top tag & status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.name.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      if (event.state == 'in') ...[
                        const Icon(Icons.circle, color: AppColors.alertRed, size: 8),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        event.state == 'in' ? event.detail : (event.state == 'post' ? 'FINAL' : 'UPCOMING'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Teams & Score Sets Container
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  // Teams row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTeamHeader(awayTeam),
                      const Icon(Icons.sports_football, color: Colors.brown), // Possession indicator simple mock
                      _buildTeamHeader(homeTeam, reverse: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quarters and Score
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildQuartersColumn(awayTeam),
                        const SizedBox(width: 16),
                        // Total Score or Time
                        event.state == 'pre' && event.date != null
                          ? Text(
                              TimeOfDay.fromDateTime(event.date!.toLocal()).format(context),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : Text(
                              '${awayTeam.score}  ${homeTeam.score}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                        const SizedBox(width: 16),
                        _buildQuartersColumn(homeTeam),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Footer summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('L. Jackson (240 yds, 2TD)', style: TextStyle(fontSize: 10, color: AppColors.darkSurface.withOpacity(0.7))),
                Text('P.Mahomes(285 yds, 3TD)', style: TextStyle(fontSize: 10, color: AppColors.darkSurface.withOpacity(0.7))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTeamHeader(NflCompetitor team, {bool reverse = false}) {
    final children = [
      CircleAvatar(
        backgroundColor: Colors.blue.shade900, // Mock color
        radius: 16,
        backgroundImage: team.logo.isNotEmpty ? NetworkImage(team.logo) : null,
        child: team.logo.isEmpty ? Text(team.abbreviation, style: const TextStyle(color: Colors.white, fontSize: 10)) : null,
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          team.teamName.toUpperCase(), 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    ];
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reverse ? children.reversed.toList() : children,
      ),
    );
  }

  Widget _buildQuartersColumn(NflCompetitor team) {
    if (team.lineScores.isEmpty) {
      return Row(children: List.generate(4, (i) => _buildSetBox("-")));
    }
    return Row(
      children: team.lineScores.map((score) => _buildSetBox(score.toString())).toList(),
    );
  }

  Widget _buildSetBox(String val) {
    return Container(
      width: 24,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.neonLime,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        val,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

