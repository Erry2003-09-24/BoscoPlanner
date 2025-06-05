import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _operations = [];

  List<Map<String, dynamic>> _piantati = [];
  List<Map<String, dynamic>> _tagliati = [];

  @override
  void initState() {
    super.initState();
    _loadOperations();
  }

  Future<void> _loadOperations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final opsString = prefs.getString('operations') ?? '[]';
    List<dynamic> jsonList = jsonDecode(opsString);

    setState(() {
      _operations = List<Map<String, dynamic>>.from(jsonList);
      _piantati = _operations.where((op) => op['type'] == 'piantato').toList();
      _tagliati = _operations.where((op) => op['type'] == 'tagliato').toList();
    });
  }

  String _formatDate(String isoDate) {
    DateTime dt = DateTime.parse(isoDate).toLocal();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} ${twoDigits(dt.hour)}:${twoDigits(dt.minute)}';
  }

  Future<void> _clearHistory() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Conferma'),
            content: const Text(
              'Sei sicuro di voler cancellare tutto lo storico?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Conferma',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('operations');
      setState(() {
        _operations.clear();
        _piantati.clear();
        _tagliati.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Storico cancellato')));
    }
  }

  Widget _buildList(
    String title,
    List<Map<String, dynamic>> list,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          list.isEmpty
              ? Text(
                'Nessuna operazione',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              )
              : Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final op = list[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(icon, color: color, size: 32),
                        title: Text(
                          'Albero $title',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: color.withOpacity(0.9),
                          ),
                        ),
                        subtitle: Text(
                          'ID: ${op['id']}\n'
                          'Data: ${_formatDate(op['date'])}\n'
                          'Lat: ${op['latitude'].toStringAsFixed(5)}, Long: ${op['longitude'].toStringAsFixed(5)}',
                          style: const TextStyle(fontSize: 14, height: 1.3),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  void _handleClearPressed() {
    if (_operations.isEmpty) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Errore'),
              content: const Text(
                'Lo storico è già vuoto. Nessuna operazione da cancellare.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } else {
      _clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Storico operazioni',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (_operations.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Nessuna operazione registrata',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    _buildList(
                      'piantati',
                      _piantati,
                      Icons.nature,
                      Colors.green[700]!,
                    ),
                    const SizedBox(height: 16),
                    _buildList(
                      'tagliati',
                      _tagliati,
                      Icons.delete,
                      Colors.red[700]!,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _handleClearPressed,
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: const Text(
                'Cancella storico',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}