import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Crystal Basket', theme: ThemeData(primarySwatch: Colors.blue), home: const GameScreen());
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

  // Таймеры
  Ticker? gameTimer;
  Timer? speedTimer;

  // Скорость падения кристаллов
  double fallSpeed = 3.0;

  // Счет
  int score = 0;

  // Пропущенные кристаллы
  int missedCrystals = 0;

  // Максимальное количество пропущенных кристаллов
  static const int maxMissedCrystals = 3;

  // Игра окончена
  bool isGameOver = false;

  // Скорость движения корзинки
  static const double moveSpeed = 8.0;

  // Флаги для отслеживания нажатых клавиш
  bool isMovingLeft = false;
  bool isMovingRight = false;

  // FocusNode для клавиатуры
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    startGame();
  }

  // Запускаем игру
  void startGame() {
    score = 0;
    missedCrystals = 0;
    isGameOver = false;
    fallSpeed = 3.0;
    isMovingLeft = false;
    isMovingRight = false;
    crystals.clear();

    // Для обновления игры с частотой обновления экрана используем Ticker вместо Timer
    gameTimer = Ticker((timer) {
      if (!isGameOver) {
        updateGame();
      }
    });
    gameTimer?.start();

    // Таймер увеличения скорости
    speedTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!isGameOver) {
        setState(() {
          fallSpeed += 0.5; // Увеличиваем скорость каждые 5 секунд
        });
      }
    });
  }

  // Обновляем игру
  void updateGame() {
    setState(() {
      // Обновляем позицию корзинки
      if (isMovingLeft) {
        playerX = (playerX - moveSpeed).clamp(0.0, screenWidth - 50);
      }
      if (isMovingRight) {
        playerX = (playerX + moveSpeed).clamp(0.0, screenWidth - 50);
      }

      // Обновляем позиции кристаллов
      for (int i = 0; i < crystals.length; i++) {
        crystals[i] = Crystal(x: crystals[i].x, y: crystals[i].y + fallSpeed);
      }

      // Проверяем пропущенные кристаллы
      for (var crystal in crystals.toList()) {
        if (crystal.y > screenHeight) {
          crystals.remove(crystal);
          missedCrystals++;
          if (missedCrystals >= maxMissedCrystals) {
            gameOver();
            return;
          }
        }
      }

      // Создаем новые кристаллы
      if (Random().nextDouble() < 0.02) {
        crystals.add(Crystal(x: Random().nextDouble() * (screenWidth - 50), y: -50));
      }

      // Проверяем сбор кристаллов
      for (var crystal in crystals.toList()) {
        if (checkCollection(crystal)) {
          crystals.remove(crystal);
          score += 10;
        }
      }
    });
  }

  // Проверяем сбор кристаллов
  bool checkCollection(Crystal crystal) {
    return (playerX < crystal.x + 50 &&
        playerX + 50 > crystal.x &&
        screenHeight - 100 < crystal.y + 50 &&
        screenHeight - 100 + 50 > crystal.y);
  }

  // Игра окончена
  void gameOver() {
    setState(() {
      isGameOver = true;
      gameTimer?.dispose();
      speedTimer?.cancel();
    });
  }

  // Обработка нажатий клавиш
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        isMovingLeft = true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        isMovingRight = true;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        isMovingLeft = false;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        isMovingRight = false;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    gameTimer?.dispose();
    speedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
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
              // Счетчики
              Positioned(
                top: 50,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Score: $score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Speed: ${fallSpeed.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18)),
                    Text(
                      'Missed: $missedCrystals/$maxMissedCrystals',
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ],
                ),
              ),
              // Экран окончания игры
              if (isGameOver)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Game Over!', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Text('Final Score: $score', style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            startGame();
                          });
                        },
                        child: const Text('Play Again'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
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
