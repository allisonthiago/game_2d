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

class MyGame extends FlameGame with HasCollisionDetection {
  late Player player;
  late JoystickComponent joystick;
  late ZoneBackground background;
  late HudButtonComponent attackButton;
  late HudButtonComponent inventoryButton;
  
  String currentZone = 'floresta';

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
    add(inventoryButton);
    
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
      c is ZoneBackground
    ).toList();
    
    removeAll(oldComponents);

    // 2. Instanciar e adicionar o novo plano de fundo (Priority: -10)
    background = ZoneBackground(zoneName: zoneName, size: Vector2(1000, 1000))..priority = -10;
    add(background);

    // 3. Montar o layout de colisões, portais e spawnar inimigos
    if (zoneName == 'floresta') {
      // Spawn de slimes normais
      add(Slime(Vector2(200, 200)));
      add(Slime(Vector2(600, 300)));
      add(Slime(Vector2(400, 700)));

      // Portal para a Vila (Vila fica à direita)
      add(ZonePortal(
        position: Vector2(970, 450),
        size: Vector2(30, 100),
        targetZone: 'vila',
        spawnPosition: Vector2(70, 500),
      ));

      // Paredes limitadoras do mapa (Floresta)
      add(Wall(position: Vector2(0, 0), size: Vector2(1000, 20))); // Topo
      add(Wall(position: Vector2(0, 980), size: Vector2(1000, 20))); // Base
      add(Wall(position: Vector2(0, 20), size: Vector2(20, 960))); // Esquerda
      
      // Direita com vão para o portal
      add(Wall(position: Vector2(980, 20), size: Vector2(20, 430))); // Superior
      add(Wall(position: Vector2(980, 550), size: Vector2(20, 430))); // Inferior

      // Obstáculos extras na Floresta (Rochas)
      add(Wall(position: Vector2(350, 350), size: Vector2(64, 64)));
      add(Wall(position: Vector2(700, 650), size: Vector2(128, 64)));
    } 
    else if (zoneName == 'vila') {
      // Vila Pacífica: sem inimigos (ou 1 slime inofensivo com 1 HP para teste)
      
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

      // Casas da Vila (Obstáculos físicos intransponíveis)
      add(Wall(position: Vector2(150, 150), size: Vector2(160, 120))); // Casa 1
      add(Wall(position: Vector2(650, 150), size: Vector2(160, 120))); // Casa 2
      add(Wall(position: Vector2(420, 450), size: Vector2(160, 160))); // Casa Central/Taverna
    } 
    else if (zoneName == 'masmorra') {
      // Masmorra escura com slimes mais resistentes (Vida: 45, Dano: 20)
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

      // Paredes internas criando um Labirinto
      add(Wall(position: Vector2(300, 100), size: Vector2(30, 450))); // Parede vertical
      add(Wall(position: Vector2(330, 520), size: Vector2(340, 30))); // Parede horizontal
      add(Wall(position: Vector2(640, 250), size: Vector2(30, 300))); // Parede vertical 2
    }

    // 4. Posicionar o jogador na entrada da nova zona, se aplicável
    if (playerSpawnPosition != null) {
      player.position.setFrom(playerSpawnPosition);
    }
  }
}
