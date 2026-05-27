import 'package:flutter/material.dart';
import '../game/my_game.dart';

class InventoryMenu extends StatefulWidget {
  final MyGame game;

  const InventoryMenu({Key? key, required this.game}) : super(key: key);

  @override
  _InventoryMenuState createState() => _InventoryMenuState();
}

class _InventoryMenuState extends State<InventoryMenu> {
  @override
  Widget build(BuildContext context) {
    // Pegar o inventário atual do Player
    final inventory = widget.game.player.inventory;

    return Center(
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.brown[800],
          border: Border.all(color: Colors.amber, width: 4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Inventário',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: inventory.isEmpty
                  ? const Center(
                      child: Text(
                        'Inventário Vazio',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: inventory.length,
                      itemBuilder: (context, index) {
                        final item = inventory[index];
                        return GestureDetector(
                          onTap: () {
                            // Usar o item ao clicar
                            setState(() {
                              widget.game.player.useItem(item);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.brown[600],
                              border: Border.all(color: Colors.amberAccent),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Image.asset(item.icon, width: 32, height: 32),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 4,
                                  child: Text(
                                    'x\${item.quantity}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  widget.game.overlays.remove('InventoryMenu');
                  widget.game.resumeEngine(); // Retoma o jogo
                },
                child: const Text('Fechar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
