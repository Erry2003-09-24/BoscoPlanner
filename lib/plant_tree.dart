import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; // Importa UUID
import 'services/location_services.dart';

class PlantTreePage extends StatefulWidget {
  @override
  _PlantTreePageState createState() => _PlantTreePageState();
}

class _PlantTreePageState extends State<PlantTreePage> {
  Position? _position;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _operations = [];

  final Uuid _uuid = Uuid(); // Crea istanza UUID

  @override
  void initState() {
    super.initState();
    _loadOperations();
    _getPosition();
  }

  Future<void> _loadOperations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final opsString = prefs.getString('operations') ?? '[]';
    setState(() {
      _operations = List<Map<String, dynamic>>.from(jsonDecode(opsString));
    });
  }

  Future<void> _getPosition() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final position = await LocationService.getCurrentPosition();
      setState(() {
        _position = position;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Errore nel recupero posizione: $e';
        _loading = false;
      });
    }
  }

  void _saveOperation() async {
    if (_position == null) {
      setState(() {
        _error = "Posizione non disponibile";
      });
      return;
    }

    final newOp = {
      'id': _uuid.v4(),  // Genera un id unico
      'type': 'piantato',
      'date': DateTime.now().toIso8601String(),
      'latitude': _position!.latitude,
      'longitude': _position!.longitude,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final opsString = prefs.getString('operations') ?? '[]';
    List<dynamic> ops = jsonDecode(opsString);
    ops.add(newOp);
    await prefs.setString('operations', jsonEncode(ops));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Albero piantato'),
        content: Text(
            'Albero piantato in posizione:\nLat: ${_position!.latitude.toStringAsFixed(5)}\nLon: ${_position!.longitude.toStringAsFixed(5)}\nID: ${newOp['id']}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // chiudi dialog
              Navigator.pop(context); // torna indietro
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pianta un albero', style: TextStyle(fontWeight: FontWeight.bold),),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: _loading
            ? CircularProgressIndicator(color: Colors.green[700])
            : _error != null
                ? Text(
                    _error!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.nature, size: 100, color: Colors.green[700]),
                      SizedBox(height: 16),
                      Text(
                        'Posizione attuale:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                          'Latitudine: ${_position?.latitude.toStringAsFixed(5)}'),
                      Text(
                          'Longitudine: ${_position?.longitude.toStringAsFixed(5)}'),
                      SizedBox(height: 30),
                      ElevatedButton.icon(
                        icon: Icon(Icons.save, color: Colors.white),
                        label: Text('Conferma e salva', style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          textStyle: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _saveOperation,
                      ),
                    ],
                  ),
      ),
    );
  }
}