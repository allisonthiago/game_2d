import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../components/player.dart';
import '../components/player_hud.dart';

class MyGame extends FlameGame {
  late Player player;
  late JoystickComponent joystick;
  late SpriteComponent background;
  late HudButtonComponent attackButton;
  late HudButtonComponent inventoryButton;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Carregar cenário (Background medieval)
    final bgSprite = await loadSprite('background.png');
    background = SpriteComponent(
      sprite: bgSprite,
      size: Vector2(1000, 1000), // Tamanho grande simulando um mapa
    );
    add(background);

    // Configuração do Joystick Virtual
    final knobPaint = BasicPalette.blue.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.blue.withAlpha(100).paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: knobPaint),
      background: CircleComponent(radius: 50, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    // Configuração do Botão de Ataque Virtual
    final buttonPaint = BasicPalette.red.withAlpha(200).paint();
    final buttonDownPaint = BasicPalette.red.withAlpha(255).paint();
    attackButton = HudButtonComponent(
      button: CircleComponent(radius: 30, paint: buttonPaint),
      buttonDown: CircleComponent(radius: 30, paint: buttonDownPaint),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      onPressed: () {
        player.attack();
      },
    );

    // Configuração do Botão de Inventário Virtual
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
    );

    // Inicializa o jogador passando o joystick
    player = Player(joystick);
    
    // Adiciona o jogador à cena
    add(player);
    
    // Adiciona os controles e a HUD (ficam presos na tela)
    add(joystick);
    add(attackButton);
    add(inventoryButton);
    add(PlayerHud());

    // Focar a câmera no jogador
    camera.follow(player);
  }
}
