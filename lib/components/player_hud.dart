import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/my_game.dart';

class PlayerHud extends PositionComponent with HasGameReference<MyGame> {
  late TextPaint textPaint;

  PlayerHud() : super(position: Vector2(20, 20));

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Estilo do texto da HUD com sombra preta para melhor leitura
    textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11.0,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black,
            offset: Offset(1.5, 1.5),
            blurRadius: 2,
          )
        ],
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final player = game.player;
    final stats = player.stats;

    // Fundo semi-transparente do painel da HUD
    final bgRect = Rect.fromLTWH(0, 0, 220, 95);
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.5);
    final rrect = RRect.fromRectAndRadius(bgRect, const Radius.circular(8));
    canvas.drawRRect(rrect, bgPaint);

    // Borda dourada medieval do painel
    final borderPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, borderPaint);

    // Pinturas para as barras
    final barBgPaint = Paint()..color = Colors.grey[850]!;
    final hpBarPaint = Paint()..color = const Color(0xFFE53935); // Vermelho medieval
    final stBarPaint = Paint()..color = const Color(0xFF43A047); // Verde medieval
    final xpBarPaint = Paint()..color = const Color(0xFF1E88E5); // Azul medieval

    // Posições das barras
    const double startX = 10.0;
    const double barWidth = 200.0;
    const double barHeight = 16.0;

    // 1. Barra de Vida (HP)
    double hpRatio = (stats.maxHealth > 0) ? (player.currentHealth / stats.maxHealth) : 0.0;
    hpRatio = hpRatio.clamp(0.0, 1.0);

    canvas.drawRect(const Rect.fromLTWH(startX, 10, barWidth, barHeight), barBgPaint);
    canvas.drawRect(Rect.fromLTWH(startX, 10, barWidth * hpRatio, barHeight), hpBarPaint);
    
    // Texto de HP sobreposto
    textPaint.render(
      canvas,
      'HP: ${player.currentHealth.round()} / ${stats.maxHealth}',
      Vector2(startX + 6, 11),
    );

    // 2. Barra de Stamina (ST)
    double stRatio = (stats.maxStamina > 0) ? (player.currentStamina / stats.maxStamina) : 0.0;
    stRatio = stRatio.clamp(0.0, 1.0);

    canvas.drawRect(const Rect.fromLTWH(startX, 34, barWidth, barHeight), barBgPaint);
    canvas.drawRect(Rect.fromLTWH(startX, 34, barWidth * stRatio, barHeight), stBarPaint);

    // Texto de Stamina sobreposto
    textPaint.render(
      canvas,
      'ST: ${player.currentStamina.round()} / ${stats.maxStamina}',
      Vector2(startX + 6, 35),
    );

    // 3. Barra de Experiência (XP)
    double xpRatio = (stats.maxExp > 0) ? (stats.currentExp / stats.maxExp) : 0.0;
    xpRatio = xpRatio.clamp(0.0, 1.0);

    const double xpBarHeight = 10.0;
    canvas.drawRect(const Rect.fromLTWH(startX, 58, barWidth, xpBarHeight), barBgPaint);
    canvas.drawRect(Rect.fromLTWH(startX, 58, barWidth * xpRatio, xpBarHeight), xpBarPaint);

    // Texto de XP e Lvl sobreposto
    textPaint.render(
      canvas,
      'Lvl: ${stats.level} | XP: ${stats.currentExp}/${stats.maxExp}',
      Vector2(startX + 6, 70),
    );
  }
}
