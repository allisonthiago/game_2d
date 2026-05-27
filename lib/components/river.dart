import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../game/my_game.dart';

class River extends PositionComponent with HasGameReference<MyGame>, CollisionCallbacks {
  double _waveTimer = 0.0;

  River({required Vector2 position})
      : super(
          position: position,
          size: Vector2(80, 1000), // Ocupa toda a altura do mapa
          priority: -2, // Atrás dos personagens mas na frente do fundo gramado
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Hitbox superior (bloqueia água de Y=0 até Y=450)
    add(RectangleHitbox(
      size: Vector2(size.x, 450),
      position: Vector2(0, 0),
    ));

    // Hitbox inferior (bloqueia água de Y=550 até Y=1000)
    add(RectangleHitbox(
      size: Vector2(size.x, 450),
      position: Vector2(0, 550),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _waveTimer += dt * 3.0; // Controla a velocidade de movimento da água
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Desenhar a Água (Azul profundo)
    final rect = size.toRect();
    final waterPaint = Paint()..color = const Color(0xFF1E88E5);
    canvas.drawRect(rect, waterPaint);

    // 2. Ondas do rio animadas procedurais
    final wavePaint = Paint()
      ..color = const Color(0xFF64B5F6).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Desenhar linhas de ondas dinâmicas
    for (double y = 0; y < size.y; y += 45) {
      if (y > 440 && y < 560) continue; // Pula a área da ponte

      // Movimenta horizontalmente as ondas usando seno
      double offsetX = sin(_waveTimer + y / 12.0) * 8.0;
      
      canvas.drawLine(
        Offset(offsetX + 15, y),
        Offset(offsetX + 40, y),
        wavePaint,
      );
      canvas.drawLine(
        Offset(offsetX + 35, y + 20),
        Offset(offsetX + 60, y + 20),
        wavePaint,
      );
    }

    // 3. Desenhar a Ponte de Madeira (de Y=450 até Y=550)
    final bridgeRect = Rect.fromLTWH(0, 450, size.x, 100);
    final bridgeBgPaint = Paint()..color = const Color(0xFF8D6E63); // Cor de prancha de madeira
    canvas.drawRect(bridgeRect, bridgeBgPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF4E342E) // Marrom escuro para divisões
      ..strokeWidth = 3.0;
      
    // Limites de entrada/saída da ponte
    canvas.drawLine(const Offset(0, 450), Offset(size.x, 450), linePaint);
    canvas.drawLine(const Offset(0, 550), Offset(size.x, 550), linePaint);

    // Pranchas de madeira horizontais
    for (double by = 465; by < 550; by += 16) {
      canvas.drawLine(Offset(0, by), Offset(size.x, by), linePaint);
    }

    // Corrimões laterais nas margens
    final railPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.fill;
    
    // Corrimão esquerdo
    canvas.drawRect(const Rect.fromLTWH(-6, 442, 10, 116), railPaint);
    // Corrimão direito
    canvas.drawRect(Rect.fromLTWH(size.x - 4, 442, 10, 116), railPaint);
  }
}
