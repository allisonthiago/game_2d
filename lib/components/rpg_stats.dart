class RpgStats {
  int level;
  int currentExp;
  int maxExp;
  int currentHealth;
  int maxHealth;
  int currentStamina;
  int maxStamina;
  int attackPower;
  int defense;

  RpgStats({
    this.level = 1,
    this.currentExp = 0,
    this.maxExp = 100,
    this.currentHealth = 100,
    this.maxHealth = 100,
    this.currentStamina = 100,
    this.maxStamina = 100,
    this.attackPower = 10,
    this.defense = 5,
  });

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'currentExp': currentExp,
      'maxExp': maxExp,
      'currentHealth': currentHealth,
      'maxHealth': maxHealth,
      'currentStamina': currentStamina,
      'maxStamina': maxStamina,
      'attackPower': attackPower,
      'defense': defense,
    };
  }

  factory RpgStats.fromMap(Map<String, dynamic> map) {
    return RpgStats(
      level: map['level'] ?? 1,
      currentExp: map['currentExp'] ?? 0,
      maxExp: map['maxExp'] ?? 100,
      currentHealth: map['currentHealth'] ?? 100,
      maxHealth: map['maxHealth'] ?? 100,
      currentStamina: map['currentStamina'] ?? 100,
      maxStamina: map['maxStamina'] ?? 100,
      attackPower: map['attackPower'] ?? 10,
      defense: map['defense'] ?? 5,
    );
  }

  void addExp(int exp) {
    currentExp += exp;
    if (currentExp >= maxExp) {
      levelUp();
    }
  }

  void levelUp() {
    level++;
    currentExp -= maxExp;
    maxExp = (maxExp * 1.5).toInt();
    maxHealth += 20;
    currentHealth = maxHealth;
    maxStamina += 10;
    currentStamina = maxStamina;
    attackPower += 3;
    defense += 2;
  }
}
