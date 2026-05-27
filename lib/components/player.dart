import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../game/my_game.dart';
import 'rpg_stats.dart';
import '../database/database_helper.dart';

import 'package:flutter/material.dart';

class Player extends SpriteComponent with HasGameReference<MyGame> {
  late JoystickComponent joystick;
  late RpgStats stats;
  
  final double speed = 150.0;
  Vector2 lastDirection = Vector2(1, 0);

  Player(this.joystick) : super(size: Vector2(64, 64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Carregar a imagem do guerreiro
    sprite = await gameRef.loadSprite('warrior.png');
    
    // Posição inicial no centro da tela
    position = gameRef.size / 2;
    
    // Tentar carregar os stats do banco
    final savedStats = await DatabaseHelper.instance.loadStats();
    if (savedStats != null) {
      stats = RpgStats.fromMap(savedStats);
    } else {
      stats = RpgStats(); // Valores padrões
      await DatabaseHelper.instance.saveStats(stats.toMap());
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Lógica de movimentação usando o Joystick
    if (!joystick.delta.isZero()) {
      position.add(joystick.relativeDelta * speed * dt);
      
      // Salva a última direção para o ataque
      lastDirection = joystick.relativeDelta;
      
      // Virar o sprite dependendo da direção horizontal
      if (joystick.relativeDelta.x < 0 && !isFlippedHorizontally) {
        flipHorizontally();
      } else if (joystick.relativeDelta.x > 0 && isFlippedHorizontally) {
        flipHorizontally();
      }
    }
  }

  void attack() {
    // Aqui adicionaremos a lógica de ataque (instanciar a hitbox da espada)
    // baseada na lastDirection
    print("Ataque realizado! Força: \${stats.attackPower}");
    
    // Exemplo: Criar efeito visual de ataque na frente do jogador
    final attackEffect = AttackEffect(position + (lastDirection * 40));
    gameRef.add(attackEffect);
  }
}

class AttackEffect extends SpriteComponent with HasGameReference<MyGame> {
  double _lifeTime = 0.2; // Efeito dura 0.2 segundos

  AttackEffect(Vector2 position) : super(size: Vector2(32, 32), position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Usaremos um quadrado vermelho como placeholder para o corte da espada
    // Você pode trocar por uma imagem real depois
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFFFF0000); // Vermelho
    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTime -= dt;
    if (_lifeTime <= 0) {
      removeFromParent(); // Some depois do ataque
    }
  }
}
