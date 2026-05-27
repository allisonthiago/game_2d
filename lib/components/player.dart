import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent {
  Player() {
    size = Vector2(50, 50); // Tamanho inicial do jogador
    position = Vector2(100, 100); // Posição inicial no mundo
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Desenha um quadrado azul como placeholder para o jogador
    final paint = Paint()..color = Colors.blue;
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Lógica de atualização (ex: movimento) vai aqui
  }
}
