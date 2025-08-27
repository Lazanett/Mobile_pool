import 'package:flutter/material.dart';

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
  bool _isPressed = false;
  String _searchText = '';


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: TextField(
          controller: _textController,
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
                  onTap: () {
                    setState(() {
                      _searchText = _textController.text;
                    });
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
                  onTap: () {
                    setState(() {
                      _searchText = "Geolocation";
                    });
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
          Center(child: Text('Currently: $_searchText', style: const TextStyle(fontSize: 24))),
          Center(child: Text('Today: $_searchText', style: const TextStyle(fontSize: 24))),
          Center(child: Text('Weekly: $_searchText', style: const TextStyle(fontSize: 24))),
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