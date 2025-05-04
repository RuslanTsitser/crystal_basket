import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crystal Basket - Step 3',
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

  // Кристаллы
  List<Crystal> crystals = [];

  // Таймер
  Timer? gameTimer;

  // Скорость падения кристаллов
  double fallSpeed = 3.0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  // Запускаем игру
  void startGame() {
    crystals.clear();

    // Запускаем таймер
    // Таймер вызывается каждые 50 миллисекунд
    // и вызывает updateGame
    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      updateGame();
    });
  }

  // Обновляем игру
  void updateGame() {
    setState(() {
      // Обновляем позиции кристаллов
      for (int i = 0; i < crystals.length; i++) {
        crystals[i] = Crystal(x: crystals[i].x, y: crystals[i].y + fallSpeed);
      }

      // Удаляем кристаллы, которые вышли за пределы экрана
      crystals.removeWhere((crystal) => crystal.y > screenHeight);

      // Создаем новые кристаллы
      if (Random().nextDouble() < 0.02) {
        crystals.add(Crystal(x: Random().nextDouble() * (screenWidth - 50), y: -50));
      }
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

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
            // Кристаллы
            ...crystals.map(
              (crystal) => Positioned(
                left: crystal.x,
                top: crystal.y,
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.transparent,
                  child: const Center(child: Text('💎', style: TextStyle(fontSize: 30))),
                ),
              ),
            ),
            // Инструкция
            const Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Text(
                'Step 3: Falling Crystals\n\n'
                'Crystals fall from the top\n\n'
                'Next steps:\n'
                '- Add score counter\n'
                '- Add game over condition',
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

class Crystal {
  final double x;
  final double y;

  const Crystal({required this.x, required this.y});
}
