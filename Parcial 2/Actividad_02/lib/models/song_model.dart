class Song {
  final int id;
  final String titulo;
  final String artista;
  final String album;
  final int duracionSeg;
  final bool favorita;
  final String portadaUrl;
  final String audioUrl;

  Song({
    required this.id,
    required this.titulo,
    required this.artista,
    required this.album,
    required this.duracionSeg,
    required this.favorita,
    required this.portadaUrl,
    required this.audioUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? 'Desconocido',
      artista: json['artista'] ?? 'Desconocido',
      album: json['album'] ?? 'Desconocido',
      duracionSeg: json['duracion_seg'] ?? 0,
      favorita: json['favorita'] ?? false,
      portadaUrl: json['portada_url'] != null && json['portada_url'].toString().isNotEmpty 
          ? json['portada_url'] 
          : 'https://picsum.photos/300',
      audioUrl: json['audio_url'] ?? '',
    );
  }

  Song copyWith({
    bool? favorita,
  }) {
    return Song(
      id: id,
      titulo: titulo,
      artista: artista,
      album: album,
      duracionSeg: duracionSeg,
      favorita: favorita ?? this.favorita,
      portadaUrl: portadaUrl,
      audioUrl: audioUrl,
    );
  }
}

