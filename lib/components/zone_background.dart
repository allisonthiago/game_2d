import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/my_game.dart';

class ZoneBackground extends SpriteComponent with HasGameReference<MyGame> {
  final String zoneName;

  ZoneBackground({required this.zoneName, required Vector2 size}) : super(size: size);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Tenta carregar o sprite da imagem correspondente
    try {
      if (zoneName == 'floresta') {
        sprite = await game.loadSprite('background.png');
      } else if (zoneName == 'vila') {
        sprite = await game.loadSprite('background_village.png');
      } else if (zoneName == 'masmorra') {
        sprite = await game.loadSprite('background_dungeon.png');
      }
    } catch (e) {
      debugPrint("Erro ao carregar imagem para a zona '$zoneName'. Usando renderizador procedural. Detalhes: $e");
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      super.render(canvas);
      return;
    }

    final rect = size.toRect();
    if (zoneName == 'floresta') {
      // Grama verde processada proceduralmente
      final paint = Paint()..color = const Color(0xFF3E8E41);
      canvas.drawRect(rect, paint);
      
      final gridPaint = Paint()
        ..color = const Color(0xFF357A38)
        ..strokeWidth = 1.5;
      
      // Pequenas folhas de grama pelo cenário
      for (double x = 0; x < size.x; x += 80) {
        for (double y = 0; y < size.y; y += 80) {
          canvas.drawLine(Offset(x + 5, y + 10), Offset(x + 10, y + 5), gridPaint);
          canvas.drawLine(Offset(x + 10, y + 5), Offset(x + 15, y + 15), gridPaint);
        }
      }
    } else if (zoneName == 'vila') {
      // Terra batida areia/areia quente
      final paint = Paint()..color = const Color(0xFFD2B48C);
      canvas.drawRect(rect, paint);

      // Contornos de caminhos de pedras redondas
      final cobblePaint = Paint()
        ..color = const Color(0xFFC2A375)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      for (double x = 0; x < size.x; x += 120) {
        for (double y = 0; y < size.y; y += 120) {
          canvas.drawOval(Rect.fromLTWH(x + 10, y + 10, 45, 25), cobblePaint);
          canvas.drawOval(Rect.fromLTWH(x + 60, y + 50, 35, 20), cobblePaint);
        }
      }
    } else if (zoneName == 'masmorra') {
      // Pedras cinzas escuras de masmorra
      final paint = Paint()..color = const Color(0xFF2C2C2C);
      canvas.drawRect(rect, paint);

      // Divisão das lajes de pedra
      final linePaint = Paint()
        ..color = const Color(0xFF1E1E1E)
        ..strokeWidth = 3.0;
      
      for (double x = 0; x < size.x; x += 64) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.y), linePaint);
      }
      for (double y = 0; y < size.y; y += 64) {
        canvas.drawLine(Offset(0, y), Offset(size.x, y), linePaint);
      }

      // Rachaduras procedurais nas lajes
      final crackPaint = Paint()
        ..color = const Color(0xFF121212)
        ..strokeWidth = 1.0;
      
      for (double x = 100; x < size.x; x += 200) {
        for (double y = 100; y < size.y; y += 200) {
          canvas.drawLine(Offset(x, y), Offset(x + 8, y + 12), crackPaint);
          canvas.drawLine(Offset(x + 8, y + 12), Offset(x + 3, y + 20), crackPaint);
        }
      }
    }
  }
}
