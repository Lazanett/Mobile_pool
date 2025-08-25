import 'package:flutter/material.dart';

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
  String currentInput = '0';
  String previousInput = '0';
  
  static const buttons = [
    'AC', 'C', '/', '*',
    '7', '8', '9', '-',
    '4', '5', '6', '+',
    '1', '2', '3', '=',
    '0', '.',
  ];

  // Détermine si l'écran est petit (mobile en portrait)
  bool _isSmallScreen(BoxConstraints constraints) {
    return constraints.maxWidth < 600 || constraints.maxHeight < 400;
  }

  // Détermine si l'orientation est paysage
  bool _isLandscape(BoxConstraints constraints) {
    return constraints.maxWidth > constraints.maxHeight;
  }

  // Calcule la taille des boutons en fonction de l'écran
  double _calculateButtonSize(BoxConstraints constraints, int itemsPerRow, int totalRows) {
    final availableWidth = constraints.maxWidth - (16 * 2); // padding
    // En paysage, on laisse plus d'espace pour l'affichage
    final displayRatio = _isLandscape(constraints) ? 0.2 : 0.3;
    final availableHeight = (constraints.maxHeight * (1 - displayRatio)) - (16 * 2);
    
    final widthBasedSize = (availableWidth - (8 * (itemsPerRow - 1))) / itemsPerRow;
    final heightBasedSize = (availableHeight - (8 * (totalRows - 1))) / totalRows;
    
    return (widthBasedSize < heightBasedSize ? widthBasedSize : heightBasedSize)
        .clamp(35.0, 100.0); // Taille min plus petite pour mobile paysage
  }

  // Détermine le nombre de colonnes en fonction de la taille d'écran
  int _getGridColumns(BoxConstraints constraints) {
    if (_isLandscape(constraints) && constraints.maxWidth > 800) {
      return 6; // Tablette en paysage
    } else if (_isLandscape(constraints)) {
      return 5; // Mobile en paysage
    }
    return 4; // Portrait standard
  }

  // Adapte la disposition des boutons selon les colonnes
  List<String> _getAdaptedButtons(int columns) {
    if (columns == 4) {
      return buttons; // Layout standard
    } else if (columns == 5) {
      // Layout mobile paysage - on peut ajouter des espaces
      return [
        'AC', 'C', '/', '*', '',
        '7', '8', '9', '-', '',
        '4', '5', '6', '+', '',
        '1', '2', '3', '=', '',
        '0', '.', '', '', '',
      ];
    } else {
      // Layout tablette - plus d'espacement
      return [
        'AC', 'C', '', '/', '*', '',
        '7', '8', '9', '-', '', '',
        '4', '5', '6', '+', '', '',
        '1', '2', '3', '=', '', '',
        '0', '.', '', '', '', '',
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = _isSmallScreen(constraints);
          final isLandscape = _isLandscape(constraints);
          final columns = _getGridColumns(constraints);
          final adaptedButtons = _getAdaptedButtons(columns);
          final rows = (adaptedButtons.length / columns).ceil();
          final buttonSize = _calculateButtonSize(constraints, columns, rows);
          
          // Hauteur de l'affichage adaptative - plus conservative en paysage
          final displayHeight = isLandscape 
              ? (constraints.maxHeight * 0.2).clamp(60.0, 120.0)
              : (constraints.maxHeight * 0.3).clamp(100.0, 200.0);
          
          // Tailles de police adaptatives
          final smallFontSize = isLandscape ? 14.0 : (isSmall ? 16.0 : 18.0);
          final largeFontSize = isLandscape ? 20.0 : (isSmall ? 24.0 : 32.0);

          return SafeArea(
            child: Column(
              children: [
                // Zone d'affichage
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
                
                // Zone des boutons
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

  Widget _buildCalculatorButton(String text, double size, bool isSmall) {
    Color backgroundColor;
    Color textColor = Colors.white;
    
    if (['/', '*', '-', '+', '=','AC', 'C'].contains(text)) {
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
        onPressed: () => _onButtonPressed(text),
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


  Widget _buildLandscapeDisplay(double smallFontSize, double largeFontSize) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                previousInput,
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
                currentInput,
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
            ],
          ),
        ),
      ],
    );
  }

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
              previousInput,
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
              currentInput,
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

  void _onButtonPressed(String buttonText) {
    setState(() {
      switch (buttonText) {
        case 'AC':
          currentInput = '0';
          previousInput = '0';
          break;
        case 'C':
          currentInput = '0';
          break;
        case '=':
          previousInput = currentInput;
          break;
        default:
          break;
      }
    });
    
    debugPrint('Button pressed: $buttonText');
  }
}