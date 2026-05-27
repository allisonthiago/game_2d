import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../game/my_game.dart';

class Wall extends PositionComponent with HasGameReference<MyGame>, CollisionCallbacks {
  Wall({required Vector2 position, required Vector2 size}) : super(position: position, size: size) {
    // Ativa colisão física
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Fundo cinza escuro de pedra
    final rect = size.toRect();
    final bgPaint = Paint()..color = const Color(0xFF4A4A4A);
    canvas.drawRect(rect, bgPaint);
    
    // Borda do bloco
    final borderPaint = Paint()
      ..color = const Color(0xFF2E2E2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(rect, borderPaint);
    
    // Desenho procedimental das ranhuras de tijolo
    final linePaint = Paint()
      ..color = const Color(0xFF6B6B6B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    int horizontalSplits = (size.y / 16).round();
    if (horizontalSplits < 1) horizontalSplits = 1;
    
    for (int i = 1; i < horizontalSplits; i++) {
      double y = i * (size.y / horizontalSplits);
      canvas.drawLine(Offset(0, y), Offset(size.x, y), linePaint);
    }
    
    int verticalSplits = (size.x / 16).round();
    if (verticalSplits < 1) verticalSplits = 1;
    
    for (int i = 0; i < horizontalSplits; i++) {
      double yStart = i * (size.y / horizontalSplits);
      double yEnd = (i + 1) * (size.y / horizontalSplits);
      double offset = (i % 2 == 0) ? 0.0 : (size.x / verticalSplits) / 2.0;
      
      for (int j = 0; j < verticalSplits; j++) {
        double x = j * (size.x / verticalSplits) + offset;
        if (x < size.x) {
          canvas.drawLine(Offset(x, yStart), Offset(x, yEnd), linePaint);
        }
      }
    }
  }
}
