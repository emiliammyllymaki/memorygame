import 'package:flutter/material.dart';
import '../services/responsive.dart';
import '../screens/level_select_screen.dart';
import 'start_screen.dart';
import 'game_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    required this.levelConfig,
    required this.moves,
    required this.timeSeconds,
    super.key,
  });

  final LevelConfig levelConfig;
  final int moves;
  final int timeSeconds;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleIn = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _timeString {
    final m = widget.timeSeconds ~/ 60;
    final s = widget.timeSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _rating {
    if (widget.moves <= widget.levelConfig.pairs + 2) return '🐱🐱🐱';
    if (widget.moves <= widget.levelConfig.pairs * 2) return '🐱🐱';
    return '🐱';
  }

  String get _ratingText {
    if (widget.moves <= widget.levelConfig.pairs + 2) return 'Purrfect!';
    if (widget.moves <= widget.levelConfig.pairs * 2) return 'Good kitty!';
    return 'Keep practicing!';
  }

  LevelConfig? get _nextLevel {
    final currentIndex =
        levels.indexWhere((l) => l.level == widget.levelConfig.level);
    if (currentIndex >= 0 && currentIndex < levels.length - 1) {
      return levels[currentIndex + 1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet(context);
    final config = widget.levelConfig;
    final nextLevel = _nextLevel;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff2d1b3d),
              Color(0xff3d1a4a),
              Color(0xff1a1a3e),
            ],
          ),
        ),
        child: maxWidthBox(
          child: Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: ScaleTransition(
                scale: _scaleIn,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🎉',
                        style: TextStyle(fontSize: tablet ? 80 : 64),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Level Complete!',
                        style: TextStyle(
                          fontSize: tablet ? 38 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _rating,
                        style: TextStyle(fontSize: tablet ? 44 : 36),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _ratingText,
                        style: TextStyle(
                          fontSize: tablet ? 18 : 15,
                          color: config.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: config.color.withOpacity(0.35)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _Stat(
                              label: 'Moves',
                              value: '${widget.moves}',
                              color: config.color,
                              tablet: tablet,
                            ),
                            Container(width: 1, height: 48, color: Colors.white12),
                            _Stat(
                              label: 'Time',
                              value: _timeString,
                              color: config.color,
                              tablet: tablet,
                            ),
                            Container(width: 1, height: 48, color: Colors.white12),
                            _Stat(
                              label: 'Pairs',
                              value: '${config.pairs}',
                              color: config.color,
                              tablet: tablet,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      if (nextLevel != null) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) =>
                                    GameScreen(levelConfig: nextLevel),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: nextLevel.color,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              'Next Level ${nextLevel.emoji}',
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const LevelSelectScreen()),
                            (route) => route.isFirst,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: config.color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            'Back to Levels 🐾',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const StartScreen()),
                            (_) => false,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white60,
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Main Menu',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    required this.tablet,
  });

  final String label;
  final String value;
  final Color color;
  final bool tablet;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: tablet ? 26 : 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: tablet ? 13 : 12,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
