import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🔥 Import necessário
import 'package:projeto_flutter/theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart'; // 🔥 Import necessário para abrir a Home direto

void main() async {
  // 1. Garante que os recursos nativos do emulador estejam prontos antes de ler a memória
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Abre o armazenamento local e checa se existe um e-mail salvo
  final prefs = await SharedPreferences.getInstance();
  String? emailLogado = prefs.getString('user_email');

  debugPrint("=========================================");
  debugPrint("SESSÃO ATIVA ENCONTRADA: $emailLogado");
  debugPrint("=========================================");

  // 3. Passa o e-mail encontrado (ou null) para dentro do Widget principal
  runApp(FitStartApp(emailLogado: emailLogado));
}

class FitStartApp extends StatelessWidget {
  final String? emailLogado;

  // 🔥 Atualizado o construtor para receber a sessão salva
  const FitStartApp({super.key, this.emailLogado});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitStart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // 🔥 O PULO DO GATO: Se tiver e-mail salvo, abre direto na Home carregando ele.
      // Se estiver vazio (null), abre a tela de Login normal.
      home: (emailLogado != null && emailLogado!.isNotEmpty)
          ? HomeScreen(userEmail: emailLogado!)
          : const LoginScreen(),
    );
  }
}
