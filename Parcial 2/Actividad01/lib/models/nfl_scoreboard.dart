class NflScoreboard {
  final List<NflEvent> events;
  final int seasonYear;
  final int weekNumber;

  NflScoreboard({required this.events, required this.seasonYear, required this.weekNumber});

  factory NflScoreboard.fromJson(Map<String, dynamic> json) {
    final season = json['season'] ?? {};
    final week = json['week'] ?? {};
    return NflScoreboard(
      seasonYear: season['year'] ?? DateTime.now().year,
      weekNumber: week['number'] ?? 1,
      events: (json['events'] as List?)?.map((e) => NflEvent.fromJson(e)).toList() ?? [],
    );
  }
}

class NflEvent {
  final String id;
  final String name;
  final String shortName;
  final String state; // 'pre', 'in', 'post'
  final String detail; // e.g. "Q3 08:42"
  final NflCompetition? competition;
  final DateTime? date;

  NflEvent({
    required this.id,
    required this.name,
    required this.shortName,
    required this.state,
    required this.detail,
    this.competition,
    this.date,
  });

  factory NflEvent.fromJson(Map<String, dynamic> json) {
    final status = json['status'] ?? {};
    final type = status['type'] ?? {};
    final competitions = (json['competitions'] as List?) ?? [];
    
    return NflEvent(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      state: type['state'] ?? 'pre',
      detail: type['detail'] ?? '',
      competition: competitions.isNotEmpty ? NflCompetition.fromJson(competitions[0]) : null,
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
    );
  }
}

class NflCompetition {
  final List<NflCompetitor> competitors;
  final NflSituation? situation;

  NflCompetition({required this.competitors, this.situation});

  factory NflCompetition.fromJson(Map<String, dynamic> json) {
    return NflCompetition(
      competitors: (json['competitors'] as List?)?.map((e) => NflCompetitor.fromJson(e)).toList() ?? [],
      situation: json['situation'] != null ? NflSituation.fromJson(json['situation']) : null,
    );
  }
}

class NflCompetitor {
  final String id;
  final String teamName;
  final String abbreviation;
  final String logo;
  final String score;
  final String record;
  final List<int> lineScores;
  final bool isHome;

  NflCompetitor({
    required this.id,
    required this.teamName,
    required this.abbreviation,
    required this.logo,
    required this.score,
    required this.record,
    required this.lineScores,
    required this.isHome,
  });

  factory NflCompetitor.fromJson(Map<String, dynamic> json) {
    final team = json['team'] ?? {};
    final records = json['records'] as List?;
    String rec = '';
    if (records != null && records.isNotEmpty) {
      rec = records[0]['summary'] ?? '';
    }
    
    final ls = json['linescores'] as List?;
    List<int> lines = [];
    if (ls != null) {
      lines = ls.map((e) => (e['value'] as num?)?.toInt() ?? 0).toList();
    }

    return NflCompetitor(
      id: json['id'] ?? '',
      teamName: team['name'] ?? '',
      abbreviation: team['abbreviation'] ?? '',
      logo: team['logo'] ?? '',
      score: json['score'] ?? '0',
      record: rec,
      lineScores: lines,
      isHome: json['homeAway'] == 'home',
    );
  }
}

class NflSituation {
  final String possession;
  final String downDistanceText;
  final int yardLine;
  final String possessionText;
  final String lastPlayText;

  NflSituation({
    required this.possession,
    required this.downDistanceText,
    required this.yardLine,
    required this.possessionText,
    required this.lastPlayText,
  });

  factory NflSituation.fromJson(Map<String, dynamic> json) {
    final lastPlay = json['lastPlay'] ?? {};
    return NflSituation(
      possession: json['possession']?.toString() ?? '',
      downDistanceText: json['downDistanceText'] ?? '',
      yardLine: json['yardLine'] ?? 0,
      possessionText: json['possessionText'] ?? '',
      lastPlayText: lastPlay['text'] ?? '',
    );
  }
}

