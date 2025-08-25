import 'package:flutter/material.dart';

void main() {
  runApp(
    LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (width < 375 || height < 667) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          );
        }
        return const MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CalculatorPage(),
      );
}

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  static const buttons = [
    'AC','C','/','*',
    '7','8','9','-',
    '4','5','6','+',
    '1','2','3','=',
    '0','.',
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenW = media.size.width;
    final screenH = media.size.height -
        kToolbarHeight -
        media.padding.top -
        media.padding.bottom;

    final displayH = screenH * 0.3;

    final buttonsH = screenH - displayH - 2;

    const perRow = 4;
    final rows = (buttons.length / perRow).ceil();

    final btnSize = ((screenW - 8 * (perRow + 1)) / perRow)
        .clamp(50.0, (buttonsH - 8 * (rows + 1)) / rows);

    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    if (screenWidth < 375 || screenHeight < 400) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: const Text('Calculator', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(children: [
          SizedBox(
            height: displayH,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextField(
                    readOnly: true,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      border: InputBorder.none,
                    ),
                    controller: TextEditingController(text: '0'),
                  ),
                  TextField(
                    readOnly: true,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      border: InputBorder.none,
                    ),
                    controller: TextEditingController(text: '0'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 2),
          SizedBox(
            height: buttonsH,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: perRow,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: btnSize,
                ),
                itemCount: buttons.length,
                itemBuilder: (_, i) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: const CircleBorder(),
                    ),
                    onPressed: () => debugPrint('Button pressed: ${buttons[i]}'),
                    child: Text(
                      buttons[i],
                      style: const TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
