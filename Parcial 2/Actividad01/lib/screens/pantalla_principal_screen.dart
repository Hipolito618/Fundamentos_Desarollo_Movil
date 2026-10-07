import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/nfl_scoreboard.dart';
import '../services/espn_api_service.dart';
import '../widgets/hero_match_card.dart';

class PantallaPrincipalScreen extends StatefulWidget {
  const PantallaPrincipalScreen({super.key});

  @override
  State<PantallaPrincipalScreen> createState() => _PantallaPrincipalScreenState();
}

class _PantallaPrincipalScreenState extends State<PantallaPrincipalScreen> {
  final EspnApiService _apiService = EspnApiService();
  NflScoreboard? _scoreboard;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  String _filterMode = 'todos'; // 'todos' or 'vivo'

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await _apiService.fetchScoreboard(date: _selectedDate);
    setState(() {
      _scoreboard = data;
      _isLoading = false;
    });
  }

  String _getMonthName(int month) {
    const months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filtrar los partidos por la fecha exacta seleccionada
    List<NflEvent> dayFilteredEvents = [];
    if (_scoreboard != null) {
      dayFilteredEvents = _scoreboard!.events.where((e) {
        if (e.date == null) return true;
        final local = e.date!.toLocal();
        return local.year == _selectedDate.year &&
               local.month == _selectedDate.month &&
               local.day == _selectedDate.day;
      }).toList();
    }

    // 2. Contar partidos en vivo de este día
    final liveCount = dayFilteredEvents.where((e) => e.state == 'in').length;

    // 3. Aplicar el filtro de modo (Todos vs En Vivo)
    List<NflEvent> displayEvents = dayFilteredEvents;
    if (_filterMode == 'vivo') {
      displayEvents = displayEvents.where((e) => e.state == 'in').toList();
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: AppColors.primaryBlue,
        child: CustomScrollView(
          slivers: [
            // Curved Header with Dates
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(top: 60, bottom: 24),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'NFL ACTION NOW',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.chevron_left, color: AppColors.white, size: 20),
                                const SizedBox(width: 4),
                                Text(_getMonthName(_selectedDate.month), style: const TextStyle(color: AppColors.white)),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right, color: AppColors.white, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Days Carousel
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(15, (index) {
                          final date = DateTime.now().add(Duration(days: index - 7));
                          final isSelected = date.year == _selectedDate.year && 
                                             date.month == _selectedDate.month && 
                                             date.day == _selectedDate.day;
                          final dayNames = ['LUN', 'MAR', 'MIE', 'JUE', 'VIE', 'SAB', 'DOM'];
                          final dayStr = dayNames[date.weekday - 1];
                          final numStr = date.day.toString().padLeft(2, '0');
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = date;
                                // Volver al filtro "Todos" por defecto al cambiar de día si lo deseas
                                // _filterMode = 'todos'; 
                              });
                              _fetchData();
                            },
                            child: _buildDayPill(dayStr, numStr, isSelected),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.neonLimeCard,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.tune, size: 20),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => setState(() => _filterMode = 'todos'),
                      child: Text('Todos', style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _filterMode == 'todos' ? AppColors.darkSurface : AppColors.darkSurface.withOpacity(0.4),
                      )),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => setState(() => _filterMode = 'vivo'),
                      child: Text('En Vivo($liveCount)', style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _filterMode == 'vivo' ? AppColors.darkSurface : AppColors.darkSurface.withOpacity(0.4),
                      )),
                    ),
                    const SizedBox(width: 16),
                    Text('AFC', style: TextStyle(color: AppColors.darkSurface.withOpacity(0.3), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            // Matches
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
              )
            else if (displayEvents.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    _filterMode == 'vivo' ? 'No hay partidos en vivo en este momento' : 'No hay partidos programados para este día',
                    style: TextStyle(color: AppColors.darkSurface.withOpacity(0.6), fontWeight: FontWeight.w500),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = displayEvents[index];
                    if (index == 0) {
                      return HeroMatchCard(event: event);
                    }
                    return _buildSecondaryCard(event, context);
                  },
                  childCount: displayEvents.length,
                ),
              ),
              
            // Space for dock
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildBottomDock(),
    );
  }

  Widget _buildDayPill(String day, String num, bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: active ? AppColors.neonLime : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(day, style: TextStyle(color: active ? AppColors.darkSurface : Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(num, style: TextStyle(color: active ? AppColors.darkSurface : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSecondaryCard(NflEvent event, BuildContext context) {
    String rightText = '';
    if (event.state == 'pre' && event.date != null) {
      rightText = TimeOfDay.fromDateTime(event.date!.toLocal()).format(context);
    } else {
      rightText = event.state == 'in' ? event.detail : (event.state == 'post' ? 'FINAL' : 'UPCOMING');
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(event.shortName, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
          Text(rightText, style: TextStyle(color: event.state == 'in' ? AppColors.alertRed : Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomDock() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.darkDock,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(Icons.sports_football_outlined, color: Colors.white54),
          const Icon(Icons.calendar_today_outlined, color: Colors.white54),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.neonLime,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, size: 8),
                SizedBox(width: 6),
                Text('Resultados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
