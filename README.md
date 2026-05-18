# FitStart

FitStart é um app Flutter para quem quer começar a criar hábitos fitness sem complicar. A proposta é simples: abrir o app, entrar com seus dados, acompanhar a rotina de treino e ter um espaço curto de orientação para manter a consistência no dia a dia.

O projeto combina autenticação local com SQLite, sessão salva no dispositivo, tela inicial com acompanhamento de hábitos e um fluxo de treino com cronômetro em segundo plano. Também há integração com IA para devolver um feedback rápido após o treino.

## Visão geral

O app foi desenhado para ser direto e leve, com foco em três frentes:

- Entrada e cadastro de usuário com validações básicas
- Painel principal com hábitos, água, treino e foto de perfil
- Conteúdo educativo para quem está começando

A interface segue um tema escuro com destaque em verde neon, priorizando contraste e leitura. A navegação é curta e intencional: login, home, cadastro e uma tela de apoio com dicas.

## O que o app faz hoje

- Login com validação de e-mail e senha
- Cadastro local de usuário
- Sessão persistida com `SharedPreferences`
- Banco local com SQLite para autenticação e dados do perfil
- Tela inicial com saudação, frase do dia, hábitos e meta de água
- Troca de foto de perfil pela câmera ou galeria
- Cronômetro de treino rodando em serviço de fundo no Android
- Geração de feedback de IA ao encerrar o treino
- Registro do histórico do coach em arquivo local
- Tela `Saiba Mais` com dicas práticas para iniciantes

## Fluxo do aplicativo

1. O app abre na tela de login.
2. O usuário pode entrar com uma conta já cadastrada ou criar um novo cadastro.
3. Quando o login é validado, a sessão fica salva no dispositivo.
4. Na próxima abertura, o app pode ir direto para a Home se houver sessão ativa.
5. Na Home, o usuário acompanha hábitos, água, perfil e treino.
6. Ao iniciar e encerrar o treino, o cronômetro roda em segundo plano e o app gera feedback de IA.
7. A tela `Saiba Mais` reúne orientações simples sobre constância, alimentação, hidratação e descanso.

## Estrutura do projeto

```text
lib/
	main.dart
	database/
		db_helper.dart
	models/
		user_model.dart
	screens/
		home_screen.dart
		login_screen.dart
		register_user_screen.dart
		saiba_mais_screen.dart
	services/
		ai_handler.dart
		auth_service.dart
		background_service.dart
		file_service.dart
		image_service.dart
	theme/
		app_theme.dart
test/
	widget_test.dart
web/
	index.html
	manifest.json
	icons/
```

### Arquivos principais

- [lib/main.dart](lib/main.dart): ponto de entrada do app, lê a sessão salva e decide entre Login e Home.
- [lib/screens/login_screen.dart](lib/screens/login_screen.dart): autenticação com validação e persistência de sessão.
- [lib/screens/register_user_screen.dart](lib/screens/register_user_screen.dart): cadastro local de novos usuários.
- [lib/screens/home_screen.dart](lib/screens/home_screen.dart): painel principal com hábitos, água, treino, foto e ações do usuário.
- [lib/screens/saiba_mais_screen.dart](lib/screens/saiba_mais_screen.dart): tela educativa com dicas para iniciantes.
- [lib/database/db_helper.dart](lib/database/db_helper.dart): camada de acesso ao SQLite.
- [lib/theme/app_theme.dart](lib/theme/app_theme.dart): cores, botões, campos e demais padrões visuais.

## Tecnologias e pacotes

- Flutter
- Dart
- Material Design
- SQLite com `sqflite`
- `shared_preferences` para sessão local
- `flutter_background_service` para o cronômetro em segundo plano
- `flutter_local_notifications` para a notificação do serviço
- `image_picker` e `path_provider` para foto de perfil
- `http` para a integração com API externa/IA

## Requisitos

- Flutter SDK instalado
- Dart SDK compatível com Flutter
- Android Studio, VS Code ou outro editor com suporte a Flutter
- Emulador Android/iOS ou dispositivo físico

Observação: o cronômetro em segundo plano foi implementado para Android. Em outras plataformas, o comportamento pode variar conforme o suporte do sistema e dos pacotes usados.

## Como executar

1. Clone o repositório.
2. Entre na pasta do projeto.
3. Instale as dependências:

```bash
flutter pub get
```

4. Rode o app:

```bash
flutter run
```

### Executar no navegador

```bash
flutter run -d chrome
```

## Scripts úteis

```bash
flutter analyze
flutter test
flutter clean
flutter pub get
```

## Configuração importante

O arquivo [lib/services/ai_handler.dart](lib/services/ai_handler.dart) contém a chave da API usada para gerar o feedback de treino. Antes de publicar ou compartilhar o projeto, revise esse ponto e mova a credencial para um local mais seguro.

Se você for testar o login com a integração externa prevista no código, confira também as credenciais esperadas no serviço de autenticação e os dados já salvos no SQLite local.

## Layout e tema

O visual do FitStart usa uma base escura com verde neon para reforçar o clima de foco e energia sem exagero.

- Fundo principal escuro
- Superfícies em cinza grafite
- Destaques em verde neon
- Tipografia com hierarquia clara
- Botões, cartões e campos padronizados no tema global

Toda a configuração visual fica centralizada em [lib/theme/app_theme.dart](lib/theme/app_theme.dart), o que facilita ajustes sem espalhar estilos pelas telas.

## Melhorias previstas

- Integrar autenticação real com backend próprio
- Melhorar o histórico de treinos e metas
- Evoluir o acompanhamento de progresso do usuário
- Adicionar notificações de lembrete mais completas
- Criar suporte a internacionalização
- Expandir a cobertura de testes

## Contribuição

Se quiser contribuir, siga este fluxo:

1. Crie uma branch para a sua mudança.
2. Faça a implementação com a menor alteração necessária.
3. Rode `flutter analyze` e `flutter test`.
4. Abra um pull request com uma descrição objetiva do que mudou.
