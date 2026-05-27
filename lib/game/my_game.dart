import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../components/player.dart';

class MyGame extends FlameGame {
  late Player _player;
  late JoystickComponent joystick;
  late SpriteComponent background;
  late HudButtonComponent attackButton;

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
        _player.attack();
      },
    );

    // Inicializa o jogador passando o joystick
    _player = Player(joystick);
    
    // Adiciona o jogador à cena
    add(_player);
    
    // Adiciona os controles (Joystick e Botão ficam presos na tela HUD)
    add(joystick);
    add(attackButton);

    // Focar a câmera no jogador
    camera.follow(_player);
  }
}
