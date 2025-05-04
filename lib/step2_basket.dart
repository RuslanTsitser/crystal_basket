import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crystal Basket - Step 2',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Позиция корзинки
  double playerX = 0.0;

  // Размеры экрана
  late double screenWidth;
  late double screenHeight;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          playerX += details.delta.dx;
          playerX = playerX.clamp(0.0, screenWidth - 50);
        });
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Stack(
          children: [
            // Корзинка
            Positioned(
              left: playerX,
              bottom: 100,
              child: Container(
                width: 50,
                height: 50,
                color: Colors.transparent,
                child: const Center(child: Text('🧺', style: TextStyle(fontSize: 30))),
              ),
            ),
            // Инструкция
            const Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Text(
                'Step 2: Movable Basket\n\n'
                'Swipe left/right to move the basket\n\n'
                'Next steps:\n'
                '- Add falling crystals\n'
                '- Add score counter',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
