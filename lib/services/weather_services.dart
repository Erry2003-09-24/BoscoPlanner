import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = '60781f0fb2b6dbd0757becf330b38032';

  static Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=it';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero dati meteo');
    }

    return json.decode(response.body);
  }
}
