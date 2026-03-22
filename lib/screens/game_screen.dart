import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/memory_game.dart';
import '../screens/level_select_screen.dart';
import '../services/progress_service.dart';
import '../services/responsive.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({required this.levelConfig, super.key});

  final LevelConfig levelConfig;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _moves = 0;
  int _seconds = 0;
  late Timer _timer;
  MemoryGame? _game;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _timeString {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _onGameComplete(int moves, int timeSeconds) async {
    _timer.cancel();
    await ProgressService.markLevelCompleted(widget.levelConfig.level);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          levelConfig: widget.levelConfig,
          moves: moves,
          timeSeconds: timeSeconds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet(context);
    final config = widget.levelConfig;

    _game ??= MemoryGame(
      levelConfig: config,
      onGameComplete: _onGameComplete,
      onMovesUpdate: (m) {
        if (mounted) setState(() => _moves = m);
      },
    );

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
        child: SafeArea(
          child: maxWidthBox(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: tablet ? 12 : 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${config.emoji}  ${config.title}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: tablet ? 18 : 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      _StatChip(
                        label: '$_moves moves',
                        color: config.color,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: _timeString,
                        color: config.color,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GameWidget(game: _game!),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
