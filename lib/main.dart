import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const BahbohApp());
}

class BahbohApp extends StatelessWidget {
  const BahbohApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bahboh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(scaffoldBackgroundColor: const Color(0xFF04070E)),
      home: const BahbohSplashScreen(),
    );
  }
}

enum BubbleTone { red, orange, yellow, green, blue, indigo, violet }

enum BubbleSizeKind { small, medium, large }

class BubbleVisual {
  const BubbleVisual({
    required this.core,
    required this.glow,
    required this.rim,
    required this.reflection,
    required this.highlight,
  });

  final Color core;
  final Color glow;
  final Color rim;
  final Color reflection;
  final Color highlight;
}

class BubbleRecipe {
  const BubbleRecipe({
    required this.id,
    required this.colors,
    required this.minCount,
  });

  final String id;
  final Set<BubbleTone> colors;
  final int minCount;
}

class BubbleEntity {
  BubbleEntity({
    required this.id,
    required this.tone,
    required this.size,
    required this.position,
    required this.velocity,
  });

  final int id;
  final BubbleTone tone;
  final BubbleSizeKind size;
  Offset position;
  Offset velocity;
  bool settled = false;
  double wobble = 0.0;
}

class ResidueCloud {
  ResidueCloud({
    required this.position,
    required this.color,
    required this.baseRadius,
    required this.maxLife,
  }) : life = maxLife;

  final Offset position;
  final Color color;
  final double baseRadius;
  final double maxLife;
  double life;
}

class AtmosBubble {
  AtmosBubble({
    required this.position,
    required this.radius,
    required this.color,
    required this.riseSpeed,
    required this.drift,
    required this.phase,
    required this.opacity,
  });

  Offset position;
  final double radius;
  final Color color;
  final double riseSpeed;
  final double drift;
  final double phase;
  final double opacity;
}

class EndlessBahbohScreen extends StatefulWidget {
  const EndlessBahbohScreen({super.key});

  @override
  State<EndlessBahbohScreen> createState() => _EndlessBahbohScreenState();
}

class _EndlessBahbohScreenState extends State<EndlessBahbohScreen>
    with SingleTickerProviderStateMixin {
  static const double _topDangerLine = 0.0;
  static const double _bottomPadding = 32.0;
  static const double _sidePadding = 16.0;

  final math.Random _random = math.Random();
  final List<BubbleEntity> _bubbles = <BubbleEntity>[];
  final List<ResidueCloud> _residue = <ResidueCloud>[];
  final List<AtmosBubble> _atmosphere = <AtmosBubble>[];

  late final Ticker _ticker;

  Duration _lastTick = Duration.zero;
  Size _boardSize = Size.zero;

  int _idSeed = 0;
  double _spawnAccumulator = 0.0;
  int _score = 0;
  int _bestScore = 0;
  int _phase = 1;
  int _combo = 0;
  int _explosionsInPhase = 0;
  bool _gameOver = false;
  double _levelBannerTime = 0.0;

  int? _draggedBubbleId;
  Offset? _dragPointer;

  late final List<BubbleRecipe> _recipePool = <BubbleRecipe>[
    const BubbleRecipe(
      id: 'roy',
      colors: {BubbleTone.red, BubbleTone.orange, BubbleTone.yellow},
      minCount: 3,
    ),
    const BubbleRecipe(
      id: 'gbi',
      colors: {BubbleTone.green, BubbleTone.blue, BubbleTone.indigo},
      minCount: 3,
    ),
    const BubbleRecipe(
      id: 'vio',
      colors: {BubbleTone.violet, BubbleTone.indigo, BubbleTone.orange},
      minCount: 3,
    ),
    const BubbleRecipe(
      id: 'rbg',
      colors: {BubbleTone.red, BubbleTone.blue, BubbleTone.green},
      minCount: 3,
    ),
    const BubbleRecipe(
      id: 'yiv',
      colors: {BubbleTone.yellow, BubbleTone.indigo, BubbleTone.violet},
      minCount: 3,
    ),
    const BubbleRecipe(
      id: 'rogb',
      colors: {
        BubbleTone.red,
        BubbleTone.orange,
        BubbleTone.green,
        BubbleTone.blue,
      },
      minCount: 4,
    ),
    const BubbleRecipe(
      id: 'ybv',
      colors: {BubbleTone.yellow, BubbleTone.blue, BubbleTone.violet},
      minCount: 3,
    ),
    const BubbleRecipe(
      id: 'oig',
      colors: {BubbleTone.orange, BubbleTone.indigo, BubbleTone.green},
      minCount: 3,
    ),
    const BubbleRecipe(
      id: 'royg',
      colors: {
        BubbleTone.red,
        BubbleTone.orange,
        BubbleTone.yellow,
        BubbleTone.green,
      },
      minCount: 4,
    ),
    const BubbleRecipe(
      id: 'gbiv',
      colors: {
        BubbleTone.green,
        BubbleTone.blue,
        BubbleTone.indigo,
        BubbleTone.violet,
      },
      minCount: 4,
    ),
    const BubbleRecipe(
      id: 'rvy',
      colors: {BubbleTone.red, BubbleTone.violet, BubbleTone.yellow},
      minCount: 3,
    ),
    const BubbleRecipe(
      id: 'obg',
      colors: {BubbleTone.orange, BubbleTone.blue, BubbleTone.green},
      minCount: 3,
    ),
  ];

  List<BubbleRecipe> _activeRecipes = <BubbleRecipe>[];

  static const Map<BubbleTone, BubbleVisual> _visuals =
      <BubbleTone, BubbleVisual>{
        BubbleTone.red: BubbleVisual(
          core: Color(0xFFFF487F),
          glow: Color(0xFFFF2B67),
          rim: Color(0xFFFFBED3),
          reflection: Color(0xFFFF9FC2),
          highlight: Color(0xFFFCEBFF),
        ),
        BubbleTone.orange: BubbleVisual(
          core: Color(0xFFFFA43B),
          glow: Color(0xFFFF7B00),
          rim: Color(0xFFFFD7AA),
          reflection: Color(0xFFFFC178),
          highlight: Color(0xFFFFF0DA),
        ),
        BubbleTone.yellow: BubbleVisual(
          core: Color(0xFFF8FF5D),
          glow: Color(0xFFE7FF00),
          rim: Color(0xFFFFFFCE),
          reflection: Color(0xFFF8FF99),
          highlight: Color(0xFFFFFFFF),
        ),
        BubbleTone.green: BubbleVisual(
          core: Color(0xFF52FF9B),
          glow: Color(0xFF00FF7B),
          rim: Color(0xFFC9FFE1),
          reflection: Color(0xFF8EFFC0),
          highlight: Color(0xFFF0FFF9),
        ),
        BubbleTone.blue: BubbleVisual(
          core: Color(0xFF55D9FF),
          glow: Color(0xFF00C8FF),
          rim: Color(0xFFC4F3FF),
          reflection: Color(0xFF9AE7FF),
          highlight: Color(0xFFF1FCFF),
        ),
        BubbleTone.indigo: BubbleVisual(
          core: Color(0xFF7A7BFF),
          glow: Color(0xFF5661FF),
          rim: Color(0xFFD3D4FF),
          reflection: Color(0xFFB1B6FF),
          highlight: Color(0xFFF3F4FF),
        ),
        BubbleTone.violet: BubbleVisual(
          core: Color(0xFFE467FF),
          glow: Color(0xFFC93CFF),
          rim: Color(0xFFF2C3FF),
          reflection: Color(0xFFE8A8FF),
          highlight: Color(0xFFFEF0FF),
        ),
      };

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _rollRecipes();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }

    final double dt =
        (elapsed - _lastTick).inMicroseconds.clamp(0, 50000) / 1000000.0;
    _lastTick = elapsed;

    if (_boardSize == Size.zero) return;

    _updateAtmosphere(dt);
    if (_levelBannerTime > 0) {
      _levelBannerTime = math.max(0.0, _levelBannerTime - dt);
    }

    if (!_gameOver) {
      _spawnAccumulator += dt;
      final double interval = _spawnIntervalSeconds();
      while (_spawnAccumulator >= interval) {
        _spawnAccumulator -= interval;
        _spawnBubble();
      }

      _updateBubbles(dt);
      _resolveBubbleCollisions();
      _refreshSupportState();
      _checkForExplosions();
      _checkForOverflowLoss();
    }

    _updateResidue(dt);
    setState(() {});
  }

  double _spawnIntervalSeconds() {
    final double phasePressure = ((_phase - 1) * 0.05);
    return math.max(0.32, 0.95 - phasePressure);
  }

  double _gravityPixelsPerSecondSq() {
    return 180.0 + ((_phase - 1) * 14.0);
  }

  double _terminalVelocity() {
    return 215.0 + ((_phase - 1) * 18.0);
  }

  double _dragFriction(double dt) {
    return math.pow(0.985, dt * 60.0).toDouble();
  }

  double _sizeRadius(BubbleSizeKind size) {
    switch (size) {
      case BubbleSizeKind.small:
        return 22.0;
      case BubbleSizeKind.medium:
        return 30.8; // 1.4x small
      case BubbleSizeKind.large:
        return 41.8; // 1.9x small
    }
  }

  BubbleSizeKind _pickSize() {
    final double roll = _random.nextDouble();
    if (roll < 0.50) return BubbleSizeKind.small;
    if (roll < 0.82) return BubbleSizeKind.medium;
    return BubbleSizeKind.large;
  }

  BubbleTone _pickTone() {
    final List<BubbleTone> tones = BubbleTone.values;
    return tones[_random.nextInt(tones.length)];
  }

  void _spawnBubble() {
    if (_boardSize == Size.zero) return;

    final BubbleSizeKind size = _pickSize();
    final double radius = _sizeRadius(size);
    final double x =
        _random.nextDouble() *
            (_boardSize.width - (_sidePadding * 2) - (radius * 2)) +
        _sidePadding +
        radius;
    final double drift = (_random.nextDouble() - 0.5) * 16.0;

    _bubbles.add(
      BubbleEntity(
        id: ++_idSeed,
        tone: _pickTone(),
        size: size,
        position: Offset(x, -radius * 2.2),
        velocity: Offset(drift, 10.0 + _random.nextDouble() * 12.0),
      ),
    );
  }

  void _updateAtmosphere(double dt) {
    if (_atmosphere.isEmpty) {
      _seedAtmosphere();
    }

    for (final AtmosBubble bubble in _atmosphere) {
      final double wave = math.sin(
        (_lastTick.inMilliseconds / 1000.0) + bubble.phase,
      );
      bubble.position = Offset(
        bubble.position.dx + (bubble.drift * wave * dt),
        bubble.position.dy - (bubble.riseSpeed * dt),
      );

      if (bubble.position.dy + bubble.radius < 0) {
        bubble.position = Offset(
          _random.nextDouble() * _boardSize.width,
          _boardSize.height + bubble.radius + _random.nextDouble() * 80.0,
        );
      }
    }
  }

  void _seedAtmosphere() {
    _atmosphere.clear();
    for (int i = 0; i < 90; i++) {
      final BubbleTone tone = _pickTone();
      final BubbleVisual visual = _visuals[tone]!;
      _atmosphere.add(
        AtmosBubble(
          position: Offset(
            _random.nextDouble() * _boardSize.width,
            _random.nextDouble() * _boardSize.height,
          ),
          radius: 3.0 + _random.nextDouble() * 14.0,
          color: visual.glow,
          riseSpeed: 3.0 + _random.nextDouble() * 12.0,
          drift: (_random.nextDouble() - 0.5) * 12.0,
          phase: _random.nextDouble() * math.pi * 2,
          opacity: 0.05 + _random.nextDouble() * 0.14,
        ),
      );
    }
  }

  void _updateBubbles(double dt) {
    final double gravity = _gravityPixelsPerSecondSq();
    final double terminal = _terminalVelocity();
    final double friction = _dragFriction(dt);

    for (final BubbleEntity bubble in _bubbles) {
      final double radius = _sizeRadius(bubble.size);
      final bool isDragged =
          bubble.id == _draggedBubbleId &&
          _dragPointer != null &&
          !bubble.settled;

      if (isDragged) {
        final double targetX = _dragPointer!.dx.clamp(
          _sidePadding + radius,
          _boardSize.width - _sidePadding - radius,
        );
        final double nextX =
            lerpDouble(bubble.position.dx, targetX, 0.26) ?? targetX;
        final double vx = (nextX - bubble.position.dx) / math.max(dt, 0.016);
        bubble.position = Offset(nextX, bubble.position.dy);
        bubble.velocity = Offset(vx, bubble.velocity.dy);
      }

      if (!bubble.settled) {
        final double driftWave = math.sin(
          (_lastTick.inMilliseconds / 650.0) + bubble.id * 0.37,
        );
        final double driftStrength = 7.0 + ((_phase - 1) * 0.5);
        bubble.velocity = Offset(
          (bubble.velocity.dx + (driftWave * driftStrength * dt)) * friction,
          math.min(
            terminal,
            (bubble.velocity.dy + gravity * dt) *
                math.pow(0.997, dt * 60).toDouble(),
          ),
        );
      } else {
        bubble.velocity = Offset(bubble.velocity.dx * 0.84, 0.0);
      }

      bubble.position += bubble.velocity * dt;

      final double minX = _sidePadding + radius;
      final double maxX = _boardSize.width - _sidePadding - radius;
      if (bubble.position.dx < minX) {
        bubble.position = Offset(minX, bubble.position.dy);
        bubble.velocity = Offset(
          bubble.velocity.dx.abs() * 0.18,
          bubble.velocity.dy,
        );
      } else if (bubble.position.dx > maxX) {
        bubble.position = Offset(maxX, bubble.position.dy);
        bubble.velocity = Offset(
          -bubble.velocity.dx.abs() * 0.18,
          bubble.velocity.dy,
        );
      }

      final double floorY = _boardSize.height - _bottomPadding - radius;
      if (bubble.position.dy >= floorY) {
        bubble.position = Offset(bubble.position.dx, floorY);
        bubble.velocity = Offset(bubble.velocity.dx * 0.15, 0.0);
        bubble.settled = true;
        bubble.wobble = math.max(bubble.wobble, 0.65);
      }

      bubble.wobble *= math.pow(0.93, dt * 60.0).toDouble();
    }
  }

  void _resolveBubbleCollisions() {
    for (int i = 0; i < _bubbles.length; i++) {
      final BubbleEntity a = _bubbles[i];
      final double ra = _sizeRadius(a.size);

      for (int j = i + 1; j < _bubbles.length; j++) {
        final BubbleEntity b = _bubbles[j];
        final double rb = _sizeRadius(b.size);

        final Offset delta = b.position - a.position;
        final double distance = delta.distance;
        final double minDistance = ra + rb;

        if (distance <= 0.0001 || distance >= minDistance) continue;

        final Offset normal = delta / distance;
        final double overlap = minDistance - distance;

        final bool aDragged = a.id == _draggedBubbleId;
        final bool bDragged = b.id == _draggedBubbleId;

        double aMove = 0.5;
        double bMove = 0.5;

        if (aDragged && !bDragged) {
          aMove = 0.05;
          bMove = 0.95;
        } else if (!aDragged && bDragged) {
          aMove = 0.95;
          bMove = 0.05;
        }

        a.position -= normal * overlap * aMove;
        b.position += normal * overlap * bMove;

        final BubbleEntity upper = a.position.dy < b.position.dy ? a : b;
        final BubbleEntity lower = identical(upper, a) ? b : a;

        if (lower.settled || lower.position.dy > upper.position.dy) {
          if (upper.velocity.dy >= 0) {
            upper.settled = true;
            upper.velocity = Offset(upper.velocity.dx * 0.12, 0.0);
            upper.wobble = math.max(upper.wobble, 0.45);
          }
        }
      }
    }
  }

  void _refreshSupportState() {
    for (final BubbleEntity bubble in _bubbles) {
      if (bubble.id == _draggedBubbleId) continue;

      final bool supported = _isSupported(bubble);
      if (!supported &&
          bubble.position.dy <
              _boardSize.height -
                  _bottomPadding -
                  _sizeRadius(bubble.size) -
                  1) {
        bubble.settled = false;
      } else if (supported && bubble.velocity.dy.abs() < 55.0) {
        bubble.settled = true;
        bubble.velocity = Offset(bubble.velocity.dx * 0.12, 0.0);
      }
    }
  }

  bool _isSupported(BubbleEntity bubble) {
    final double r = _sizeRadius(bubble.size);
    final double floorY = _boardSize.height - _bottomPadding - r;
    if ((bubble.position.dy - floorY).abs() < 1.5 ||
        bubble.position.dy >= floorY) {
      return true;
    }

    for (final BubbleEntity other in _bubbles) {
      if (identical(other, bubble)) continue;

      final double or = _sizeRadius(other.size);
      final double distance = (other.position - bubble.position).distance;
      final bool touching = distance <= (r + or + 3.5);
      final bool lowerEnough = other.position.dy > bubble.position.dy + 4.0;

      if (touching && lowerEnough) {
        return true;
      }
    }

    return false;
  }

  void _checkForExplosions() {
    if (_bubbles.length < 3) return;

    final Map<int, List<int>> adjacency = <int, List<int>>{};
    for (int i = 0; i < _bubbles.length; i++) {
      adjacency[i] = <int>[];
    }

    for (int i = 0; i < _bubbles.length; i++) {
      final BubbleEntity a = _bubbles[i];
      final double ra = _sizeRadius(a.size);

      for (int j = i + 1; j < _bubbles.length; j++) {
        final BubbleEntity b = _bubbles[j];
        final double rb = _sizeRadius(b.size);

        final double distance = (a.position - b.position).distance;
        if (distance <= (ra + rb + 4.0)) {
          adjacency[i]!.add(j);
          adjacency[j]!.add(i);
        }
      }
    }

    final Set<int> visited = <int>{};
    final List<List<int>> components = <List<int>>[];

    for (int i = 0; i < _bubbles.length; i++) {
      if (visited.contains(i)) continue;

      final List<int> stack = <int>[i];
      final List<int> component = <int>[];
      visited.add(i);

      while (stack.isNotEmpty) {
        final int current = stack.removeLast();
        component.add(current);

        for (final int neighbor in adjacency[current]!) {
          if (!visited.contains(neighbor)) {
            visited.add(neighbor);
            stack.add(neighbor);
          }
        }
      }

      if (component.length >= 3) {
        components.add(component);
      }
    }

    if (components.isEmpty) {
      _combo = 0;
      return;
    }

    final List<int> toRemove = <int>[];
    int explosionCount = 0;

    for (final List<int> component in components) {
      final Set<BubbleTone> tones = component
          .map((int index) => _bubbles[index].tone)
          .toSet();

      BubbleRecipe? matchedRecipe;
      for (final BubbleRecipe recipe in _activeRecipes) {
        if (tones.containsAll(recipe.colors) &&
            component.length >= recipe.minCount) {
          if (matchedRecipe == null ||
              recipe.colors.length > matchedRecipe.colors.length) {
            matchedRecipe = recipe;
          }
        }
      }

      if (matchedRecipe == null) continue;

      for (final int index in component) {
        toRemove.add(index);
      }

      final int componentScore =
          (component.length * 120) +
          (matchedRecipe.colors.length * 180) +
          (_combo * 35);
      _score += componentScore;
      if (_score > _bestScore) {
        _bestScore = _score;
      }

      for (final int index in component) {
        final BubbleEntity bubble = _bubbles[index];
        final BubbleVisual visual = _visuals[bubble.tone]!;
        _residue.add(
          ResidueCloud(
            position: bubble.position,
            color: visual.glow,
            baseRadius: _sizeRadius(bubble.size),
            maxLife: 0.95 + _random.nextDouble() * 0.45,
          ),
        );
      }

      _combo += 1;
      explosionCount += 1;
      _explosionsInPhase += 1;
    }

    if (toRemove.isNotEmpty) {
      final Set<int> removeSet = toRemove.toSet();
      final List<BubbleEntity> survivors = <BubbleEntity>[];
      for (int i = 0; i < _bubbles.length; i++) {
        if (!removeSet.contains(i)) {
          survivors.add(_bubbles[i]);
        }
      }
      _bubbles
        ..clear()
        ..addAll(survivors);
    }

    if (explosionCount == 0) {
      _combo = 0;
    }

    if (_explosionsInPhase >= 5) {
      _explosionsInPhase = 0;
      _phase += 1;
      _levelBannerTime = 1.8;
      _rollRecipes();
    }
  }

  void _rollRecipes() {
    final List<BubbleRecipe> shuffled = List<BubbleRecipe>.of(_recipePool)
      ..shuffle(_random);
    _activeRecipes = shuffled.take(4).toList(growable: false);
  }

  void _updateResidue(double dt) {
    for (final ResidueCloud cloud in _residue) {
      cloud.life -= dt;
    }
    _residue.removeWhere((ResidueCloud cloud) => cloud.life <= 0);
  }

  void _checkForOverflowLoss() {
    for (final BubbleEntity bubble in _bubbles) {
      final double r = _sizeRadius(bubble.size);
      final double bubbleTop = bubble.position.dy - r;
      final bool bubbleHasEnteredBoard = bubble.position.dy >= r;
      if (bubbleHasEnteredBoard && bubbleTop <= _topDangerLine) {
        _gameOver = true;
        _draggedBubbleId = null;
        _dragPointer = null;
        return;
      }
    }
  }

  void _restartGame() {
    _bubbles.clear();
    _residue.clear();
    _score = 0;
    _phase = 1;
    _combo = 0;
    _explosionsInPhase = 0;
    _spawnAccumulator = 0.0;
    _draggedBubbleId = null;
    _dragPointer = null;
    _gameOver = false;
    _rollRecipes();
  }

  void _handlePanStart(Offset localPosition) {
    if (_gameOver) {
      _restartGame();
      return;
    }

    BubbleEntity? selected;
    double bestDistance = double.infinity;

    for (final BubbleEntity bubble in _bubbles) {
      if (bubble.settled) continue;

      final double r = _sizeRadius(bubble.size);
      final double d = (bubble.position - localPosition).distance;
      if (d <= r * 1.25 && d < bestDistance) {
        selected = bubble;
        bestDistance = d;
      }
    }

    _draggedBubbleId = selected?.id;
    _dragPointer = localPosition;
  }

  void _handlePanUpdate(Offset localPosition) {
    _dragPointer = localPosition;
  }

  void _handlePanEnd() {
    _draggedBubbleId = null;
    _dragPointer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Size nextSize = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          if (nextSize != _boardSize) {
            _boardSize = nextSize;
            if (_atmosphere.isEmpty) {
              _seedAtmosphere();
            }
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (DragDownDetails details) {
              _handlePanStart(details.localPosition);
            },
            onPanUpdate: (DragUpdateDetails details) {
              _handlePanUpdate(details.localPosition);
            },
            onPanEnd: (_) => _handlePanEnd(),
            onPanCancel: _handlePanEnd,
            onTapDown: (TapDownDetails details) {
              if (_gameOver) {
                _restartGame();
              }
            },
            child: CustomPaint(
              painter: BahbohPainter(
                bubbles: _bubbles,
                residue: _residue,
                atmosphere: _atmosphere,
                score: _score,
                bestScore: _bestScore,
                phase: _phase,
                combo: _combo,
                gameOver: _gameOver,
                levelBannerTime: _levelBannerTime,
                sizeResolver: _sizeRadius,
                visuals: _visuals,
              ),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );
  }
}

class BahbohSplashScreen extends StatelessWidget {
  const BahbohSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.08, -0.32),
            radius: 1.1,
            colors: <Color>[
              Color(0xFF16061F),
              Color(0xFF080B13),
              Color(0xFF020307),
            ],
            stops: <double>[0.0, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool compact = constraints.maxWidth < 860;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'BAHBOH',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.94),
                        fontSize: compact ? 30 : 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'A glowing bubble puzzle where hidden sets explode and the board turns into a canvas of light.',
                      style: TextStyle(
                        color: const Color(0xFFD9EEFF).withValues(alpha: 0.82),
                        fontSize: compact ? 15 : 18,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Expanded(
                      child: Flex(
                        direction: compact ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: compact ? 0 : 6,
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: compact ? constraints.maxWidth : 640,
                                  maxHeight: compact ? 420 : 640,
                                ),
                                child: _EnterableSplashArt(
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const EndlessBahbohScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: compact ? 0 : 44, height: compact ? 28 : 0),
                          Expanded(
                            flex: compact ? 0 : 4,
                            child: Align(
                              alignment: compact
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 420),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _SplashLine(
                                      label: 'DISCOVER',
                                      text:
                                          'the hidden OK sets before the board fills.',
                                    ),
                                    const SizedBox(height: 18),
                                    _SplashLine(
                                      label: 'MOVE',
                                      text:
                                          'the falling bubble before it locks into place.',
                                    ),
                                    const SizedBox(height: 18),
                                    _SplashLine(
                                      label: 'SURVIVE',
                                      text:
                                          'the Not OK bubbles by letting danger colors annihilate cleanly.',
                                    ),
                                    const SizedBox(height: 18),
                                    _SplashLine(
                                      label: 'PLAY',
                                      text:
                                          'with quick drags, soft drops, and sharp timing.',
                                    ),
                                    const SizedBox(height: 30),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                const EndlessBahbohScreen(),
                                          ),
                                        );
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF61B4),
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 18,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      child: const Text('ENTER BAHBOH'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EnterableSplashArt extends StatelessWidget {
  const _EnterableSplashArt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Enter Bahboh',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox.expand(
            child: Center(
              child: Image.asset(
                'assets/branding/baboh.gif',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashLine extends StatelessWidget {
  const _SplashLine({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 98,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFF83CC),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 18,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class BahbohPainter extends CustomPainter {
  const BahbohPainter({
    required this.bubbles,
    required this.residue,
    required this.atmosphere,
    required this.score,
    required this.bestScore,
    required this.phase,
    required this.combo,
    required this.gameOver,
    required this.levelBannerTime,
    required this.sizeResolver,
    required this.visuals,
  });

  final List<BubbleEntity> bubbles;
  final List<ResidueCloud> residue;
  final List<AtmosBubble> atmosphere;
  final int score;
  final int bestScore;
  final int phase;
  final int combo;
  final bool gameOver;
  final double levelBannerTime;
  final double Function(BubbleSizeKind size) sizeResolver;
  final Map<BubbleTone, BubbleVisual> visuals;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBoard(canvas, size);
    _paintAtmosphere(canvas);
    _paintResidue(canvas);
    _paintGameplayBubbles(canvas);
    _paintHud(canvas, size);
    if (levelBannerTime > 0) {
      _paintLevelBanner(canvas, size);
    }
    if (gameOver) {
      _paintGameOver(canvas, size);
    }
  }

  void _paintBoard(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Paint bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFF03050C),
          Color(0xFF07111D),
          Color(0xFF090818),
          Color(0xFF02030A),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    final List<Offset> fogCenters = <Offset>[
      Offset(size.width * 0.18, size.height * 0.22),
      Offset(size.width * 0.75, size.height * 0.30),
      Offset(size.width * 0.35, size.height * 0.75),
      Offset(size.width * 0.85, size.height * 0.80),
    ];

    final List<Color> fogColors = <Color>[
      const Color(0xFF00D9FF).withValues(alpha: 0.07),
      const Color(0xFFE03DFF).withValues(alpha: 0.08),
      const Color(0xFF48FF9B).withValues(alpha: 0.07),
      const Color(0xFFFFB200).withValues(alpha: 0.06),
    ];

    for (int i = 0; i < fogCenters.length; i++) {
      final Paint fog = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60)
        ..color = fogColors[i];
      canvas.drawCircle(fogCenters[i], size.shortestSide * 0.18, fog);
    }

    final Paint vignette = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0),
        radius: 1.08,
        colors: <Color>[
          Colors.transparent,
          Colors.black.withValues(alpha: 0.20),
          Colors.black.withValues(alpha: 0.45),
        ],
        stops: const <double>[0.50, 0.82, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  void _paintAtmosphere(Canvas canvas) {
    for (final AtmosBubble bubble in atmosphere) {
      final Paint glow = Paint()
        ..color = bubble.color.withValues(alpha: bubble.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(bubble.position, bubble.radius * 1.65, glow);

      final Paint shell = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, bubble.radius * 0.06)
        ..color = Colors.white.withValues(alpha: bubble.opacity * 0.45);
      canvas.drawCircle(bubble.position, bubble.radius, shell);
    }
  }

  void _paintResidue(Canvas canvas) {
    for (final ResidueCloud cloud in residue) {
      final double t = (cloud.life / cloud.maxLife).clamp(0.0, 1.0);
      final double radius = cloud.baseRadius * (1.0 + (1.55 * (1 - t)));

      final Paint fog = Paint()
        ..color = cloud.color.withValues(alpha: 0.16 * t)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
      canvas.drawCircle(cloud.position, radius * 1.2, fog);

      final Paint ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.4, cloud.baseRadius * 0.10)
        ..color = Colors.white.withValues(alpha: 0.20 * t)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(cloud.position, radius, ring);

      final Paint core = Paint()
        ..color = cloud.color.withValues(alpha: 0.10 * t)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(cloud.position, radius * 0.72, core);
    }
  }

  void _paintGameplayBubbles(Canvas canvas) {
    final List<BubbleEntity> ordered = List<BubbleEntity>.of(bubbles)
      ..sort((BubbleEntity a, BubbleEntity b) {
        final double ar = sizeResolver(a.size);
        final double br = sizeResolver(b.size);
        return ar.compareTo(br);
      });

    for (final BubbleEntity bubble in ordered) {
      _paintOneBubble(canvas, bubble);
    }
  }

  void _paintOneBubble(Canvas canvas, BubbleEntity bubble) {
    final BubbleVisual visual = visuals[bubble.tone]!;
    final double r = sizeResolver(bubble.size);
    final Offset center = bubble.position;
    final double wobbleScale = 1.0 + (bubble.wobble * 0.05);
    final double wobbleY = 1.0 - (bubble.wobble * 0.03);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(wobbleScale, wobbleY);
    canvas.translate(-center.dx, -center.dy);

    final Paint farGlow = Paint()
      ..color = visual.glow.withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, r * 1.95, farGlow);

    final Paint nearGlow = Paint()
      ..color = visual.glow.withValues(alpha: 0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(center, r * 1.35, nearGlow);

    final Rect bodyRect = Rect.fromCircle(center: center, radius: r * 0.96);
    final Paint body = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.32),
        radius: 1.15,
        colors: <Color>[
          Colors.white.withValues(alpha: 0.05),
          visual.core.withValues(alpha: 0.08),
          visual.core.withValues(alpha: 0.14),
          visual.core.withValues(alpha: 0.24),
        ],
        stops: const <double>[0.0, 0.30, 0.72, 1.0],
      ).createShader(bodyRect);
    canvas.drawCircle(center, r * 0.96, body);

    final Paint innerSheen = Paint()
      ..shader =
          RadialGradient(
            center: const Alignment(-0.36, -0.46),
            radius: 0.62,
            colors: <Color>[
              visual.reflection.withValues(alpha: 0.20),
              visual.reflection.withValues(alpha: 0.07),
              Colors.transparent,
            ],
            stops: const <double>[0.0, 0.55, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: center + Offset(-r * 0.14, -r * 0.16),
              radius: r,
            ),
          );
    canvas.drawCircle(
      center + Offset(-r * 0.04, -r * 0.04),
      r * 0.82,
      innerSheen,
    );

    final Paint rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, r * 0.08)
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: (math.pi * 1.5),
        colors: <Color>[
          visual.rim.withValues(alpha: 0.92),
          visual.rim.withValues(alpha: 0.48),
          visual.rim.withValues(alpha: 0.22),
          visual.rim.withValues(alpha: 0.72),
          visual.rim.withValues(alpha: 0.92),
        ],
        stops: const <double>[0.0, 0.28, 0.55, 0.82, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, rim);

    final Paint primaryHighlight = Paint()
      ..color = visual.highlight.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-r * 0.28, -r * 0.30),
        width: r * 0.56,
        height: r * 0.33,
      ),
      primaryHighlight,
    );

    final Paint secondaryHighlight = Paint()
      ..color = visual.highlight.withValues(alpha: 0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-r * 0.05, -r * 0.10),
        width: r * 0.18,
        height: r * 0.12,
      ),
      secondaryHighlight,
    );

    final Paint reflectionArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, r * 0.05)
      ..color = visual.reflection.withValues(alpha: 0.22)
      ..strokeCap = StrokeCap.round;
    final Rect arcRect = Rect.fromCenter(
      center: center + Offset(r * 0.02, -r * 0.03),
      width: r * 1.14,
      height: r * 0.88,
    );
    canvas.drawArc(arcRect, -2.45, 1.1, false, reflectionArc);

    if (bubble.size != BubbleSizeKind.small) {
      final Paint motePaint = Paint()
        ..color = visual.highlight.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(
        center + Offset(r * 0.16, -r * 0.18),
        r * 0.045,
        motePaint,
      );
      canvas.drawCircle(
        center + Offset(-r * 0.20, r * 0.06),
        r * 0.038,
        motePaint,
      );
      if (bubble.size == BubbleSizeKind.large) {
        canvas.drawCircle(
          center + Offset(r * 0.28, r * 0.14),
          r * 0.035,
          motePaint,
        );
      }
    }

    canvas.restore();
  }

  void _paintHud(Canvas canvas, Size size) {
    final RRect chip = RRect.fromRectAndRadius(
      const Rect.fromLTWH(16, 16, 260, 96),
      const Radius.circular(24),
    );

    final Paint chipBg = Paint()
      ..color = const Color(0xFF091320).withValues(alpha: 0.72);
    canvas.drawRRect(chip, chipBg);

    final Paint chipStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawRRect(chip, chipStroke);

    final TextPainter scoreLabel = TextPainter(
      text: TextSpan(
        text: 'SCORE',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.72),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    scoreLabel.paint(canvas, const Offset(30, 28));

    final TextPainter scoreValue = TextPainter(
      text: TextSpan(
        text: '$score',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    scoreValue.paint(canvas, const Offset(28, 40));

    final TextPainter meta = TextPainter(
      text: TextSpan(
        text: 'BEST $bestScore   •   LEVEL $phase   •   CHAIN $combo',
        style: TextStyle(
          color: const Color(0xFFB6DFFF).withValues(alpha: 0.86),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 220);
    meta.paint(canvas, const Offset(30, 80));

    final TextPainter brand = TextPainter(
      text: const TextSpan(
        text: 'BAHBOH',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    brand.paint(canvas, Offset(size.width - brand.width - 20, 22));

    final TextPainter hint = TextPainter(
      text: TextSpan(
        text: gameOver
            ? 'tap anywhere to restart'
            : 'drag falling bubbles • discover hidden sets • keep the field alive',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.62),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 40);
    hint.paint(canvas, Offset(size.width - hint.width - 20, 48));
  }

  void _paintGameOver(Canvas canvas, Size size) {
    final Rect overlay = Offset.zero & size;
    final Paint dim = Paint()..color = Colors.black.withValues(alpha: 0.42);
    canvas.drawRect(overlay, dim);

    final RRect card = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: math.min(420, size.width - 36),
        height: 200,
      ),
      const Radius.circular(30),
    );

    final Paint cardPaint = Paint()
      ..color = const Color(0xFF0A1322).withValues(alpha: 0.90);
    canvas.drawRRect(card, cardPaint);

    final Paint cardStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.09);
    canvas.drawRRect(card, cardStroke);

    final TextPainter over = TextPainter(
      text: const TextSpan(
        text: 'GAME OVER',
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: card.outerRect.width - 40);

    over.paint(
      canvas,
      Offset(
        card.outerRect.center.dx - over.width / 2,
        card.outerRect.top + 38,
      ),
    );

    final TextPainter stats = TextPainter(
      text: TextSpan(
        text: 'score $score   •   best $bestScore   •   reached level $phase',
        style: TextStyle(
          color: const Color(0xFFBEE6FF).withValues(alpha: 0.86),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: card.outerRect.width - 40);

    stats.paint(
      canvas,
      Offset(
        card.outerRect.center.dx - stats.width / 2,
        card.outerRect.top + 94,
      ),
    );

    final TextPainter tap = TextPainter(
      text: TextSpan(
        text: 'tap anywhere to bloom again',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.72),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: card.outerRect.width - 40);

    tap.paint(
      canvas,
      Offset(
        card.outerRect.center.dx - tap.width / 2,
        card.outerRect.top + 142,
      ),
    );
  }

  void _paintLevelBanner(Canvas canvas, Size size) {
    final double t = levelBannerTime.clamp(0.0, 1.8);
    final double normalized = t / 1.8;
    final double opacity = Curves.easeOut.transform(
      normalized < 0.5 ? 1.0 : (normalized * 2).clamp(0.0, 1.0),
    );

    final Paint glow = Paint()
      ..color = const Color(0xFF63E6FF).withValues(alpha: 0.18 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

    final Offset center = Offset(size.width / 2, size.height * 0.18);
    canvas.drawCircle(center, 120, glow);

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: 'LEVEL $phase',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.95 * opacity),
          fontSize: 42,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant BahbohPainter oldDelegate) => true;
}
