import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:test/spot_the_difference_game.dart';
import 'package:flame/components.dart' show Vector2;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();

  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spot the Difference',
      home: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SpotTheDifferenceGameWidget(
                maxSize: Vector2(
                  constraints.biggest.width,
                  constraints.biggest.height,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
