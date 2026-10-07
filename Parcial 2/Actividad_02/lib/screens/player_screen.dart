import 'dart:math';
import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import '../models/song_model.dart';
import '../services/supabase_service.dart';
import '../core/theme.dart';

class PlayerScreen extends StatefulWidget {
  final int initialIndex;
  const PlayerScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;
  
  List<Song> _songs = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _hasError = false;
  String _errorMessage = '';
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _loadSongs();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
        if (_isPlaying) {
          _animationController.repeat();
        } else {
          _animationController.stop();
        }
      });
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() => _duration = newDuration);
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() => _position = newPosition);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _nextTrack();
    });
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await SupabaseService().getSongs();
      setState(() {
        _songs = songs;
        _hasError = false;
      });
      if (_songs.isNotEmpty) {
        _playSong();
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'No hay canciones en la base de datos';
        });
      }
    } catch (e) {
      print('Error loading songs: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _playSong() async {
    if (_songs.isEmpty) return;
    final song = _songs[_currentIndex];
    if (song.audioUrl.isEmpty) return;
    try {
      await _audioPlayer.play(UrlSource(song.audioUrl));
    } catch (e) {
      print('Error al reproducir audio: $e');
    }
  }

  void _pauseSong() async {
    await _audioPlayer.pause();
  }

  void _nextTrack() {
    if (_songs.isEmpty) return;
    if (_currentIndex < _songs.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0; // Loop back
    }
    _playSong();
  }

  void _previousTrack() {
    if (_songs.isEmpty) return;
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _songs.length - 1;
    }
    _playSong();
  }

  void _seekForward() {
    final newPosition = _position + const Duration(seconds: 10);
    _audioPlayer.seek(newPosition < _duration ? newPosition : _duration);
  }

  void _seekBackward() {
    final newPosition = _position - const Duration(seconds: 10);
    _audioPlayer.seek(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _songs.isNotEmpty ? _songs[_currentIndex] : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          currentSong?.album ?? 'Loading...',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: _hasError 
          ? Center(child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(_errorMessage, textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent)),
            ))
          : currentSong == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Vinyl Record
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (_, child) {
                      return Transform.rotate(
                        angle: _animationController.value * 2 * pi,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                        border: Border.all(color: Colors.grey[800]!, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.05),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ],
                        image: DecorationImage(
                          image: NetworkImage(currentSong.portadaUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!, width: 10),
                          ),
                          child: Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Metadata
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.titulo,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentSong.artista,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          currentSong.favorita ? Icons.favorite : Icons.favorite_border,
                          color: currentSong.favorita ? AppTheme.primaryColor : Colors.white,
                        ),
                        onPressed: () async {
                          await SupabaseService().toggleFavorite(currentSong.id, currentSong.favorita);
                          setState(() {
                            _songs[_currentIndex] = currentSong.copyWith(favorita: !currentSong.favorita);
                          });
                        },
                      ),
                    ],
                  ),

                  // Progress Bar
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(_position), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(_formatDuration(_duration), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Slider(
                        min: 0,
                        max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
                        value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1),
                        onChanged: (value) {
                          _audioPlayer.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                    ],
                  ),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10),
                        color: Colors.grey[400],
                        onPressed: _seekBackward, // -10s
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        color: Colors.white,
                        iconSize: 32,
                        onPressed: _previousTrack,
                      ),
                      Container(
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                          color: Colors.white,
                          iconSize: 32,
                          onPressed: _isPlaying ? _pauseSong : _playSong,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        color: Colors.white,
                        iconSize: 32,
                        onPressed: _nextTrack,
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10),
                        color: Colors.grey[400],
                        onPressed: _seekForward, // +10s
                      ),
                    ],
                  ),
                  
                  // Bottom extra controls (like volume/mute as seen in image)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_off, size: 20),
                        color: Colors.grey[600],
                        onPressed: () => _audioPlayer.setVolume(0),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_down, size: 20),
                        color: Colors.grey[600],
                        onPressed: () => _audioPlayer.setVolume(0.5),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, size: 20),
                        color: Colors.grey[600],
                        onPressed: () => _audioPlayer.setVolume(1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

