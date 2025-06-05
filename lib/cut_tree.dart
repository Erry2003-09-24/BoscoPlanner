import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/location_services.dart';
import 'services/weather_services.dart';

class CutTreePage extends StatefulWidget {
  @override
  _CutTreePageState createState() => _CutTreePageState();
}

class _CutTreePageState extends State<CutTreePage> {
  Position? _position;
  Map<String, dynamic>? _weatherData;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _operations = [];

  @override
  void initState() {
    super.initState();
    _loadOperations();
    _loadData();
  }

  // Carica operazioni salvate
  Future<void> _loadOperations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final opsString = prefs.getString('operations') ?? '[]';
    setState(() {
      _operations = List<Map<String, dynamic>>.from(jsonDecode(opsString));
    });
  }

  // Salva la lista operazioni in locale
  Future<void> _saveOperations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('operations', jsonEncode(_operations));
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final position = await LocationService.getCurrentPosition();
      final weather = await WeatherService.getWeather(
          position.latitude, position.longitude);

      setState(() {
        _position = position;
        _weatherData = weather;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Errore nel caricamento dati: $e';
        _loading = false;
      });
    }
  }

  bool _isWeatherGoodForCut() {
    if (_weatherData == null) return false;

    String mainWeather = _weatherData!['weather'][0]['main'].toString().toLowerCase();

    if (mainWeather.contains('rain') || mainWeather.contains('snow') || mainWeather.contains('storm')) {
      return false;
    }
    return true;
  }

  // save the cut operation
  // and show a confirmation dialog
  void _saveOperation() async {
    final newOp = {
      'type': 'tagliato',
      'date': DateTime.now().toIso8601String(),
      'latitude': _position?.latitude,
      'longitude': _position?.longitude,
    };
    setState(() {
      _operations.add(newOp);
    });
    await _saveOperations();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Intervento registrato'),
        content: Text(
            'Albero tagliato in posizione:\nLat: ${_position?.latitude.toStringAsFixed(5)}\nLon: ${_position?.longitude.toStringAsFixed(5)}'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK'))
        ],
      ),
    );
  }

  Widget _buildWeatherInfo() {
    if (_weatherData == null) return SizedBox();

    String description = _weatherData!['weather'][0]['description'];
    double temp = _weatherData!['main']['temp'];
    String iconCode = _weatherData!['weather'][0]['icon'];
    String iconUrl = 'http://openweathermap.org/img/wn/$iconCode@2x.png';

    return Card(
      margin: EdgeInsets.all(12),
      child: ListTile(
        leading: Image.network(iconUrl),
        title: Text('${temp.toStringAsFixed(1)} °C'),
        subtitle: Text(description),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCut = _isWeatherGoodForCut();

    return Scaffold(
      appBar: AppBar(
        title: Text('Taglia un albero', style: TextStyle(fontWeight: FontWeight.bold),),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green[700],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Posizione attuale:\nLat: ${_position?.latitude.toStringAsFixed(5)}\nLon: ${_position?.longitude.toStringAsFixed(5)}',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Text('Meteo attuale:', style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildWeatherInfo(),
                      SizedBox(height: 20),
                      Text(
                        canCut ? 'Condizioni favorevoli per il taglio' : 'Condizioni meteo NON favorevoli',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: canCut ? Colors.green : Colors.red, // Color based on condition
                            fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: Icon(Icons.save, color: Colors.white,),
                        label: Text('Conferma taglio', style: TextStyle(color: Colors.white),),
                        onPressed: canCut ? _saveOperation : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canCut ? Colors.green[700] : Colors.grey,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
