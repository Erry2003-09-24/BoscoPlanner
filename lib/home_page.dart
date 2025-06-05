import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'services/location_services.dart';
import 'services/weather_services.dart';
import 'plant_tree.dart';
import 'cut_tree.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _currentPosition;
  Map<String, dynamic>? _weatherData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final position = await LocationService.getCurrentPosition();
      final weather = await WeatherService.getWeather(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentPosition = position;
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

  Widget _buildWeatherCard() {
    if (_weatherData == null) return SizedBox();

    String description = _weatherData!['weather'][0]['description'];
    double temp = _weatherData!['main']['temp'];
    int humidity = _weatherData!['main']['humidity'];
    double windSpeed = _weatherData!['wind']['speed'];
    String iconCode = _weatherData!['weather'][0]['icon'];
    String iconUrl = 'http://openweathermap.org/img/wn/$iconCode@2x.png';

    return Card(
      margin: EdgeInsets.all(12),
      child: ListTile(
        leading: Image.network(iconUrl),
        title: Text('${temp.toStringAsFixed(1)} °C'),
        subtitle: Text('$description\nUmidità: $humidity%\nVento: ${windSpeed} m/s'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('BoscoPlanner', style: TextStyle(fontWeight: FontWeight.bold),),),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Aggiorna dati',
          )
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Posizione attuale:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Lat: ${_currentPosition?.latitude.toStringAsFixed(5) ?? "-"}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Lon: ${_currentPosition?.longitude.toStringAsFixed(5) ?? "-"}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Meteo attuale:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    _buildWeatherCard(),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.nature, color: Colors.white),
                            label: Text('Pianta un albero',style: TextStyle(color: Colors.white),),
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => PlantTreePage())),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: Colors.green[700],
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            icon: Icon(Icons.cut, color: Colors.white),
                            label: Text('Taglia un albero', style: TextStyle(color: Colors.white),),
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => CutTreePage())),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: Colors.green[700],
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            icon: Icon(Icons.history, color: Colors.white),
                            label: Text('Storico operazioni', style: TextStyle(color: Colors.white),),
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => HistoryPage())),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}
