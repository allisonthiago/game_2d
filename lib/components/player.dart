import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../game/my_game.dart';
import 'rpg_stats.dart';
import '../database/database_helper.dart';

import 'package:flutter/material.dart';
import 'item.dart';
import 'enemy.dart';
import 'wall.dart';
import 'zone_portal.dart';

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
    
    // Cooldown de dano sofrido
    if (_damageCooldownTimer > 0) {
      _damageCooldownTimer -= dt;
    }

    bool isMoving = !joystick.delta.isZero();
    double currentSpeed = (currentStamina > 0) ? speed : (speed / 2.0);
    
    if (isMoving) {
      position.add(joystick.relativeDelta * currentSpeed * dt);
      
      // Salva a última direção para o ataque
      lastDirection = joystick.relativeDelta;
      
      // Virar o sprite dependendo da direção horizontal
      if (joystick.relativeDelta.x < 0 && !isFlippedHorizontally) {
        flipHorizontally();
      } else if (joystick.relativeDelta.x > 0 && isFlippedHorizontally) {
        flipHorizontally();
      }

      // Consumir stamina ao correr
      currentStamina -= 12.0 * dt;
      if (currentStamina < 0) currentStamina = 0;
      stats.currentStamina = currentStamina.round();

      _isSavingPending = true;
    } else {
      // Regenerar stamina ao ficar parado
      if (currentStamina < stats.maxStamina) {
        currentStamina += 15.0 * dt;
        if (currentStamina > stats.maxStamina) {
          currentStamina = stats.maxStamina.toDouble();
        }
        stats.currentStamina = currentStamina.round();
      } else if (_isSavingPending) {
        _isSavingPending = false;
        DatabaseHelper.instance.saveStats(stats.toMap());
      }
    }
    
    // Travar movimento nas bordas do mapa (dinâmico pelo tamanho do background)
    position.clamp(
      Vector2(size.x / 2, size.y / 2),
      game.background.size - (size / 2),
    );
  }

  void attack() {
    if (currentStamina < 15.0) {
      print("Sem stamina suficiente para atacar!");
      return;
    }

    currentStamina -= 15.0;
    stats.currentStamina = currentStamina.round();
    DatabaseHelper.instance.saveStats(stats.toMap());

    print("Ataque realizado! Força: ${stats.attackPower}");
    
    // Criar efeito visual de ataque na frente do jogador
    final attackEffect = AttackEffect(position + (lastDirection * 40));
    game.add(attackEffect);
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
    if (other is Wall) {
      // Impede movimentação através da parede
      position.setFrom(_previousPosition);
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Slime) {
      // Recebe dano do Slime ao colidir
      takeDamage(other.attackDamage);
    }
  }

  void takeDamage(int amount) {
    if (_damageCooldownTimer > 0) return;

    currentHealth -= amount;
    if (currentHealth < 0) currentHealth = 0;
    stats.currentHealth = currentHealth.round();

    _damageCooldownTimer = 1.0;

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
    // Usaremos um quadrado vermelho como placeholder para o corte da espada
    // Você pode trocar por uma imagem real depois
    
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
