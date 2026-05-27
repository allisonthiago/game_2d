class Item {
  String id;
  String name;
  String description;
  String type; // 'consumable', 'weapon', 'armor', 'quest'
  String icon; // path to the asset image
  int value; // e.g., heal amount for potions, attack power for weapons
  int quantity;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    required this.value,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'icon': icon,
      'value': value,
      'quantity': quantity,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      type: map['type'],
      icon: map['icon'],
      value: map['value'],
      quantity: map['quantity'] ?? 1,
    );
  }
}
