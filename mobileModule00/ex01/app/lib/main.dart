import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String displayText = 'Module00 ex01';

  void _toggleText() {
    setState(() {
      displayText = (displayText == 'Module00 ex01') ? 'Hello World!' : 'Module00 ex01';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(displayText),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleText,
              child: const Text('Click me'),
            ),
          ],
        ),
      ),
    );
  }
}
