import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../game/my_game.dart';
import 'wall.dart';

class Slime extends SpriteComponent with HasGameReference<MyGame>, CollisionCallbacks {
  final double speed = 50.0;
  final double chaseDistance = 300.0;
  final int attackDamage = 10;
  int health = 20;

  Vector2 _previousPosition = Vector2.zero();

  Slime(Vector2 position) : super(size: Vector2(48, 48), position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await game.loadSprite('slime.png');
    
    // Adiciona a caixa de colisão ao redor do Slime
    add(RectangleHitbox(
      size: Vector2(40, 40),
      position: Vector2(4, 4), // Centraliza o hitbox dentro dos 48x48
    ));
  }

  @override
  void update(double dt) {
    _previousPosition.setFrom(position);
    super.update(dt);
    
    // IA de perseguição básica
    final player = game.player;
    final distanceToPlayer = position.distanceTo(player.position);
    
    // Se o jogador estiver perto o suficiente, persiga-o
    if (distanceToPlayer < chaseDistance) {
      final direction = (player.position - position).normalized();
      position.add(direction * speed * dt);
      
      // Vira o sprite na direção correta
      if (direction.x < 0 && isFlippedHorizontally) {
        flipHorizontally();
      } else if (direction.x > 0 && !isFlippedHorizontally) {
        flipHorizontally();
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Wall) {
      position.setFrom(_previousPosition);
    }
  }

  void takeDamage(int damage) {
    health -= damage;
    
    // Efeito visual de tomar dano (ficar vermelho rapidamente)
    // Em Flame puro, a maneira mais fácil de piscar é alterar temporariamente o paint, 
    // mas por simplicidade e robustez, se morrer, desaparecemos.
    
    if (health <= 0) {
      die();
    }
  }

  void die() {
    print("Slime morreu!");
    removeFromParent();
    // Concede XP ao jogador
    game.player.stats.addExp(30);
  }
}
