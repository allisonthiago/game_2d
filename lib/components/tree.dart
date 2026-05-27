import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../game/my_game.dart';

class Tree extends PositionComponent with HasGameReference<MyGame>, CollisionCallbacks {
  final bool isGiant;

  Tree({required Vector2 position, this.isGiant = false})
      : super(
          position: position,
          size: isGiant ? Vector2(128, 160) : Vector2(64, 80),
          anchor: Anchor.bottomCenter, // Ponto de ancoragem na base para Y-sorting correto
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Colisão física apenas no tronco (base inferior do componente)
    double trunkWidth = isGiant ? 40.0 : 20.0;
    double trunkHeight = isGiant ? 30.0 : 15.0;

    add(RectangleHitbox(
      size: Vector2(trunkWidth, trunkHeight),
      position: Vector2((size.x - trunkWidth) / 2, size.y - trunkHeight),
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Desenhar Tronco (Marrom)
    final trunkWidth = isGiant ? 30.0 : 16.0;
    final trunkHeight = isGiant ? 50.0 : 25.0;
    final trunkRect = Rect.fromLTWH(
      (size.x - trunkWidth) / 2,
      size.y - trunkHeight,
      trunkWidth,
      trunkHeight,
    );
    final trunkPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRect(trunkRect, trunkPaint);

    // Detalhe de textura vertical do tronco
    final barkPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawRect(
      Rect.fromLTWH(
        (size.x - trunkWidth) / 2 + trunkWidth / 3,
        size.y - trunkHeight,
        trunkWidth / 4,
        trunkHeight,
      ),
      barkPaint,
    );

    // 2. Desenhar Copa (Verde) com Efeito Parallax 3D
    // A copa se move levemente com base no deslocamento da câmera
    final cameraPos = game.camera.viewfinder.position;
    final diff = cameraPos - position;
    
    final double maxShift = isGiant ? 16.0 : 8.0;
    final double shiftX = (diff.x * 0.05).clamp(-maxShift, maxShift);
    final double shiftY = (diff.y * 0.05).clamp(-maxShift, maxShift);
    final Vector2 canopyOffset = Vector2(shiftX, shiftY - (isGiant ? 50.0 : 28.0));

    // Posição central da copa
    final double centerX = size.x / 2 + canopyOffset.x;
    final double centerY = (size.y - trunkHeight) + canopyOffset.y;
    final double radius = isGiant ? 52.0 : 28.0;

    // Cores da copa para sensação de luz/sombra
    final leavesPaintDark = Paint()..color = const Color(0xFF1B5E20); // Verde escuro (base)
    final leavesPaintMedium = Paint()..color = const Color(0xFF2E7D32); // Verde médio (corpo)
    final leavesPaintLight = Paint()..color = const Color(0xFF4CAF50); // Verde claro (luz solar)

    // Camada Inferior (Sombras)
    canvas.drawCircle(Offset(centerX, centerY), radius, leavesPaintDark);
    canvas.drawCircle(Offset(centerX - radius / 3, centerY + radius / 6), radius * 0.8, leavesPaintDark);
    canvas.drawCircle(Offset(centerX + radius / 3, centerY + radius / 6), radius * 0.8, leavesPaintDark);

    // Camada Média
    canvas.drawCircle(Offset(centerX, centerY - radius / 6), radius * 0.9, leavesPaintMedium);
    canvas.drawCircle(Offset(centerX - radius / 4, centerY), radius * 0.7, leavesPaintMedium);
    canvas.drawCircle(Offset(centerX + radius / 4, centerY), radius * 0.7, leavesPaintMedium);

    // Camada Superior (Brilho do Sol)
    canvas.drawCircle(Offset(centerX - radius / 6, centerY - radius / 3), radius * 0.6, leavesPaintLight);
    canvas.drawCircle(Offset(centerX + radius / 8, centerY - radius / 4), radius * 0.5, leavesPaintLight);
  }
}
