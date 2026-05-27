import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../game/my_game.dart';
import 'rpg_stats.dart';
import '../database/database_helper.dart';

import 'package:flutter/material.dart';
import 'dart:math';
import 'item.dart';
import 'enemy.dart';
import 'wall.dart';
import 'zone_portal.dart';
import 'river.dart';

class Player extends SpriteComponent with HasGameReference<MyGame>, CollisionCallbacks {
  late JoystickComponent joystick;
  late RpgStats stats;
  List<Item> inventory = [];
  
  final double speed = 150.0;
  Vector2 lastDirection = Vector2(1, 0);

  // Controle interno de precisão de double para HP/Stamina
  double currentHealth = 100.0;
  double currentStamina = 100.0;
  double _damageCooldownTimer = 0.0;
  bool _isSavingPending = false;
  Vector2 _previousPosition = Vector2.zero();

  // Estados adicionais de Física e Animação
  double _jumpOffset = 0.0;
  double _jumpVelocity = 0.0;
  Vector2 _knockbackVelocity = Vector2.zero();
  double _walkCycle = 0.0;
  double _attackAnimTimer = 0.0;
  bool isRunning = false;

  Player(this.joystick) : super(size: Vector2(64, 64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Carregar a imagem do guerreiro
    sprite = await game.loadSprite('warrior.png');
    
    // Posição inicial no centro da tela
    position = game.size / 2;
    
    // Adicionar a caixa de colisão do Player
    add(RectangleHitbox(
      size: Vector2(40, 50),
      position: Vector2(12, 14), // Ajuste manual dependendo do sprite
    ));
    
    // Tentar carregar os stats do banco
    final savedStats = await DatabaseHelper.instance.loadStats();
    if (savedStats != null) {
      stats = RpgStats.fromMap(savedStats);
    } else {
      stats = RpgStats(); // Valores padrões
      await DatabaseHelper.instance.saveStats(stats.toMap());
    }

    currentHealth = stats.currentHealth.toDouble();
    currentStamina = stats.currentStamina.toDouble();

    // Carregar Inventário
    final savedInventory = await DatabaseHelper.instance.loadInventory();
    if (savedInventory.isEmpty) {
      // Dá uma poção de presente pro jogador novo testar
      final initialPotion = Item(
        id: 'potion_1',
        name: 'Poção de Vida',
        description: 'Restaura 50 pontos de vida.',
        type: 'consumable',
        icon: 'assets/images/potion.png',
        value: 50,
        quantity: 1,
      );
      await DatabaseHelper.instance.saveItem(initialPotion.toMap());
      inventory.add(initialPotion);
    } else {
      inventory = savedInventory.map((itemMap) => Item.fromMap(itemMap)).toList();
    }
  }

  @override
  void update(double dt) {
    _previousPosition.setFrom(position);
    super.update(dt);
    
    // 1. Atualizar timers de animação e cooldown
    if (_damageCooldownTimer > 0) {
      _damageCooldownTimer -= dt;
    }
    if (_attackAnimTimer > 0) {
      _attackAnimTimer -= dt;
    }

    // 2. Aplicar Física de Pulo (Gravidade 2.5D)
    if (_jumpOffset > 0.0 || _jumpVelocity > 0.0) {
      _jumpOffset += _jumpVelocity * dt;
      _jumpVelocity -= 980.0 * dt; // Gravidade descendo
      if (_jumpOffset < 0.0) {
        _jumpOffset = 0.0;
        _jumpVelocity = 0.0;
      }
    }

    // 3. Aplicar Recuo (Knockback) de dano
    if (!_knockbackVelocity.isZero()) {
      position.add(_knockbackVelocity * dt);
      _knockbackVelocity *= 0.8; // Decaimento rápido por atrito
      if (_knockbackVelocity.length < 5.0) {
        _knockbackVelocity = Vector2.zero();
      }
    }

    // 4. Lógica de Velocidade e Stamina
    bool isMoving = !joystick.delta.isZero();
    
    // Determinar velocidade
    double currentSpeed = speed;
    if (isRunning && currentStamina > 0 && isMoving) {
      currentSpeed = speed * 1.6; // Velocidade de corrida: 240 px/s
      currentStamina -= 16.0 * dt; // Consumo de fôlego ao correr
      if (currentStamina < 0) currentStamina = 0;
      stats.currentStamina = currentStamina.round();
      _isSavingPending = true;
    } else {
      // Andando normal ou parado
      if (isMoving) {
        // Andar normal regenera stamina super lentamente
        if (currentStamina < stats.maxStamina) {
          currentStamina += 5.0 * dt;
          if (currentStamina > stats.maxStamina) currentStamina = stats.maxStamina.toDouble();
          stats.currentStamina = currentStamina.round();
        }
      } else {
        // Parado regenera stamina rápido
        if (currentStamina < stats.maxStamina) {
          currentStamina += 15.0 * dt;
          if (currentStamina > stats.maxStamina) currentStamina = stats.maxStamina.toDouble();
          stats.currentStamina = currentStamina.round();
        } else if (_isSavingPending) {
          _isSavingPending = false;
          DatabaseHelper.instance.saveStats(stats.toMap());
        }
      }
    }
    
    // 5. Aplicar Movimento do Joystick se não estiver sob forte recuo (knockback)
    if (_knockbackVelocity.length < 150.0 && isMoving) {
      position.add(joystick.relativeDelta * currentSpeed * dt);
      
      // Incrementar ciclo de passos para animação
      _walkCycle += dt * (isRunning ? 16.0 : 10.0);
      
      // Salva a última direção para o ataque
      lastDirection = joystick.relativeDelta;
      
      // Virar o sprite dependendo da direção horizontal
      if (joystick.relativeDelta.x < 0 && !isFlippedHorizontally) {
        flipHorizontally();
      } else if (joystick.relativeDelta.x > 0 && isFlippedHorizontally) {
        flipHorizontally();
      }

      _isSavingPending = true;
    }
    
    // 6. Travar movimento nas bordas do mapa (dinâmico pelo tamanho do background)
    position.clamp(
      Vector2(size.x / 2, size.y / 2),
      game.background.size - (size / 2),
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.save();

    // 1. Aplicar animação de Pulo
    if (_jumpOffset > 0.0) {
      canvas.translate(0, -_jumpOffset);
      
      // Efeito Squash & Stretch no pulo
      double stretch = (_jumpVelocity / 300.0) * 0.12;
      canvas.scale(1.0 - stretch, 1.0 + stretch);
    }

    // 2. Aplicar animação de Passada (Bobbing + Tilt)
    bool isMoving = !joystick.delta.isZero();
    if (isMoving && _jumpOffset == 0.0) {
      double bob = sin(_walkCycle) * 3.0;
      double tilt = cos(_walkCycle) * 0.08;
      canvas.translate(0, bob);
      canvas.skew(tilt, 0);
    }

    // Desenha o sprite do Guerreiro com os transforms aplicados
    super.render(canvas);
    canvas.restore();

    // 3. Desenhar Espada Procedural ao atacar
    if (_attackAnimTimer > 0) {
      final double progress = 1.0 - (_attackAnimTimer / 0.2);
      final double angle = atan2(lastDirection.y, lastDirection.x);
      
      // O arco vai de -60 graus a +60 graus da direção do ataque
      final double sweep = -pi/3 + (progress * (2 * pi / 3));
      
      canvas.save();
      // Move a origem do desenho para o centro do jogador
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(angle + sweep);
      
      // Desenha o cabo da espada (Marrom)
      final handlePaint = Paint()..color = const Color(0xFF5D4037);
      canvas.drawRect(const Rect.fromLTWH(18, -2, 8, 4), handlePaint);
      
      // Guarda-mão dourado
      final guardPaint = Paint()..color = const Color(0xFFFFD54F);
      canvas.drawRect(const Rect.fromLTWH(26, -8, 3, 16), guardPaint);
      
      // Lâmina de aço brilhante
      final bladePaint = Paint()..color = const Color(0xFFECEFF1);
      canvas.drawRect(const Rect.fromLTWH(29, -3, 24, 6), bladePaint);
      
      // Ponta da lâmina (Triângulo)
      final tipPath = Path()
        ..moveTo(53, -3)
        ..lineTo(59, 0)
        ..lineTo(53, 3)
        ..close();
      canvas.drawPath(tipPath, bladePaint);
      
      canvas.restore();
      
      // Desenhar rastro de ar em corte translúcido (Vento)
      final arcPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.5 * (1.0 - progress))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round;
      
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(angle);
      
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: 46),
        -pi/3,
        (2 * pi / 3) * progress,
        false,
        arcPaint,
      );
      canvas.restore();
    }
  }

  void attack() {
    if (currentStamina < 15.0) {
      print("Sem stamina suficiente para atacar!");
      return;
    }

    currentStamina -= 15.0;
    stats.currentStamina = currentStamina.round();
    DatabaseHelper.instance.saveStats(stats.toMap());

    // Dispara cronômetro de ataque (duração de 0.2 segundos)
    _attackAnimTimer = 0.2;

    print("Ataque realizado! Força: ${stats.attackPower}");
    
    // Criar caixa de colisão do golpe
    final attackEffect = AttackEffect(position + (lastDirection * 40));
    game.add(attackEffect);
  }

  void jump() {
    if (_jumpOffset == 0.0) {
      _jumpVelocity = 280.0;
      print("Pulo iniciado!");
    }
  }

  void useItem(Item item) {
    if (item.type == 'consumable') {
      currentHealth += item.value;
      if (currentHealth > stats.maxHealth) {
        currentHealth = stats.maxHealth.toDouble();
      }
      stats.currentHealth = currentHealth.round();
      
      // Reduzir quantidade
      item.quantity--;
      if (item.quantity <= 0) {
        inventory.remove(item);
        DatabaseHelper.instance.deleteItem(item.id);
      } else {
        DatabaseHelper.instance.saveItem(item.toMap());
      }
      // Salvar os status de vida
      DatabaseHelper.instance.saveStats(stats.toMap());
      print("Usou ${item.name}. Vida curada!");
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Wall || other is River) {
      // Se estiver pulando alto o suficiente, ignora colisão com o Rio!
      if (other is River && _jumpOffset > 12.0) {
        return;
      }
      // Impede movimentação através da barreira
      position.setFrom(_previousPosition);
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Slime) {
      // Recebe dano e recuo com base na posição do Slime
      takeDamage(other.attackDamage, other.position);
    }
  }

  void takeDamage(int amount, Vector2 enemyPosition) {
    if (_damageCooldownTimer > 0) return;

    currentHealth -= amount;
    if (currentHealth < 0) currentHealth = 0;
    stats.currentHealth = currentHealth.round();

    _damageCooldownTimer = 1.0;

    // Calcular vetor de recuo (knockback)
    Vector2 pushDirection = (position - enemyPosition).normalized();
    if (pushDirection.isZero()) {
      pushDirection = Vector2(0, -1);
    }
    
    // Aplica impulso de recuo
    _knockbackVelocity = pushDirection * 350.0;

    // Feedback visual piscando em vermelho
    paint.color = Colors.red;
    Future.delayed(const Duration(milliseconds: 150), () {
      paint.color = Colors.white;
    });

    DatabaseHelper.instance.saveStats(stats.toMap());

    if (currentHealth <= 0) {
      respawn();
    }
  }

  void respawn() {
    print("Jogador morreu! Renascendo...");
    currentHealth = stats.maxHealth.toDouble();
    currentStamina = stats.maxStamina.toDouble();
    stats.currentHealth = currentHealth.round();
    stats.currentStamina = currentStamina.round();
    position = game.background.size / 2;
    DatabaseHelper.instance.saveStats(stats.toMap());
  }
}

class AttackEffect extends SpriteComponent with HasGameReference<MyGame>, CollisionCallbacks {
  double _lifeTime = 0.2; // Efeito dura 0.2 segundos

  AttackEffect(Vector2 position) : super(size: Vector2(32, 32), position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Adiciona o Hitbox que vai colidir com o inimigo
    add(RectangleHitbox());
  }
  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    // Se bater num Slime, causa dano
    if (other is Slime) {
      other.takeDamage(game.player.stats.attackPower);
      removeFromParent(); // Destrói o efeito após o acerto
    }
  }
  
  @override
  void render(Canvas canvas) {
    // Não precisa desenhar o quadrado vermelho original pois a espada procedural 
    // já é desenhada no corpo do player! Apenas a caixa de colisão atua aqui.
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
