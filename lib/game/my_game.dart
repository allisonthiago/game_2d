import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/player.dart';

class MyGame extends FlameGame {
  late Player _player;

  @override
  Color backgroundColor() => const Color(0xFF000000); // Fundo preto

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Inicializa e adiciona o jogador à cena do jogo
    _player = Player();
    add(_player);
  }
}
