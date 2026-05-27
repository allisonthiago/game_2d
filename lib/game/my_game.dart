import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../components/player.dart';
import '../components/player_hud.dart';
import '../components/enemy.dart';
import '../components/zone_background.dart';
import '../components/wall.dart';
import '../components/zone_portal.dart';
import '../components/tree.dart';
import '../components/cloud.dart';
import '../components/river.dart';

class MyGame extends FlameGame with HasCollisionDetection {
  late Player player;
  late JoystickComponent joystick;
  late ZoneBackground background;
  late HudButtonComponent attackButton;
  late HudButtonComponent runButton;
  late HudButtonComponent jumpButton;
  late HudButtonComponent inventoryButton;
  
  String currentZone = 'floresta';

  @override
  void update(double dt) {
    super.update(dt);
    
    // Y-sorting dinâmico para dar profundidade visual 2D Zelda-like
    for (final child in children) {
      if (child is Player) {
        // Base inferior do herói (âncora é centro)
        child.priority = (child.position.y + child.size.y / 2).toInt();
      } else if (child is Slime) {
        // Base inferior do slime (âncora é centro)
        child.priority = (child.position.y + child.size.y / 2).toInt();
      } else if (child is Tree) {
        // Árvores usam Anchor.bottomCenter, então Y já representa a base
        child.priority = child.position.y.toInt();
      } else if (child is Wall) {
        // Paredes normais usam Anchor.topLeft
        child.priority = (child.position.y + child.size.y).toInt();
      } else if (child is River) {
        // Rio fica desenhado sempre no fundo (sobre o background)
        child.priority = -5;
      }
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Configuração do Joystick Virtual (Priority: 100)
    final knobPaint = BasicPalette.blue.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.blue.withAlpha(100).paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: knobPaint),
      background: CircleComponent(radius: 50, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
      priority: 100,
    );

    // Configuração do Botão de Ataque Virtual (Priority: 100)
    final buttonPaint = BasicPalette.red.withAlpha(200).paint();
    final buttonDownPaint = BasicPalette.red.withAlpha(255).paint();
    attackButton = HudButtonComponent(
      button: CircleComponent(radius: 30, paint: buttonPaint),
      buttonDown: CircleComponent(radius: 30, paint: buttonDownPaint),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      onPressed: () {
        player.attack();
      },
      priority: 100,
    );

    // Configuração do Botão de Correr Virtual (Priority: 100)
    final runButtonPaint = BasicPalette.gray.withAlpha(180).paint();
    final runButtonDownPaint = BasicPalette.gray.withAlpha(240).paint();
    runButton = HudButtonComponent(
      button: CircleComponent(radius: 20, paint: runButtonPaint),
      buttonDown: CircleComponent(radius: 20, paint: runButtonDownPaint),
      margin: const EdgeInsets.only(right: 120, bottom: 40),
      onPressed: () {
        player.isRunning = true;
      },
      onReleased: () {
        player.isRunning = false;
      },
      priority: 100,
    );

    // Configuração do Botão de Pular Virtual (Priority: 100)
    final jumpButtonPaint = BasicPalette.gray.withAlpha(180).paint();
    final jumpButtonDownPaint = BasicPalette.gray.withAlpha(240).paint();
    jumpButton = HudButtonComponent(
      button: CircleComponent(radius: 20, paint: jumpButtonPaint),
      buttonDown: CircleComponent(radius: 20, paint: jumpButtonDownPaint),
      margin: const EdgeInsets.only(right: 40, bottom: 120),
      onPressed: () {
        player.jump();
      },
      priority: 100,
    );

    // Configuração do Botão de Inventário Virtual (Priority: 100)
    final invButtonPaint = BasicPalette.green.withAlpha(200).paint();
    final invButtonDownPaint = BasicPalette.green.withAlpha(255).paint();
    inventoryButton = HudButtonComponent(
      button: CircleComponent(radius: 20, paint: invButtonPaint),
      buttonDown: CircleComponent(radius: 20, paint: invButtonDownPaint),
      margin: const EdgeInsets.only(top: 40, right: 40),
      onPressed: () {
        pauseEngine();
        overlays.add('InventoryMenu');
      },
      priority: 100,
    );

    // Inicializa o jogador passando o joystick (Priority: 10)
    player = Player(joystick)..priority = 10;
    
    // Adiciona o jogador à cena
    add(player);
    
    // Adiciona os controles e a HUD (ficam presos na tela, Priority: 100)
    add(joystick);
    add(attackButton);
    add(runButton);
    add(jumpButton);
    add(inventoryButton);
    
    // Rótulos de identificação visual para os botões virtuais
    final runLabel = TextComponent(
      text: 'RUN',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
      position: Vector2(20, 20),
      anchor: Anchor.center,
    );
    runButton.add(runLabel);

    final jumpLabel = TextComponent(
      text: 'JUMP',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
      ),
      position: Vector2(20, 20),
      anchor: Anchor.center,
    );
    jumpButton.add(jumpLabel);

    final hud = PlayerHud()..priority = 100;
    add(hud);

    // Carrega a primeira zona (Floresta)
    loadZone('floresta');

    // Focar a câmera no jogador
    camera.follow(player);
  }

  void loadZone(String zoneName, {Vector2? playerSpawnPosition}) {
    currentZone = zoneName;

    // 1. Limpar os componentes da zona anterior (Inimigos, Paredes, Portais e Fundo)
    final oldComponents = children.where((c) =>
      c is Slime ||
      c is Wall ||
      c is ZonePortal ||
      c is ZoneBackground ||
      c is Tree ||
      c is Cloud ||
      c is River
    ).toList();
    
    removeAll(oldComponents);

    // 2. Instanciar e adicionar o novo plano de fundo (Priority: -10)
    background = ZoneBackground(zoneName: zoneName, size: Vector2(1000, 1000))..priority = -10;
    add(background);

    // 3. Montar o layout de colisões, portais e spawnar inimigos
    if (zoneName == 'floresta') {
      // Spawn de slimes normais
      add(Slime(Vector2(200, 250)));
      add(Slime(Vector2(750, 300)));
      add(Slime(Vector2(250, 750)));

      // O Rio cruzando o mapa a X=460 (largura 80px)
      add(River(position: Vector2(460, 0)));

      // Portal para a Vila (Vila fica à direita)
      add(ZonePortal(
        position: Vector2(970, 450),
        size: Vector2(30, 100),
        targetZone: 'vila',
        spawnPosition: Vector2(70, 500),
      ));

      // Fronteiras densas de árvores gigantes ao invés de muralhas
      // Topo
      for (double x = 0; x <= 1000; x += 90) {
        add(Tree(position: Vector2(x, 60), isGiant: true));
      }
      // Base
      for (double x = 0; x <= 1000; x += 90) {
        add(Tree(position: Vector2(x, 1050), isGiant: true));
      }
      // Esquerda
      for (double y = 140; y <= 980; y += 90) {
        add(Tree(position: Vector2(10, y), isGiant: true));
      }
      // Direita (com vão para o portal de Y=450 a Y=550)
      for (double y = 140; y <= 980; y += 90) {
        if (y > 380 && y < 580) continue;
        add(Tree(position: Vector2(990, y), isGiant: true));
      }

      // Árvores decorativas com colisão no tronco no meio da Floresta
      add(Tree(position: Vector2(200, 350)));
      add(Tree(position: Vector2(260, 420)));
      add(Tree(position: Vector2(720, 200)));
      add(Tree(position: Vector2(800, 700)));
      add(Tree(position: Vector2(250, 780)));

      // Nuvens flutuantes lentas para efeito de Parallax no céu (Priority: 95)
      add(Cloud(position: Vector2(100, 150), speed: 12.0, opacity: 0.35, scaleFactor: 1.0));
      add(Cloud(position: Vector2(450, 400), speed: 8.0, opacity: 0.3, scaleFactor: 1.3));
      add(Cloud(position: Vector2(800, 680), speed: 18.0, opacity: 0.45, scaleFactor: 0.85));
    } 
    else if (zoneName == 'vila') {
      // Vila Pacífica: sem inimigos
      
      // Portal de volta para a Floresta (à esquerda)
      add(ZonePortal(
        position: Vector2(0, 450),
        size: Vector2(30, 100),
        targetZone: 'floresta',
        spawnPosition: Vector2(930, 500),
      ));

      // Portal para a Masmorra (à base)
      add(ZonePortal(
        position: Vector2(450, 970),
        size: Vector2(100, 30),
        targetZone: 'masmorra',
        spawnPosition: Vector2(500, 70),
      ));

      // Paredes limitadoras (Vila)
      add(Wall(position: Vector2(0, 0), size: Vector2(1000, 20))); // Topo
      add(Wall(position: Vector2(0, 20), size: Vector2(20, 430))); // Esquerda superior
      add(Wall(position: Vector2(0, 550), size: Vector2(20, 430))); // Esquerda inferior
      add(Wall(position: Vector2(980, 20), size: Vector2(20, 960))); // Direita
      
      add(Wall(position: Vector2(20, 980), size: Vector2(430, 20))); // Base esquerda
      add(Wall(position: Vector2(550, 980), size: Vector2(430, 20))); // Base direita

      // Casas da Vila
      add(Wall(position: Vector2(150, 150), size: Vector2(160, 120)));
      add(Wall(position: Vector2(650, 150), size: Vector2(160, 120)));
      add(Wall(position: Vector2(420, 450), size: Vector2(160, 160)));
    } 
    else if (zoneName == 'masmorra') {
      // Masmorra escura com slimes mais resistentes
      final darkSlime1 = Slime(Vector2(250, 400))..health = 45;
      final darkSlime2 = Slime(Vector2(750, 400))..health = 45;
      final darkSlime3 = Slime(Vector2(500, 750))..health = 45;
      add(darkSlime1);
      add(darkSlime2);
      add(darkSlime3);

      // Portal para a Vila (no topo)
      add(ZonePortal(
        position: Vector2(450, 0),
        size: Vector2(100, 30),
        targetZone: 'vila',
        spawnPosition: Vector2(500, 930),
      ));

      // Paredes limitadoras (Masmorra)
      add(Wall(position: Vector2(0, 20), size: Vector2(20, 960))); // Esquerda
      add(Wall(position: Vector2(980, 20), size: Vector2(20, 960))); // Direita
      add(Wall(position: Vector2(0, 980), size: Vector2(1000, 20))); // Base
      
      add(Wall(position: Vector2(0, 0), size: Vector2(450, 20))); // Topo esquerdo
      add(Wall(position: Vector2(550, 0), size: Vector2(450, 20))); // Topo direito

      // Paredes internas
      add(Wall(position: Vector2(300, 100), size: Vector2(30, 450)));
      add(Wall(position: Vector2(330, 520), size: Vector2(340, 30)));
      add(Wall(position: Vector2(640, 250), size: Vector2(30, 300)));
    }

    // 4. Posicionar o jogador na entrada da nova zona, se aplicável
    if (playerSpawnPosition != null) {
      player.position.setFrom(playerSpawnPosition);
    }
  }
}
