import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song_model.dart';
import '../services/supabase_service.dart';
import '../core/theme.dart';
import 'player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _searchController = TextEditingController();
  
  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];
  
  bool _isLoading = true;
  String _errorMessage = '';
  
  String _selectedFilter = 'Todas'; // 'Todas', 'Favoritas', 'Álbumes'
  
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadSongs();
    
    _searchController.addListener(_onSearchChanged);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      // Opcional: Pasar a la siguiente canción
      _playNext();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await SupabaseService().getSongs();
      setState(() {
        _allSongs = songs;
        _filteredSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredSongs = _allSongs.where((song) {
        // Filtrar por texto
        final matchesSearch = song.titulo.toLowerCase().contains(query) ||
            song.artista.toLowerCase().contains(query) ||
            song.album.toLowerCase().contains(query);
            
        // Filtrar por chip (Píldora)
        bool matchesChip = true;
        if (_selectedFilter == 'Favoritas') {
          matchesChip = song.favorita;
        }
        // Nota: El filtro "Álbumes" podría requerir una vista agrupada distinta, 
        // pero por ahora filtramos la lista plana si es necesario o simplemente lo dejamos.
        
        return matchesSearch && matchesChip;
      }).toList();
    });
  }

  void _toggleFavorite(Song song) async {
    try {
      await SupabaseService().toggleFavorite(song.id, song.favorita);
      // Actualizar el estado local
      setState(() {
        final indexAll = _allSongs.indexWhere((s) => s.id == song.id);
        if (indexAll != -1) {
          _allSongs[indexAll] = song.copyWith(favorita: !song.favorita);
        }
        _applyFilters();
        
        // Si es la canción actual, actualizarla también
        if (_currentSong?.id == song.id) {
          _currentSong = _currentSong!.copyWith(favorita: !song.favorita);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar favorito: $e')),
      );
    }
  }

  void _playSong(Song song) async {
    if (song.audioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio no disponible para esta pista.')),
      );
      return;
    }

    try {
      if (_currentSong?.id != song.id) {
        setState(() => _currentSong = song);
        await _audioPlayer.play(UrlSource(song.audioUrl));
      } else {
        // Si es la misma, pausar/reanudar
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      print('Error al reproducir: $e');
    }
  }

  void _playNext() {
    if (_currentSong == null || _filteredSongs.isEmpty) return;
    final currentIndex = _filteredSongs.indexWhere((s) => s.id == _currentSong!.id);
    if (currentIndex != -1 && currentIndex < _filteredSongs.length - 1) {
      _playSong(_filteredSongs[currentIndex + 1]);
    }
  }

  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tu Biblioteca',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar canciones, artistas o álbumes...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Píldoras (Chips)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildFilterChip('Todas (${_allSongs.length})', 'Todas'),
                const SizedBox(width: 8),
                _buildFilterChip('Favoritas', 'Favoritas'),
                const SizedBox(width: 8),
                _buildFilterChip('Álbumes', 'Álbumes'),
              ],
            ),
          ),
          
          // Lista de canciones
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                    : ListView.builder(
                        itemCount: _filteredSongs.length,
                        itemBuilder: (context, index) {
                          final song = _filteredSongs[index];
                          final isCurrent = _currentSong?.id == song.id;
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCurrent ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent ? AppTheme.primaryColor.withOpacity(0.5) : Colors.transparent,
                              ),
                            ),
                            child: ListTile(
                              onTap: () {
                                _playSong(song);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlayerScreen(
                                      initialIndex: _allSongs.indexWhere((s) => s.id == song.id),
                                    ),
                                  ),
                                );
                              },
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              leading: _buildVinylAvatar(song),
                              title: Text(
                                song.titulo,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                '${song.artista} • ${song.album}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatDuration(song.duracionSeg),
                                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      song.favorita ? Icons.favorite : Icons.favorite_border,
                                      color: song.favorita ? Colors.pinkAccent : Colors.grey[600],
                                      size: 20,
                                    ),
                                    onPressed: () => _toggleFavorite(song),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          
          // Mini Reproductor Flotante
          if (_currentSong != null)
            _buildMiniPlayer(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterValue) {
    final isActive = _selectedFilter == filterValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterValue;
          _applyFilters();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[400],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildVinylAvatar(Song song) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[900],
        border: Border.all(color: Colors.black, width: 2),
        image: song.portadaUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(song.portadaUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.2),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0A0A0D),
            border: Border.all(color: _getRandomColor(song.id), width: 2),
          ),
        ),
      ),
    );
  }
  
  Color _getRandomColor(int id) {
    final colors = [Colors.blue, Colors.orange, Colors.cyan, Colors.pink, Colors.teal, Colors.purple];
    return colors[id % colors.length];
  }

  Widget _buildMiniPlayer() {
    // Calculamos el progreso para la línea inferior
    double progress = 0.0;
    if (_duration.inMilliseconds > 0) {
      progress = _position.inMilliseconds / _duration.inMilliseconds;
    }

    return GestureDetector(
      onTap: () {
        if (_currentSong != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerScreen(
                initialIndex: _allSongs.indexWhere((s) => s.id == _currentSong!.id),
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _buildVinylAvatar(_currentSong!),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentSong!.titulo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_currentSong!.artista} • En reproducción',
                            style: TextStyle(
                              color: AppTheme.primaryColor.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_isPlaying) {
                          _audioPlayer.pause();
                        } else {
                          _audioPlayer.resume();
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Barra de progreso inferior en el mini reproductor
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                minHeight: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

