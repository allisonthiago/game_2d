import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/my_game.dart';
import 'database/database_helper.dart';
import 'ui/inventory_menu.dart';

void main() async {
  // Garante que o binding do Flutter esteja inicializado antes do banco de dados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a instância do banco de dados (sqflite)
  await DatabaseHelper.instance.database;

  // Roda o aplicativo com o widget do jogo
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget<MyGame>(
          game: MyGame(),
          overlayBuilderMap: {
            'InventoryMenu': (BuildContext context, MyGame game) {
              return InventoryMenu(game: game);
            },
          },
        ),
      ),
    ),
  );
}
