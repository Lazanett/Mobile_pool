import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _textController;
  
  List<Map<String, dynamic>> _suggestions = [];
  bool _loadingSuggestions = false;
  String _error = '';
  String _weatherInfo = '';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchCitySuggestions(String query) async {
    if (query.length < 2) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() {
      _loadingSuggestions = true;
      _error = '';
    });

    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=fr'
    );

    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final list = data['results'] as List<dynamic>? ?? [];
        setState(() {
          _suggestions = list.map((e) => {
            'name': e['name'],
            'region': e['admin1'] ?? '',
            'country': e['country'],
            'lat': e['latitude'],
            'lon': e['longitude'],
          }).toList();
        });
      } else {
        setState(() => _error = 'Erreur suggestions (${resp.statusCode})');
      }
    } catch (e) {
      setState(() => _error = 'Erreur réseau suggestions');
    } finally {
      setState(() => _loadingSuggestions = false);
    }
  }

  Future<void> _fetchWeather(double lat, double lon, String cityName) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true'
    );

    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final temp = data['current_weather']['temperature'];
        setState(() => _weatherInfo = '🌤 $cityName : $temp °C');
      } else {
        setState(() => _weatherInfo = 'Erreur météo (${resp.statusCode})');
      }
    } catch (e) {
      setState(() => _weatherInfo = 'Erreur réseau météo');
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => _error = 'Services de localisation désactivés');
      return;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    
    if (perm == LocationPermission.denied) {
      setState(() => _error = 'Permission refusée');
      return;
    }
    
    if (perm == LocationPermission.deniedForever) {
      setState(() => _error = 'Permission refusée définitivement');
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    _textController.text = '${pos.latitude},${pos.longitude}';
    setState(() => _error = '');
    await _fetchWeather(pos.latitude, pos.longitude, 'Localisation');
  }

  Widget _buildSuggestions() {
    if (_loadingSuggestions) return const LinearProgressIndicator();
    if (_error.isNotEmpty) return Text(_error, style: const TextStyle(color: Colors.red));
    
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _suggestions.length,
      itemBuilder: (c, i) {
        final s = _suggestions[i];
        return ListTile(
          title: Text('${s['name']}, ${s['region']}, ${s['country']}'),
          onTap: () {
            _textController.text = s['name'];
            setState(() => _suggestions = []);
            _fetchWeather(s['lat'], s['lon'], s['name']);
          },
        );
      },
    );
  }

  Widget _buildTabContent(String title) {
    if (title == 'Currently') {
      return Column(
        children: [
          if (_suggestions.isNotEmpty) _buildSuggestions(),
          Expanded(
            child: Center(
              child: Text(
                _weatherInfo.isEmpty ? 'Recherchez une ville ou utilisez votre localisation' : _weatherInfo,
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }
    return Center(child: Text('$title section', style: const TextStyle(fontSize: 24)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: TextField(
          controller: _textController,
          onChanged: (value) {
            _fetchCitySuggestions(value);
          },
          decoration: InputDecoration(
            hintText: 'Search city...',
            hintStyle: TextStyle(color: Colors.indigo[600]!),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo[600]!, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo[600]!, width: 2),
            ),
          ),
          style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    await _fetchCitySuggestions(_textController.text);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.indigo[600],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    await _getCurrentLocation();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.indigo[600],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.my_location, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.indigo[600],
            height: 2.0,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent('Currently'),
          _buildTabContent('Today'),
          _buildTabContent('Weekly'),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.access_time), text: "Currently"),
              Tab(icon: Icon(Icons.today), text: "Today"),
              Tab(icon: Icon(Icons.calendar_view_week), text: "Weekly"),
            ],
            labelColor: Colors.indigo[600],
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.indigo[600],
          ),
        ),
      ),
    );
  }
}