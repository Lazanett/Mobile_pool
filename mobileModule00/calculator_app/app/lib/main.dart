import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const CalculatorPage(),
        theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: Colors.black,
        ),
      );
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String expression = '';
  String result = '0';
  
  static const buttons = [
    'AC', 'C', '÷', '×',
    '7', '8', '9', '-',
    '4', '5', '6', '+',
    '1', '2', '3', '=',
    '0', '.',
  ];

  static const operators = ['+', '-', '×', '÷', '*', '/'];

  bool _isSmallScreen(BoxConstraints constraints) {
    return constraints.maxWidth < 600 || constraints.maxHeight < 400;
  }

  bool _isLandscape(BoxConstraints constraints) {
    return constraints.maxWidth > constraints.maxHeight;
  }

  double _calculateButtonSize(BoxConstraints constraints, int itemsPerRow, int totalRows) {
    final availableWidth = constraints.maxWidth - (16 * 2);
    final displayRatio = _isLandscape(constraints) ? 0.2 : 0.3;
    final availableHeight = (constraints.maxHeight * (1 - displayRatio)) - (16 * 2);

    final widthBasedSize = (availableWidth - (8 * (itemsPerRow - 1))) / itemsPerRow;
    final heightBasedSize = (availableHeight - (8 * (totalRows - 1))) / totalRows;

    double size = (widthBasedSize < heightBasedSize ? widthBasedSize : heightBasedSize);

    if (_isLandscape(constraints)) {
      return size.clamp(25.0, 60.0);
    } else {
      return size.clamp(30.0, 70.0);
    }
  }

  int _getGridColumns(BoxConstraints constraints) {
    if (_isLandscape(constraints) && constraints.maxWidth > 800) {
      return 6;
    } else if (_isLandscape(constraints)) {
      return 5;
    }
    return 4;
  }

  List<String> _getAdaptedButtons(int columns) {
    if (columns == 4) {
      return buttons; // Layout standard
    } else if (columns == 5) {
      return [
        'AC', 'C', '÷', '×', '',
        '7', '8', '9', '-', '',
        '4', '5', '6', '+', '',
        '1', '2', '3', '=', '',
        '0', '.', '', '', '',
      ];
    } else {
      return [
        'AC', 'C', '×', '÷', '', '',
        '7', '8', '9', '-', '', '',
        '4', '5', '6', '+', '', '',
        '1', '2', '3', '=', '', '',
        '0', '.', '', '', '', '',
      ];
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: const Text('Calculator', style: TextStyle(color: Colors.white)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = _isSmallScreen(constraints);
          final isLandscape = _isLandscape(constraints);
          final columns = _getGridColumns(constraints);
          final adaptedButtons = _getAdaptedButtons(columns);
          final rows = (adaptedButtons.length / columns).ceil();
          final buttonSize = _calculateButtonSize(constraints, columns, rows);
          
          final displayHeight = isLandscape 
              ? (constraints.maxHeight * 0.2).clamp(60.0, 120.0)
              : (constraints.maxHeight * 0.3).clamp(100.0, 200.0);
          
          final smallFontSize = isLandscape ? 14.0 : (isSmall ? 16.0 : 18.0);
          final largeFontSize = isLandscape ? 20.0 : (isSmall ? 24.0 : 32.0);

          return SafeArea(
            child: Column(
              children: [
                Container(
                  height: displayHeight,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: isLandscape ? 8 : 16
                  ),
                  child: isLandscape 
                      ? _buildLandscapeDisplay(smallFontSize, largeFontSize)
                      : _buildPortraitDisplay(smallFontSize, largeFontSize),
                ),
                
                const Divider(height: 1, thickness: 2, color: Colors.grey),
                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        mainAxisExtent: buttonSize,
                      ),
                      itemCount: adaptedButtons.length,
                      itemBuilder: (context, index) {
                        final buttonText = adaptedButtons[index];

                        if (buttonText.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        
                        return _buildCalculatorButton(
                          buttonText,
                          buttonSize,
                          isSmall,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Affichage compact pour paysage
  Widget _buildLandscapeDisplay(double smallFontSize, double largeFontSize) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                expression.isEmpty ? '0' : expression,
                style: TextStyle(
                  fontSize: smallFontSize,
                  color: Colors.grey,
                  height: 1.2,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                result,
                style: TextStyle(
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Affichage standard pour portrait
  Widget _buildPortraitDisplay(double smallFontSize, double largeFontSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            width: double.infinity,
            alignment: Alignment.bottomRight,
            child: Text(
              expression.isEmpty ? '0' : expression,
              style: TextStyle(
                fontSize: smallFontSize,
                color: Colors.grey,
                height: 1.2,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Container(
            width: double.infinity,
            alignment: Alignment.bottomRight,
            child: Text(
              result,
              style: TextStyle(
                fontSize: largeFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculatorButton(String text, double size, bool isSmall) {
    Color backgroundColor;
    Color textColor = Colors.white;
    
    if (['÷', '×', '-', '+', '=','AC', 'C'].contains(text)) {
      backgroundColor = Colors.orange;
    } else {
      backgroundColor = Colors.grey[800]!;
    }
    
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          elevation: 4,
        ),
        onPressed: () => onButtonPressed(text),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isSmall ? 18 : 22,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}