import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CalculatorPage(),
      );
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String expression = '';
  String result = '0';

  static const operators = ['+', '-', '×', '÷', '*', '/'];

  void onButtonPressed(String btn) {
    setState(() {
      final ops = ['+', '-', '×', '÷', '*', '/'];
      bool lastIsOp = expression.isNotEmpty && ops.contains(expression.characters.last);

      switch (btn) {
        case 'AC':
          expression = '';
          result = '0';
          break;
        case 'C':
          if (expression.isNotEmpty) 
            expression = expression.substring(0, expression.length - 1);
          break;
        case '=':
          calculateResult();
          break;
        default:
          if (ops.contains(btn)) {
            if (expression.isEmpty && btn != '-') {
              return;
            }

            if (lastIsOp) {
              final before = expression.characters.last;
              if (before == btn) {
                expression = expression.substring(0, expression.length - 1);
                expression += btn;
                return;
              } else if (btn == '-' && ops.contains(before)) {
                expression += btn;
                return;
              } else {
                expression = expression.substring(0, expression.length - 1) + btn;
                return;
              }
            }
          }

          if (btn == '.') {
            final parts = expression.split(RegExp(r'[+\-×÷*/]'));
            if (parts.isNotEmpty && parts.last.contains('.')) {
              return;
            }
          }

          expression += btn;
      }
    });
    debugPrint('Button pressed: $btn');
  }


  void calculateResult() {
    try {
      final expString = expression.replaceAll('×', '*').replaceAll('÷', '/');
      Parser p = Parser();
      Expression exp = p.parse(expString);
      ContextModel cm = ContextModel();
      num eval = exp.evaluate(EvaluationType.REAL, cm);
      result = eval.toString();
    } catch (_) {
      result = 'Error';
    }
  }

  static const buttons = [
    'AC','C','÷','×',
    '7','8','9','-',
    '4','5','6','+',
    '1','2','3','=',
    '0','.'
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: const Text('Calculator', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(child: Column(children: [
        SizedBox(
          height: displayH,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  expression.isEmpty ? '0' : expression,
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                  textAlign: TextAlign.right,
                ),
                Text(
                  result,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.right,
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
                final b = buttons[i];
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: const CircleBorder(),
                  ),
                  onPressed: () => onButtonPressed(b),
                  child: Text(b, style: const TextStyle(fontSize: 24, color: Colors.white)),
                );
              },
            ),
          ),
        ),
      ])),
    );
  }
}
