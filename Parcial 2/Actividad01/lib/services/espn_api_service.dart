import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nfl_scoreboard.dart';

class EspnApiService {
  static const String _url = 'https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard';

  Future<NflScoreboard?> fetchScoreboard({DateTime? date}) async {
    try {
      String url = _url;
      if (date != null) {
        String formattedDate = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
        url = '$_url?dates=$formattedDate';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NflScoreboard.fromJson(data);
      } else {
        print('Error fetching data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception fetching data: $e');
      return null;
    }
  }
}

