# ⚔️ Game 2D - RPG Medieval (Zelda-like)

Um jogo RPG 2D *top-down* (visto de cima) com temática medieval, desenvolvido inteiramente em **Flutter** utilizando o motor gráfico **Flame**. O projeto foi planejado com foco na exportação para dispositivos móveis (Android/iOS), implementando controles virtuais (Joystick) nativos e persistência de dados local offline.

---

## 🚀 Funcionalidades Atuais

- **Movimentação Livre (8 Direções)**: Sistema de movimentação completo utilizando um Joystick Virtual na tela.
- **Sistema de Combate**: Botão HUD na tela para executar ataques (atualmente exibe um efeito direcional básico).
- **Atributos de RPG**: Sistema embutido de *Status* do personagem, contendo: Nível, Pontos de Experiência (Atual e Máximo), Vida, Força de Ataque e Defesa.
- **Banco de Dados Local**: Integração com `Sqflite` para persistir o progresso e os status do herói localmente, sem necessidade de internet.
- **Assets Originais**: Cenário medieval e sprites (personagem) gerados por IA, garantindo uma temática coesa e autoral.

---

## 🛠️ Tecnologias Utilizadas

- [**Flutter**](https://flutter.dev/): Framework UI criado pelo Google.
- [**Flame Engine**](https://flame-engine.org/): Motor de jogos 2D poderoso, otimizado e modular feito para o Flutter.
- [**Sqflite**](https://pub.dev/packages/sqflite): Banco de dados SQLite relacional para salvar o estado (saves) do jogo.
- [**Shared Preferences**](https://pub.dev/packages/shared_preferences): Para configurações rápidas de usuário (volume, linguagem, etc).

---

## 🎮 Como Jogar e Executar

Este projeto requer o SDK do Flutter instalado na sua máquina. Siga os passos abaixo para testar localmente:

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
- Emulador Android / iOS configurado ou navegador ativo para debug.

### Rodando o projeto

1. **Clone o repositório**
   ```bash
   git clone https://github.com/allisonthiago/game_2d.git
   ```

2. **Acesse a pasta do projeto**
   ```bash
   cd game_2d
   ```

3. **Instale as dependências**
   ```bash
   flutter pub get
   ```

4. **Execute o jogo**
   ```bash
   flutter run
   ```
   > **Dica**: No VS Code ou Android Studio, basta abrir a pasta e pressionar `F5` para debugar.

---

## 📱 Gerando APK (Para Celulares Android)

Para gerar a build de produção (APK) e instalar diretamente no seu celular Android:

1. Certifique-se de que possui o **Android Studio** e o **Android SDK** corretamente configurados nas variáveis de ambiente.
2. No terminal do projeto, execute:
   ```bash
   flutter build apk
   ```
3. O arquivo compilado estará disponível em: `build/app/outputs/flutter-apk/app-release.apk`. Você pode copiar este arquivo para o celular e instalar.

---

## 📂 Estrutura do Projeto

A arquitetura das pastas foi pensada para isolar a lógica do motor Flame do resto do app:

```text
lib/
 ├── components/       # Atores do jogo (Player, Inimigos, Joysticks) e Status de RPG
 ├── database/         # Script de inicialização do SQLite e helpers
 ├── game/             # Classe central MyGame (herdada de FlameGame) que gerencia tudo
 └── main.dart         # Ponto de entrada padrão do Flutter (inicia a tela e o banco)
assets/
 └── images/           # Cenários, Sprites e ícones
```

---

## 🤝 Próximos Passos (Roadmap)
- [ ] Adicionar Inimigos com Inteligência Artificial (Follower).
- [ ] Implementar sistema de dano e barra de vida na tela (HUD).
- [ ] Criar paredes e colisões nos limites do cenário.
- [ ] Adicionar sistema de inventário básico.

---

*Desenvolvido em parceria com Antigravity (AI).*
