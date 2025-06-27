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
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: TextField(
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
            child: Listener(
              onPointerDown: (_) {
                setState(() {
                  _isPressed = true;
                });
              },
              onPointerUp: (_) {
                setState(() {
                  _isPressed = false;
                });
              },
              onPointerCancel: (_) {
                setState(() {
                  _isPressed = false;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isPressed ? Colors.transparent : Colors.indigo[600],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.indigo[600]!,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.search,
                  color: _isPressed ? Colors.indigo[600] : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text('Currently', style: TextStyle(fontSize: 24))),
          Center(child: Text('Today', style: TextStyle(fontSize: 24))),
          Center(child: Text('Weekly', style: TextStyle(fontSize: 24))),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
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
    );
  }
}
