import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../services/responsive.dart';
import 'game_screen.dart';

const levels = [
  LevelConfig(
    level: 1,
    title: 'Kitten',
    pairs: 6,
    emoji: '🐱',
    color: Color(0xffff6b9d),
    description: '6 pairs — easy',
  ),
  LevelConfig(
    level: 2,
    title: 'Cat',
    pairs: 10,
    emoji: '🐈',
    color: Color(0xffb06bff),
    description: '10 pairs — medium',
  ),
  LevelConfig(
    level: 3,
    title: 'Cat Queen',
    pairs: 15,
    emoji: '👑',
    color: Color(0xffff9f43),
    description: '15 pairs — hard',
  ),
];

class LevelConfig {
  final int level;
  final String title;
  final int pairs;
  final String emoji;
  final Color color;
  final String description;

  const LevelConfig({
    required this.level,
    required this.title,
    required this.pairs,
    required this.emoji,
    required this.color,
    required this.description,
  });
}

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  void _startLevel(LevelConfig config) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => GameScreen(levelConfig: config),
        ))
        .then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet(context);
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select Level',
                        style: TextStyle(
                          fontSize: tablet ? 32 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('🐾', style: TextStyle(fontSize: tablet ? 28 : 22)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: Text(
                      'Complete a level to unlock the next one',
                      style: TextStyle(
                        fontSize: tablet ? 15 : 13,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: ListView.separated(
                      itemCount: levels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final config = levels[i];
                        final completed =
                            ProgressService.isLevelCompleted(config.level);
                        final unlocked =
                            ProgressService.isLevelUnlocked(config.level);
                        return _LevelCard(
                          config: config,
                          completed: completed,
                          unlocked: unlocked,
                          tablet: tablet,
                          onTap: unlocked ? () => _startLevel(config) : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        await ProgressService.resetProgress();
                        setState(() {});
                      },
                      child: const Text(
                        'Reset Progress',
                        style: TextStyle(color: Colors.white30, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.config,
    required this.completed,
    required this.unlocked,
    required this.tablet,
    required this.onTap,
  });

  final LevelConfig config;
  final bool completed;
  final bool unlocked;
  final bool tablet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: unlocked ? 1.0 : 0.4,
        child: Container(
          padding: EdgeInsets.all(tablet ? 24 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: completed
                  ? config.color.withOpacity(0.9)
                  : Colors.white.withOpacity(0.1),
              width: completed ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: tablet ? 66 : 58,
                height: tablet ? 66 : 58,
                decoration: BoxDecoration(
                  color: config.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    config.emoji,
                    style: TextStyle(fontSize: tablet ? 32 : 28),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${config.level} — ${config.title}',
                      style: TextStyle(
                        fontSize: tablet ? 19 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      config.description,
                      style: TextStyle(
                        fontSize: tablet ? 14 : 13,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              if (!unlocked)
                const Icon(Icons.lock, color: Colors.white30, size: 24)
              else if (completed)
                Icon(Icons.check_circle, color: config.color, size: 30)
              else
                Icon(Icons.play_circle_fill,
                    color: config.color.withOpacity(0.8), size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
