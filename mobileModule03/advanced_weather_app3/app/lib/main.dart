import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

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
  State createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State with SingleTickerProviderStateMixin {
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
  Map<String, String>? _locationInfo;
  bool _showNoResultsError = false;
  bool _showConnectionError = false;
  String _displayLocation = '';
  double _currentTemp = 0.0;
  String _currentEmoji = '';
  String _currentDesc = '';
  double _currentWind = 0.0;

  
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
      setState(() {
        _suggestions = [];
        _showNoResultsError = false;
        _showConnectionError = false;
      });
      return;
    }
    
    setState(() {
      _loadingSuggestions = true;
      _error = '';
      _showConnectionError = false;
    });
    
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=fr'
    );
    
    try {
      final resp = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );
      
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final list = data['results'] as List? ?? [];
        
        setState(() {
          _suggestions = list.map((e) => {
            'name': e['name'],
            'region': e['admin1'] ?? '',
            'country': e['country'],
            'lat': e['latitude'],
            'lon': e['longitude'],
          }).toList();
          
          if (_suggestions.isEmpty && query.length >= 2) {
            _showNoResultsError = true;
          } else {
            _showNoResultsError = false;
          }
        });
      } else {
        setState(() {
          _showConnectionError = true;
          _showNoResultsError = false;
        });
      }
    } catch (e) {
      setState(() {
        _showConnectionError = true;
        _showNoResultsError = false;
      });
    } finally {
      setState(() => _loadingSuggestions = false);
    }
  }
  
  // Reverse geocoding pour obtenir ville, région, pays à partir des coordonnées
  Future<Map<String, String>> _reverseGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=fr'
      );
      
      final resp = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );
      
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        
        return {
          'name': data['city'] ?? data['locality'] ?? data['principalSubdivision'] ?? 'Ville inconnue',
          'region': data['principalSubdivision'] ?? '',
          'country': data['countryName'] ?? '',
        };
      } else {
        return {
          'name': 'Position actuelle',
          'region': '',
          'country': '',
        };
      }
    } catch (e) {
      return {
        'name': 'Position actuelle',
        'region': '',
        'country': '',
      };
    }
  }
  
  // Conversion of values to String 
  Map<String, String> convertMap(Map<String, dynamic> original) {
    return original.map((key, value) {
      return MapEntry(key, value?.toString() ?? '');
    });
  }
  
  String formatLocation(Map<String, String>? locationInfo, String cityName) {
    if (locationInfo == null) {
      return cityName;
    }
    final parts = <String>[];
    if (locationInfo['name'] != null && locationInfo['name']!.isNotEmpty) {
      parts.add(locationInfo['name']!);
    }
    if (locationInfo['region'] != null && locationInfo['region']!.isNotEmpty) {
      parts.add(locationInfo['region']!);
    }
    if (locationInfo['country'] != null && locationInfo['country']!.isNotEmpty) {
      parts.add(locationInfo['country']!);
    }
    return parts.isNotEmpty ? parts.join(', ') : cityName;
  }
  
  // get weather
  Future<void> _fetchWeather(double lat, double lon, String cityName, {Map<String, String>? locationInfo}) async {
    _latitude = lat;
    _longitude = lon;
    _currentCityName = cityName;
    
    setState(() {
      _showConnectionError = false;
      _showNoResultsError = false;
    });
    
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat'
      '&longitude=$lon'
      '&current_weather=true'
      '&current=weathercode,windspeed_10m'
      '&hourly=temperature_2m,weathercode,windspeed_10m'
      '&daily=temperature_2m_max,temperature_2m_min,weathercode'
      '&timezone=auto'
    );
    
    try {
      final resp = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );
      
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        
        final cw = data['current_weather'];
        final double temp = cw['temperature'];
        final double wind = cw['windspeed'];
        final int code = cw['weathercode'];
        final desc = _mapWeatherCode(code);
        _currentLocalTime = DateTime.parse(cw['time']);
        
        _hourlyWeather = [];
        final times = List<String>.from(data['hourly']['time']);
        final temps = List<double>.from(data['hourly']['temperature_2m']);
        final codes = List<int>.from(data['hourly']['weathercode']);
        final winds = List<double>.from(data['hourly']['windspeed_10m']);
        
        final emoji = _emojiForWeatherCode(code);
        
        for (int i = 0; i < times.length && _currentLocalTime != null; i++) {
          final time = DateTime.parse(times[i]);
          if (time.isAfter(_currentLocalTime!) && time.day == _currentLocalTime!.day) {
            final temp = temps[i];
            final code = codes[i];
            final windVal = winds[i];
            _hourlyWeather.add({
              'time': time,
              'temperature': temp,
              'code': code,
              'wind': windVal,
            });
          }
        }
        
        _dailyWeather = [];
        final dTimes = List<String>.from(data['daily']['time']);
        final dMax = List<double>.from(data['daily']['temperature_2m_max']);
        final dMin = List<double>.from(data['daily']['temperature_2m_min']);
        
        // CORRECTION : Récupérer les codes météo daily depuis l'API
        final dCodes = data['daily']['weathercode'] != null 
            ? List<int>.from(data['daily']['weathercode'])
            : <int>[];
        
        for (int i = 0; i < dTimes.length; i++) {
          _dailyWeather.add({
            'date': DateTime.parse(dTimes[i]),
            'temp_max': dMax[i],
            'temp_min': dMin[i],
            'code': i < dCodes.length ? dCodes[i] : 0,
            'wind': i < winds.length ? winds[i] : 0.0,
          });
        }
        
        final displayLocation = formatLocation(locationInfo, cityName);
        
        setState(() {
          _locationInfo = locationInfo;
          _currentCityName = cityName;
          _displayLocation = displayLocation;
          _currentTemp = temp;
          _currentEmoji = emoji;
          _currentDesc = desc;
          _currentWind = wind;
          _weatherInfo = '$displayLocation\n...';
        });
      } else {
        setState(() {
          _showConnectionError = true;
          _weatherInfo = '';
        });
      }
    } catch (e) {
      setState(() {
        _showConnectionError = true;
        _weatherInfo = '';
      });
    }
  }
  
  // 🎯 Mapper le code météo Open-Meteo vers une description humaine
  String _mapWeatherCode(int? code) {
    if (code == null) return 'Unknown';
    if (code == 0) return 'Clear ';
    if (code == 1 || code == 2 || code == 3) return 'Partly cloudy';
    if (code == 45 || code == 48) return 'Fog';
    if (code >= 51 && code <= 67) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Downpours';
    if (code >= 95) return 'Storm';
    return 'Unknown';
  }
  
  String _emojiForWeatherCode(int? code) {
    if (code == null) return '❓';
    if (code == 0) return '☀️';
    if (code == 1 || code == 2 || code == 3) return '⛅';
    if (code == 45 || code == 48) return '🌫️';
    if (code >= 51 && code <= 67) return '🌧️';
    if (code >= 71 && code <= 77) return '❄️';
    if (code >= 80 && code <= 82) return '🌦️';
    if (code >= 95) return '🌩️';
    return '❓';
  }
    
  // function for the Today body
  Widget _buildTodayTab() {
  if (_hourlyWeather.isEmpty) {
      return const Center(child: Text('No hourly data available'));
    }

    final nowLocal = _currentLocalTime ?? DateTime.now();
    final filteredHours = _hourlyWeather.where((hourData) {
      final time = hourData['time'] as DateTime;
      return time.day == nowLocal.day;
    }).toList();

    if (filteredHours.isEmpty) {
      return const Center(child: Text('No data for today'));
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  formatLocation(_locationInfo, _currentCityName),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Graphique
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final containerWidth = screenWidth < 400 
                        ? screenWidth * 0.95 
                        : constraints.maxWidth * 0.95;

                    return Center(
                      child: Container(
                        width: containerWidth,
                        height: screenWidth < 400 ? 240 : 270,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 12, 
                          horizontal: screenWidth < 400 ? 8 : 16,
                        ),
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 40,
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 5,
                                  reservedSize: screenWidth < 400 ? 30 : 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}°',
                                      style: TextStyle(
                                        fontSize: screenWidth < 400 ? 10 : 12,
                                        color: Colors.indigo[600],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: screenWidth < 400 ? 25 : 30,
                                  getTitlesWidget: (value, meta) {
                                    int hour = value.toInt();
                                    if (hour >= 0 && hour <= 23) {
                                      return Text(
                                        '${hour}h',
                                        style: TextStyle(
                                          fontSize: screenWidth < 400 ? 8 : 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo[600],
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              horizontalInterval: 5,
                              drawVerticalLine: true,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey.withOpacity(0.3),
                                strokeWidth: 0.7,
                              ),
                              getDrawingVerticalLine: (value) => FlLine(
                                color: Colors.grey.withOpacity(0.3),
                                strokeWidth: 0.7,
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey.withOpacity(0.5)),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (final hourData in filteredHours)
                                    FlSpot(
                                      (hourData['time'] as DateTime).hour.toDouble(),
                                      (hourData['temperature'] as num).toDouble(),
                                    ),
                                ],
                                isCurved: true,
                                gradient: LinearGradient(
                                  colors: [Colors.orange, Colors.redAccent],
                                ),
                                barWidth: screenWidth < 400 ? 3 : 4,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  height: 210,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredHours.length,
                    itemBuilder: (context, index) {
                      final hourData = filteredHours[index];
                      final time = hourData['time'] as DateTime;
                      final temp = hourData['temperature'];
                      final double wind = hourData['wind'] ?? 0.0;
                      final int? code = hourData['code'] as int?;
                      final emoji = _emojiForWeatherCode(code);
                      final desc = _mapWeatherCode(code);
                      final timeStr = '${time.hour.toString().padLeft(2, '0')}:00';

                      return Container(
                        width: 130,
                        margin: const EdgeInsets.only(right: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(timeStr,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(emoji, style: const TextStyle(fontSize: 26)),
                                const SizedBox(height: 6),
                                Text(desc,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 6),
                                Text('${temp}°C',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.air,
                                        size: 14, color: Colors.blueGrey),
                                    const SizedBox(width: 4),
                                    Text('${wind.toStringAsFixed(0)} km/h',
                                        style: const TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
    
  String _formatDateToFrench(DateTime date) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final dayName = weekdays[date.weekday - 1];
    return '$dayName ${date.day} ${_monthNameInFrench(date.month)}';
  }
  
  String _monthNameInFrench(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September ', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
  
  // function for the weekly body
  Widget _buildWeeklyTab() {
    if (_dailyWeather.isEmpty) {
      return const Center(child: Text('No daily data available'));
    }
    
    final today = _currentLocalTime ?? DateTime.now();
    int startIndex = _dailyWeather.indexWhere((dayData) {
      final date = dayData['date'] as DateTime;
      return date.year == today.year && date.month == today.month && date.day == today.day;
    });
    
    if (startIndex == -1) startIndex = 0;
    final weekData = _dailyWeather.skip(startIndex).take(7).toList();
    
    return Center(
      child: SizedBox(
        width: 360,
        child: Column(
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                formatLocation(_locationInfo, _currentCityName),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: weekData.length,
                itemBuilder: (context, index) {
                  final day = weekData[index];
                  final date = day['date'] as DateTime;
                  final tempMax = day['temp_max'];
                  final tempMin = day['temp_min'];
                  final code = day['code'] as int?;
                  final wind = day['wind'] as double? ?? 0.0;
                  final emoji = _emojiForWeatherCode(code);
                  final desc = _mapWeatherCode(code);
                  final formattedDate = _formatDateToFrench(date);
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Card(
                      elevation: 2,
                      child: ListTile(
                        leading: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          formattedDate,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(desc),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Max: ${tempMax.toString()}°C'),
                            Text('Min: ${tempMin.toString()}°C'),
                            Text('Vent: ${wind.toStringAsFixed(0)} km/h'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // getCurrentLocation - VERSION AVEC REVERSE GEOCODING
  Future<void> _getCurrentLocation() async {
    setState(() {
      _error = '';
      _showNoResultsError = false;
      _showConnectionError = false;
    });
    
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => _error = 'Geolocation is not available, please enable it in your App settings.');
      return;
    }
    
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      setState(() => _error = 'Geolocation is not available, please enable it in your App settings.');
      return;
    }
    if (perm == LocationPermission.deniedForever) {
      setState(() => _error = 'Geolocation is not available, please enable it in your App settings.');
      return;
    }
    
    try {

      final pos = await Geolocator.getCurrentPosition();
      final locationInfo = await _reverseGeocode(pos.latitude, pos.longitude);
      _textController.text = '${locationInfo['name']} (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
      await _fetchWeather(pos.latitude, pos.longitude, 'Location', locationInfo: locationInfo);
      
    } catch (e) {
      setState(() => _error = 'Error during geolocation: $e');
    }
  }
  
  // style suggestion
  Widget _buildSuggestions() {
    if (_loadingSuggestions) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const LinearProgressIndicator(),
      );
    }
    
    if (_error.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          _error, 
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final limitedSuggestions = _suggestions.take(5).toList();

    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: limitedSuggestions.length,
        itemBuilder: (c, i) {
          final s = limitedSuggestions[i];
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: i < limitedSuggestions.length - 1 
                  ? BorderSide(color: Colors.grey.shade300, width: 0.5)
                  : BorderSide.none,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              dense: true,
              title: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(c).style,
                  children: [
                    TextSpan(
                      text: s['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ', ${s['region']}, ${s['country']}'),
                  ],
                ),
              ),
              onTap: () {
                _textController.text = s['name'];
                setState(() {
                  _suggestions = [];
                  _showNoResultsError = false;
                  _showConnectionError = false;
                });
                final locationInfo = {
                  'name': s['name'],
                  'region': s['region'],
                  'country': s['country'],
                };
                _fetchWeather(s['lat'], s['lon'], s['name'], locationInfo: convertMap(locationInfo));
              },
            ),
          );
        },
      ),
    );
  }

  // create content of body for the 3 slides
  Widget _buildTabContent(String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 375) {
      return const SizedBox.shrink();
    }

    if (_showConnectionError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'The service connection is lost, please check your internet connection or try again later.',
              style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _showConnectionError = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_showNoResultsError) {
      return const Center(
        child: Text(
          'Could not find any result for the supplied address or coordinates.',
          style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              _error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w500
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

    if (title == 'Currently') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: _weatherInfo.isEmpty
                ? const Text(
                    'Search for a city or use your location',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  )
                : Text.rich(
                    TextSpan(
                      style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20),
                      children: [
                        TextSpan(
                          text: '$_displayLocation\n\n',
                          style: const TextStyle(color: Colors.indigo, fontSize: 26, fontWeight: FontWeight.bold, decoration: TextDecoration.none,),
                          
                        ),
                        TextSpan(
                          text: '${_currentTemp.toStringAsFixed(1)} °C\n',
                          style: const TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                        ),
                        TextSpan(
                          text: _currentEmoji,
                          style: const TextStyle(fontSize: 40,
                          decoration: TextDecoration.none),

                        ),
                        TextSpan(
                          text: ' \n$_currentDesc\n\n',
                          style: const TextStyle(fontSize: 18,
                          decoration: TextDecoration.none,
                          color: Color(0xFF424242)),
                        ),
                        TextSpan(
                          text: '💨 ${_currentWind.toStringAsFixed(1)} km/h',
                          style: const TextStyle(fontSize: 15,
                          decoration: TextDecoration.none,
                          color: Color(0xFF424242)),
                        ),
                      ],
                    ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 375) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: Colors.transparent,
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
              fillColor: Colors.white.withOpacity(0.01),
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
                        color: Colors.indigo[600]!.withOpacity(0.9),
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
                        color: Colors.indigo[600]!.withOpacity(0.9),
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
              color: Colors.indigo[600]!.withOpacity(0.8),
              height: 2.0,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/sky.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top),
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
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.01),
            ],
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 60,
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
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overlayColor: MaterialStateProperty.resolveWith(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                    return Colors.white.withOpacity(0.1);
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}