import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

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
  List<Map<String, dynamic>> _hourlyWeather = [];
  List<Map<String, dynamic>> _dailyWeather = [];
  double? _latitude;
  double? _longitude;
  String _currentCityName = '';
  late tz.Location _timezone;
  DateTime? _currentLocalTime;



  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
    tzdata.initializeTimeZones();
    _timezone = tz.getLocation('Europe/Paris'); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // get city suggestion
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

  // get weather
  Future<void> _fetchWeather(double lat, double lon, String cityName) async {
    _latitude = lat;
    _longitude = lon;
    _currentCityName = cityName;

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m&daily=temperature_2m_max,temperature_2m_min&timezone=auto'
    );

    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);

        final temp = data['current_weather']['temperature'];
        _currentLocalTime = DateTime.parse(data['current_weather']['time']);

        final List<String> times = List<String>.from(data['hourly']['time']);
        final List<dynamic> temps = data['hourly']['temperature_2m'];

        _hourlyWeather = [];

        for (int i = 0; i < times.length; i++) {
          final time = DateTime.parse(times[i]);
          final tempVal = temps[i];

          if (_currentLocalTime == null) return;
          final sameDate = time.year == _currentLocalTime!.year &&
              time.month == _currentLocalTime!.month &&
              time.day == _currentLocalTime!.day;

          final isAfterNow = time.isAfter(_currentLocalTime!);

          if (sameDate && isAfterNow) {
            _hourlyWeather.add({
              'time': time,
              'temperature': tempVal,
            });
          }
        }
        final List<String> dailyTimes = List<String>.from(data['daily']['time']);
        final List<dynamic> tempsMax = data['daily']['temperature_2m_max'];
        final List<dynamic> tempsMin = data['daily']['temperature_2m_min'];

        _dailyWeather = [];
        for (int i = 0; i < dailyTimes.length; i++) {
          DateTime date = DateTime.parse(dailyTimes[i]);
          _dailyWeather.add({
            'date': date,
            'temp_max': tempsMax[i],
            'temp_min': tempsMin[i],
          });
        }

        setState(() => _weatherInfo = '🌤 $cityName : $temp °C');
      } else {
        setState(() => _weatherInfo = 'Erreur météo (${resp.statusCode})');
      }
    } catch (e) {
      setState(() => _weatherInfo = 'Erreur réseau météo');
    }
  }

  // function for the Today body
  Widget _buildTodayTab() {
    if (_hourlyWeather.isEmpty) {
      return Center(child: Text('Aucune donnée horaire disponible'));
    }

    final nowLocal = _currentLocalTime ?? DateTime.now();

    final filteredHours = _hourlyWeather.where((hourData) {
      final time = hourData['time'] as DateTime;
      return time.isAfter(nowLocal) && time.hour <= 23;
    }).toList();

    if (filteredHours.isEmpty) {
      return Center(child: Text('Pas de données pour le reste de la journée'));
    }

    return Center(
      child: Container(
        width: 300,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shrinkWrap: true,
          itemCount: filteredHours.length,
          itemBuilder: (context, index) {
            final hourData = filteredHours[index];
            final time = hourData['time'] as DateTime;
            final temp = hourData['temperature'];
            final timeStr = '${time.hour.toString().padLeft(2, '0')}:00';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 30,
                    child: Icon(Icons.access_time, size: 20, color: Colors.indigo[600]),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      timeStr,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '🌤',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$temp °C',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // function for the weekly body
  Widget _buildWeeklyTab() {
    if (_dailyWeather.isEmpty) {
      return Center(child: Text('Aucune donnée quotidienne disponible'));
    }

    final today = _currentLocalTime ?? DateTime.now();

    int startIndex = _dailyWeather.indexWhere((dayData) {
      final date = dayData['date'] as DateTime;
      return date.year == today.year && date.month == today.month && date.day == today.day;
    });

    if (startIndex == -1) startIndex = 0;

    final weekData = _dailyWeather.skip(startIndex).take(7).toList();

    return Center(
      child: Container(
        width: 300,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shrinkWrap: true,
          itemCount: weekData.length,
          itemBuilder: (context, index) {
            final day = weekData[index];
            final date = day['date'] as DateTime;
            final tempMax = day['temp_max'];
            final tempMin = day['temp_min'];

            final dayName = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
            final dateStr = '${date.day}/${date.month}';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      dayName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 60,
                    child: Text(
                      dateStr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '🌤',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Min: $tempMin°C  Max: $tempMax°C',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // getCurrentLocation
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

  // style suggestion
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

  // create content of body for the 3 slides
  Widget _buildTabContent(String title) {

    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 375) {
      return const SizedBox.shrink(); 
    }
    if (title == 'Currently') {
      return Column(
        children: [
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
    } else if (title == 'Today') {
      return _buildTodayTab();
    } else if (title == 'Weekly') {
      return _buildWeeklyTab();
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

      body: Column(
        children: [
          if (_suggestions.isNotEmpty) _buildSuggestions(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('Currently'),
                _buildTabContent('Today'),
                _buildTabContent('Weekly'),
              ],
            ),
          ),
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
            unselectedLabelColor: Colors.indigo[600],
            indicatorColor: Colors.indigo[600],
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                  return Colors.transparent;
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }

}