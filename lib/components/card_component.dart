import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class CardComponent extends PositionComponent with TapCallbacks {
  CardComponent({
    required this.emoji,
    required super.position,
    required super.size,
    required this.onTapped,
    required this.accentColor,
  });

  final String emoji;
  final void Function(CardComponent) onTapped;
  final Color accentColor;

  bool _faceUp = false;
  bool isMatched = false;

  bool _isFlipping = false;
  bool _flipToFaceUp = false;
  double _flipProgress = 0;

  static const _flipDuration = 0.22;

  final Paint _backPaint = Paint();
  final Paint _frontPaint = Paint();
  final Paint _matchedPaint = Paint();
  final Paint _borderPaint = Paint()..style = PaintingStyle.stroke;

  @override
  Future<void> onLoad() async {
    _backPaint.color = const Color(0xff3d1a4a);
    _frontPaint.color = const Color(0xff2d1040);
    _matchedPaint.color = accentColor.withOpacity(0.22);
    _borderPaint
      ..color = accentColor.withOpacity(0.55)
      ..strokeWidth = 2;
  }

  void flip() {
    if (_isFlipping) return;
    _isFlipping = true;
    _flipToFaceUp = true;
    _flipProgress = 0;
  }

  void flipBack() {
    if (!_faceUp) return;
    _isFlipping = true;
    _flipToFaceUp = false;
    _flipProgress = 0;
  }

  void markMatched() {
    isMatched = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_isFlipping) return;
    _flipProgress += dt / _flipDuration;
    if (_flipProgress >= 1.0) {
      _flipProgress = 1.0;
      _isFlipping = false;
      _faceUp = _flipToFaceUp;
    }
  }

  double get _scaleX {
    if (!_isFlipping) return 1.0;
    final angle = _flipToFaceUp
        ? _flipProgress * pi
        : (1 - _flipProgress) * pi;
    final s = cos(angle).abs();
    return s < 0.01 ? 0.01 : s;
  }

  bool get _showFront =>
      _faceUp ||
      (_isFlipping && _flipToFaceUp && _flipProgress > 0.5);

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final rx = min(w, h) * 0.13;
    final rect = Rect.fromLTWH(0, 0, w, h);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(rx));

    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.scale(_scaleX, 1.0);
    canvas.translate(-w / 2, -h / 2);

    if (_showFront) {
      canvas.drawRRect(rRect, isMatched ? _matchedPaint : _frontPaint);
      canvas.drawRRect(rRect, _borderPaint);
      _drawEmoji(canvas, w, h);
      if (isMatched) _drawMatchedGlow(canvas, w, h);
    } else {
      canvas.drawRRect(rRect, _backPaint);
      canvas.drawRRect(rRect, _borderPaint);
      _drawCardBack(canvas, w, h);
    }

    canvas.restore();
  }

  void _drawEmoji(Canvas canvas, double w, double h) {
    final fontSize = min(w, h) * 0.50;
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((w - tp.width) / 2, (h - tp.height) / 2));
  }

  void _drawMatchedGlow(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = accentColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final rx = min(w, h) * 0.13;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(rx)),
      paint,
    );
  }

  void _drawCardBack(Canvas canvas, double w, double h) {
    final pinkPaint = Paint()..color = const Color(0xffff6b9d).withOpacity(0.7);
    final size = min(w, h);

    _drawPaw(canvas, w / 2, h / 2, size * 0.28, pinkPaint);
  }

  void _drawPaw(Canvas canvas, double cx, double cy, double r, Paint paint) {
    canvas.drawCircle(Offset(cx, cy + r * 0.1), r, paint);
    canvas.drawCircle(Offset(cx - r * 0.85, cy - r * 0.5), r * 0.52, paint);
    canvas.drawCircle(Offset(cx - r * 0.35, cy - r * 1.05), r * 0.48, paint);
    canvas.drawCircle(Offset(cx + r * 0.35, cy - r * 1.05), r * 0.48, paint);
    canvas.drawCircle(Offset(cx + r * 0.85, cy - r * 0.5), r * 0.52, paint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_faceUp && !_isFlipping && !isMatched) {
      onTapped(this);
    }
  }
}
