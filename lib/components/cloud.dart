import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../game/my_game.dart';

class Cloud extends PositionComponent with HasGameReference<MyGame> {
  final double speed;
  final double opacity;
  final double scaleFactor;
  final Random _random = Random();

  Cloud({
    required Vector2 position,
    required this.speed,
    required this.opacity,
    required this.scaleFactor,
  }) : super(position: position, size: Vector2(120, 60), priority: 95);

  @override
  void update(double dt) {
    super.update(dt);
    // Movimento lento da esquerda para a direita
    position.x += speed * dt;
    
    // Se a nuvem sair do mapa (1000px + margem), reaparece na esquerda com uma nova altura Y
    if (position.x > 1150) {
      position.x = -150;
      position.y = _random.nextDouble() * 850 + 50;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Desenho de uma nuvem fofa estilizada usando círculos sobrepostos
    final double radius = 25.0 * scaleFactor;
    
    // Círculo esquerdo
    canvas.drawCircle(Offset(radius, radius * 1.2), radius * 0.8, paint);
    // Círculo central (mais alto)
    canvas.drawCircle(Offset(radius * 1.8, radius), radius, paint);
    // Círculo direito
    canvas.drawCircle(Offset(radius * 2.8, radius * 1.2), radius * 0.8, paint);
    
    // Retângulo base para unir os círculos suavemente por baixo
    final baseRect = Rect.fromLTWH(
      radius * 0.4,
      radius * 0.8,
      radius * 2.6,
      radius * 0.75,
    );
    canvas.drawRect(baseRect, paint);
  }
}
