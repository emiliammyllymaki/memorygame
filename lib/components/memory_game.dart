import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../screens/level_select_screen.dart';
import 'card_component.dart';

class MemoryGame extends FlameGame with TapCallbacks {
  MemoryGame({
    required this.levelConfig,
    required this.onGameComplete,
    required this.onMovesUpdate,
  });

  final LevelConfig levelConfig;
  final void Function(int moves, int timeSeconds) onGameComplete;
  final void Function(int moves) onMovesUpdate;

  static const _kittyEmojis = [
    '🐱', '🐈', '🐾', '🎀', '🐟', '🥛',
    '🧶', '😸', '😹', '😻', '🙀', '😾',
    '🐈‍⬛', '🌙', '🐭', '🦋',
  ];

  final List<CardComponent> _flippedCards = [];
  bool _checking = false;
  int moves = 0;
  int matchedPairs = 0;
  late int _startTime;
  bool _complete = false;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _buildGrid();
  }

  void _buildGrid() {
    final pairs = levelConfig.pairs;
    final selected = (_kittyEmojis.toList()..shuffle()).take(pairs).toList();
    final cards = [...selected, ...selected]..shuffle(Random());

    final cols = _columnsFor(pairs);
    final rows = (cards.length / cols).ceil();

    const padding = 12.0;
    const gap = 8.0;

    final cardW = (size.x - padding * 2 - gap * (cols - 1)) / cols;
    final cardH = (size.y - padding * 2 - gap * (rows - 1)) / rows;
    final cardSize = min(cardW, cardH);

    final totalW = cardSize * cols + gap * (cols - 1);
    final totalH = cardSize * rows + gap * (rows - 1);
    final startX = (size.x - totalW) / 2;
    final startY = (size.y - totalH) / 2;

    for (var i = 0; i < cards.length; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      add(CardComponent(
        emoji: cards[i],
        position: Vector2(
          startX + col * (cardSize + gap),
          startY + row * (cardSize + gap),
        ),
        size: Vector2(cardSize, cardSize),
        onTapped: _onCardTapped,
        accentColor: levelConfig.color,
      ));
    }
  }

  int _columnsFor(int pairs) {
    final total = pairs * 2;
    if (total <= 12) return 4;
    if (total <= 20) return 5;
    return 6;
  }

  void _onCardTapped(CardComponent card) {
    if (_checking) return;
    if (card.isMatched) return;
    if (_flippedCards.contains(card)) return;
    if (_flippedCards.length >= 2) return;

    card.flip();
    _flippedCards.add(card);

    if (_flippedCards.length == 2) {
      moves++;
      onMovesUpdate(moves);
      _checking = true;
      Future.delayed(const Duration(milliseconds: 900), _checkMatch);
    }
  }

  void _checkMatch() {
    if (_flippedCards[0].emoji == _flippedCards[1].emoji) {
      _flippedCards[0].markMatched();
      _flippedCards[1].markMatched();
      matchedPairs++;
      if (matchedPairs == levelConfig.pairs && !_complete) {
        _complete = true;
        final elapsed =
            (DateTime.now().millisecondsSinceEpoch - _startTime) ~/ 1000;
        Future.delayed(
          const Duration(milliseconds: 400),
          () => onGameComplete(moves, elapsed),
        );
      }
    } else {
      _flippedCards[0].flipBack();
      _flippedCards[1].flipBack();
    }
    _flippedCards.clear();
    _checking = false;
  }
}
