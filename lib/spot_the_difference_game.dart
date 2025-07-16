import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LevelData {
  final String imagePath;
  final List<Rect> correctAreas;
  LevelData({required this.imagePath, required this.correctAreas});
}

class SpotTheDifferenceGameWidget extends StatefulWidget {
  final Vector2 maxSize;
  const SpotTheDifferenceGameWidget({required this.maxSize, super.key});

  @override
  State<SpotTheDifferenceGameWidget> createState() =>
      _SpotTheDifferenceGameWidgetState();
}

class _SpotTheDifferenceGameWidgetState
    extends State<SpotTheDifferenceGameWidget> {
  late final SpotTheDifferenceGame game;
  bool showIntro = true;

  final TextEditingController empIdController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    game = SpotTheDifferenceGame();
  }

  @override
  void dispose() {
    empIdController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void startGame() {
    if (empIdController.text.isEmpty || nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')));
      return;
    }

    game.setPlayerInfo(
      empIdController.text,
      nameController.text,
    ); // ✅ เพิ่มตรงนี้

    setState(() {
      showIntro = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showIntro) {
      return Scaffold(
        backgroundColor: Color(0xfffbf2e3),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/game_logo.png', height: 300),
                  const SizedBox(height: 10),
                  const Text(
                    'วิธีการเล่น',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '- ปรับโทรศัพท์ให้อยู่ในแนวนอน\n'
                    '- แตะจุดที่คิดว่าทำให้เกิดคาร์บอนไดออกไซด์\n'
                    '- แตะครบ 4 จุด หรือครบจำนวนสูงสุด\n'
                    '- กดปุ่ม Next เพื่อไปเลเวลถัดไป\n'
                    '- เมื่อจบเกมจะแสดงคะแนนรวม',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // กรอกข้อมูลรหัสพนักงาน
                  TextField(
                    controller: empIdController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'รหัสพนักงาน',
                      labelStyle: const TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // กรอกชื่อ-สกุล
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'ชื่อ-สกุล',
                      labelStyle: const TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'เริ่มเกม',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return GameWidget(
        game: game,
        overlayBuilderMap: {
          'next_button': (_, SpotTheDifferenceGame g) {
            return Positioned(
              right: 16,
              bottom: 16,
              child: ValueListenableBuilder<bool>(
                valueListenable: g.isLevelCompleteNotifier,
                builder: (ctx, visible, child) {
                  return visible
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            g.goToNextLevel();
                          },
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
            );
          },
          'victory_overlay': (_, SpotTheDifferenceGame g) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xfffbf2e3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'จบเกม!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'คะแนนรวม: ${g.score}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    //const SizedBox(height: 24),
                    //ElevatedButton(
                    //  onPressed: () {
                    //   g.current = 0;
                    //    g.score = 0;
                    //   g.loadLevel(g.current);
                    //  g.overlays.remove('victory_overlay');
                    // },
                    //style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.blueAccent,
                    //padding: const EdgeInsets.symmetric(
                    //horizontal: 32,
                    //vertical: 12,
                    //),
                    //shape: RoundedRectangleBorder(
                    // borderRadius: BorderRadius.circular(8),
                    // ),
                    //),
                    //child: const Text(
                    //'เริ่มใหม่',
                    //style: TextStyle(
                    //fontSize: 18,
                    //fontWeight: FontWeight.bold,
                    //color: Colors.white,
                    //),
                    //),
                    //),
                  ],
                ),
              ),
            );
          },
        },
      );
    }
  }
}

class SpotTheDifferenceGame extends FlameGame with TapCallbacks {
  final ValueNotifier<bool> isLevelCompleteNotifier = ValueNotifier(false);
  final ValueNotifier<int> tapCountNotifier = ValueNotifier(0);
  final int maxTaps = 4;
  final Set<int> found = {};
  int score = 0;
  bool canTap = true;

  String? empId;
  String? playerName;
  void setPlayerInfo(String id, String name) {
    empId = id;
    playerName = name;
  }

  Future<void> sendScoreToGoogleSheet() async {
    if (empId == null || playerName == null) {
      debugPrint("❌ Missing empId or playerName, skip sending");
      return;
    }

    final urlStr =
        'https://script.google.com/macros/s/AKfycbxolsN0RIvvW5UMOrF3ZRJ2FXq1wY_xa2eTuKV1rgCcttvRnoFbhc92OLne7CX7VHhIBw/exec';
    debugPrint("→ POST to URL: $urlStr");
    final payload = {
      'employeeId': empId,
      'name': playerName,
      'gameId': "game1",
      'score': score,
    };
    debugPrint("→ Payload: ${jsonEncode(payload)}");

    try {
      final response = await http.post(
        Uri.parse(urlStr),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      debugPrint("← Status: ${response.statusCode}");
      debugPrint("← Body: ${response.body}");
    } catch (e) {
      debugPrint("❌ send error: $e");
    }
  }

  // Flag ควบคุมการแสดง highlight เฉพาะตอนจบ level เท่านั้น
  bool showHighlights = false;

  late final List<LevelData> levels = [
    LevelData(
      imagePath: 'game_background.png',
      correctAreas: [
        Rect.fromLTWH(550, 0, 580, 140),
        Rect.fromLTWH(1250, 110, 350, 260),
        Rect.fromLTWH(1400, 770, 320, 350),
        Rect.fromLTWH(480, 700, 130, 150),
      ],
    ),
    LevelData(
      imagePath: 'game_background_2.png',
      correctAreas: [
        Rect.fromLTWH(750, 0, 450, 140),
        Rect.fromLTWH(700, 550, 120, 120),
        Rect.fromLTWH(1250, 410, 420, 300),
        Rect.fromLTWH(1170, 770, 150, 100),
      ],
    ),
    LevelData(
      imagePath: 'game_background_3.png',
      correctAreas: [
        Rect.fromLTWH(75, 450, 340, 210),
        Rect.fromLTWH(900, 300, 150, 150),
        Rect.fromLTWH(1200, 200, 150, 180),
        Rect.fromLTWH(1380, 50, 140, 300),
      ],
    ),
    LevelData(
      imagePath: 'game_background_4.png',
      correctAreas: [
        Rect.fromLTWH(550, 210, 175, 100),
        Rect.fromLTWH(250, 180, 100, 150),
        Rect.fromLTWH(750, 190, 185, 95),
        Rect.fromLTWH(900, 200, 870, 700),
      ],
    ),
    LevelData(
      imagePath: 'game_background_5.png',
      correctAreas: [
        Rect.fromLTWH(50, 180, 540, 410),
        Rect.fromLTWH(50, 600, 300, 250),
        Rect.fromLTWH(1250, 50, 500, 390),
        Rect.fromLTWH(1050, 470, 580, 150),
      ],
    ),
  ];

  int current = 0;
  SpriteComponent? background;
  Vector2 imageSize = Vector2.zero();
  Vector2 scaleRatio = Vector2.all(1.0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await Flame.images.loadAll(levels.map((l) => l.imagePath).toList());
    loadLevel(current);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (imageSize.x != 0 && imageSize.y != 0) {
      scaleRatio = Vector2(size.x / imageSize.x, size.y / imageSize.y);
    }
    if (background != null) {
      background!
        ..size = size
        ..position = Vector2.zero();
    }
    for (final detector in children.whereType<FullScreenTapDetector>()) {
      detector
        ..size = size
        ..position = Vector2.zero();
    }
    // เรียก refresh highlight ก็ต่อเมื่อ flag เปิดอยู่เท่านั้น
    if (showHighlights) {
      refreshCorrectAreasHighlight();
    }
  }

  void loadLevel(int idx) async {
    if (idx < 0 || idx >= levels.length) {
      debugPrint('Invalid level index: $idx');
      return;
    }

    removeAll(children.where((c) => c is! CameraComponent));

    canTap = true;
    found.clear();
    tapCountNotifier.value = 0;
    isLevelCompleteNotifier.value = false;
    showHighlights = false; // ปิดการแสดง highlight ตอนเริ่ม level

    final lvl = levels[idx];
    final img = await images.load(lvl.imagePath);
    imageSize = Vector2(img.width.toDouble(), img.height.toDouble());

    scaleRatio = Vector2(
      canvasSize.x / imageSize.x,
      canvasSize.y / imageSize.y,
    );

    background = SpriteComponent(
      sprite: Sprite(img),
      position: Vector2.zero(),
      size: canvasSize,
      anchor: Anchor.topLeft,
      priority: -1,
    );
    add(background!);

    add(
      FullScreenTapDetector(handleTap)
        ..size = canvasSize
        ..position = Vector2.zero()
        ..priority = 10,
    );
  }

  void handleTap(Vector2 position) {
    if (!canTap) return;

    tapCountNotifier.value++;

    final orig = Offset(position.x / scaleRatio.x, position.y / scaleRatio.y);
    final lvl = levels[current];

    bool ok = false;
    for (int i = 0; i < lvl.correctAreas.length; i++) {
      if (lvl.correctAreas[i].contains(orig) && !found.contains(i)) {
        ok = true;
        found.add(i);
        score += 3;
        break;
      }
    }

    final c =
        CircleComponent(
          radius: 30,
          position: position,
          anchor: Anchor.center,
          paint: Paint()
            ..color = (ok ? Colors.greenAccent : Colors.redAccent).withAlpha(
              180,
            ),
          priority: 15,
        )..add(
          OpacityEffect.to(
            0,
            EffectController(duration: 0.8, reverseDuration: 0.4),
          ),
        );
    add(c);

    if (tapCountNotifier.value >= maxTaps ||
        found.length >= lvl.correctAreas.length) {
      canTap = false;
      Future.delayed(const Duration(seconds: 1), showComplete);
    }
  }

  void showComplete() {
    showHighlights = true; // เปิด flag เพื่อแสดง highlight
    refreshCorrectAreasHighlight();
    isLevelCompleteNotifier.value = true;
    overlays.add('next_button');
  }

  void refreshCorrectAreasHighlight() {
    if (!showHighlights) return;

    if (current < 0 || current >= levels.length) {
      print(
        'refreshCorrectAreasHighlight called with invalid current: $current',
      );
      return; // ป้องกันไม่ให้เกิด index out of range
    }

    background?.children.whereType<RectangleComponent>().toList().forEach(
      (element) => element.removeFromParent(),
    );

    final lvl = levels[current];
    for (final area in lvl.correctAreas) {
      final r = Rect.fromLTWH(
        area.left * scaleRatio.x,
        area.top * scaleRatio.y,
        area.width * scaleRatio.x,
        area.height * scaleRatio.y,
      );
      final rc = RectangleComponent(
        position: Vector2(r.left, r.top),
        size: Vector2(r.width, r.height),
        paint: Paint()..color = Colors.green.withAlpha(128),
      );
      background?.add(rc);
    }
  }

  void goToNextLevel() {
    overlays.remove('next_button');
    current++;
    if (current >= levels.length) {
      current = levels.length - 1; // ป้องกันไม่ให้ current เกิน
      showVictory();
    } else {
      loadLevel(current);
    }
  }

  void showVictory() {
    overlays.remove('next_button');
    overlays.add('victory_overlay');
    removeAll(children.where((c) => c is! CameraComponent));
    sendScoreToGoogleSheet();
  }
}

class FullScreenTapDetector extends PositionComponent with TapCallbacks {
  final void Function(Vector2 localPosition) onTap;

  FullScreenTapDetector(this.onTap);

  @override
  void onTapDown(TapDownEvent event) {
    onTap(event.localPosition);
  }
}
