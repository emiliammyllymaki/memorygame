import 'package:flutter/material.dart';
import '../services/responsive.dart';
import 'level_select_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _bounceAnim,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _bounceAnim.value),
                      child: child,
                    ),
                    child: Text(
                      '🐱',
                      style: TextStyle(fontSize: tablet ? 110 : 90),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Kitty Memory',
                    style: TextStyle(
                      fontSize: tablet ? 52 : 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Find all the kitty themed pairs! 🐾',
                    style: TextStyle(
                      fontSize: tablet ? 20 : 16,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 56),
                  SizedBox(
                    width: tablet ? 300 : double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const LevelSelectScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffff6b9d),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Play! 🐱',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
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
