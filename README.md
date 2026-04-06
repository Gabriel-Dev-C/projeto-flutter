# FitStart (README RASCUNHO)

Aplicativo Flutter voltado para iniciantes que desejam construir habitos fitness com consistencia. O projeto apresenta uma experiencia simples e direta, com autenticacao simulada, painel inicial e uma secao educativa com dicas praticas para treino, alimentacao, hidratacao e descanso.

## Sumario

1. Visao geral
2. Funcionalidades
3. Fluxo do aplicativo
4. Estrutura do projeto
5. Tecnologias
6. Requisitos
7. Como executar
8. Scripts uteis
9. Padroes de UI e tema
10. Melhorias planejadas
11. Contribuicao
12. Licenca

## Visao geral

O FitStart foi pensado para ser um ponto de partida para quem esta comecando na academia e quer manter disciplina no dia a dia. A aplicacao foca em:

- Interface visual em tema escuro com destaque neon
- Navegacao objetiva entre login, home e conteudo educativo
- Validacoes basicas de formulario
- Estrutura limpa para evolucao futura (estado real, backend, persistencia)

## Funcionalidades

- Login com validacao de e-mail e senha
- Simulacao de carregamento ao entrar
- Tela inicial com:
	- Cartao de boas-vindas
	- Cards de estatisticas (treinos, dias, metas)
	- Lista de habitos recomendados
- Navegacao para tela Saiba Mais com dicas para iniciantes
- Acao de sair com confirmacao em dialog
- Tema centralizado para padronizacao visual

## Fluxo do aplicativo

1. O app inicia na tela de login.
2. O usuario informa e-mail e senha.
3. Com dados validos, ocorre uma simulacao de carregamento.
4. O usuario e redirecionado para a tela Home.
5. Na Home, pode acessar o conteudo de orientacao em Saiba Mais.
6. O usuario pode encerrar sessao pela acao de sair.

## Estrutura do projeto

```text
lib/
	main.dart
	screens/
		login_screen.dart
		home_screen.dart
		saiba_mais_screen.dart
	theme/
		app_theme.dart
test/
	widget_test.dart
web/
	index.html
	manifest.json
	icons/
```

### Principais arquivos

- lib/main.dart: ponto de entrada, inicializa o app e aplica o tema global.
- lib/screens/login_screen.dart: formulario de login com validacoes e navegacao para Home.
- lib/screens/home_screen.dart: painel principal com habitos e acoes de navegacao/logoff.
- lib/screens/saiba_mais_screen.dart: conteudo educativo para iniciantes.
- lib/theme/app_theme.dart: configuracao de cores, tipografia e componentes visuais.

## Tecnologias

- Flutter
- Dart
- Material Design (widgets nativos do Flutter)

## Requisitos

- Flutter SDK instalado
- Dart SDK (incluido com Flutter)
- Android Studio, VS Code ou outro editor com suporte Flutter
- Emulador Android/iOS ou dispositivo fisico

## Como executar

1. Clone o repositorio.
2. Entre na pasta do projeto.
3. Instale as dependencias:

```bash
flutter pub get
```

4. Rode o aplicativo:

```bash
flutter run
```

### Executar no navegador

```bash
flutter run -d chrome
```

## Scripts uteis

```bash
flutter analyze
flutter test
flutter clean
flutter pub get
```

## Padroes de UI e tema

O projeto utiliza um tema escuro centralizado com destaque em verde neon para reforcar identidade visual e contraste:

- Cor de destaque: neonGreen
- Fundo principal: darkBackground
- Superficies: surfaceColor e cardColor
- Tipografia com hierarquia para titulos e textos de apoio
- Componentes padronizados: botoes, campos de entrada, cards e app bar

Toda a configuracao visual fica em lib/theme/app_theme.dart, facilitando manutencao e evolucao do design.

## Melhorias planejadas

- Integrar autenticacao real
- Persistir dados de habitos e progresso
- Adicionar acompanhamento de metas com historico
- Incluir notificacoes para lembretes diarios
- Criar suporte a internacionalizacao
- Aumentar cobertura de testes automatizados

## Contribuicao

Contribuicoes sao bem-vindas. Sugestoes de melhoria, correcoes e novas funcionalidades podem ser enviadas via issue ou pull request.

Passos recomendados:

1. Crie uma branch para sua feature/correcao.
2. Implemente e teste localmente.
3. Rode analise estatica e testes.
4. Abra um pull request com descricao clara.

## Licenca

Defina aqui a licenca do projeto (por exemplo: MIT) conforme a necessidade do repositorio.
