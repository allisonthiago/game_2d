import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import '../game/my_game.dart';

class PlayerHud extends PositionComponent with HasGameReference<MyGame> {
  late TextComponent healthText;
  late TextComponent levelText;

  PlayerHud() : super(position: Vector2(20, 20));

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Estilo do texto
    final textPaint = TextPaint(
      style: TextStyle(
        color: BasicPalette.white.color,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(
            color: Colors.black,
            offset: Offset(2, 2),
            blurRadius: 3,
          )
        ],
      ),
    );

    healthText = TextComponent(
      text: 'HP: Carregando...',
      textRenderer: textPaint,
      position: Vector2(0, 0),
    );

    levelText = TextComponent(
      text: 'Lvl: Carregando...',
      textRenderer: textPaint,
      position: Vector2(0, 30),
    );

    add(healthText);
    add(levelText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Atualiza os textos frame a frame lendo os status do player
    final stats = game.player.stats;
    healthText.text = 'HP: \${stats.currentHealth} / \${stats.maxHealth}';
    levelText.text = 'Lvl: \${stats.level} (XP: \${stats.currentExp}/\${stats.maxExp})';
  }
}
