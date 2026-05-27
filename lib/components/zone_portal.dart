import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../game/my_game.dart';

class ZonePortal extends PositionComponent with HasGameReference<MyGame>, CollisionCallbacks {
  final String targetZone;
  final Vector2 spawnPosition;

  ZonePortal({
    required Vector2 position,
    required Vector2 size,
    required this.targetZone,
    required this.spawnPosition,
  }) : super(position: position, size: size) {
    // Ativa colisão física
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Desenho de um portal de energia roxa/azulada
    final rect = size.toRect();
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.purpleAccent.withOpacity(0.9),
          Colors.indigo.withOpacity(0.5),
          Colors.transparent,
        ],
      ).createShader(rect);
      
    canvas.drawOval(rect, paint);
    
    // Anel externo brilhante
    final borderPaint = Paint()
      ..color = Colors.purpleAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawOval(rect, borderPaint);
  }
}
