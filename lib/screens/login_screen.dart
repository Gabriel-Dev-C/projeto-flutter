import 'package:flutter/material.dart';
import 'package:projeto_flutter/theme/app_theme.dart';
import 'package:projeto_flutter/database/db_helper.dart';
import 'package:projeto_flutter/services/auth_service.dart';
import '../models/user_model.dart'; // Garanta que o caminho para o seu User model está correto
import 'home_screen.dart';
import 'register_user_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String emailDigitado = _emailController.text.trim().toLowerCase();
      String senhaDigitada = _passwordController.text;

      // 1. TENTA AUTENTICAÇÃO JWT (API EXTERNA)
      String? token = await AuthService().login(
        emailDigitado,
        senhaDigitada,
      );

      // TRAVA DE SEGURANÇA MÁXIMA CONTRA A API MOCK QUE ACEITA QUALQUER COISA:
      if (emailDigitado == "eve.holt@reqres.in") {
        // Se for o e-mail da API, a senha precisa ser a correta dela
        if (senhaDigitada != "cityslick") {
          token = null;
        }
      } else {
        // O PULO DO GATO: Se for QUALQUER outro e-mail (ex: matheus@teste.com),
        // nós desconsideramos o token falso da API para forçar a validação real no SQLite!
        token = null;
      }

      if (token != null) {
        // CASO A: SUCESSO EXCLUSIVO NA API EXTERNA 
        debugPrint("---------------------------------");
        debugPrint("TOKEN JWT RECEBIDO: $token");
        debugPrint("---------------------------------");

        String nomeDoBanco = await DbHelper().getUserNameByEmail(emailDigitado);

        if (nomeDoBanco == "Recruta") {
          String nomeGerado = emailDigitado.split('@')[0];

          await DbHelper().insertUser(User(
            name: nomeGerado,
            email: emailDigitado,
            password: senhaDigitada,
          ));
          debugPrint("Usuário da API registrado no SQLite como: $nomeGerado");
        }

        //  GRAVA A SESSÃO PARA O LOGIN AUTOMÁTICO
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', emailDigitado);

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomeScreen(userEmail: emailDigitado),
            ),
          );
        }
      } else {
        //  CASO B: VALIDAÇÃO REAL E RÍGIDA NO SQLITE LOCAL 
        debugPrint("Verificando credenciais no SQLite local...");

        bool loginLocalSucesso = await DbHelper().checkLogin(
          emailDigitado,
          senhaDigitada,
        );

        setState(() => _isLoading = false);

        if (loginLocalSucesso) {
          // GRAVA A SESSÃO PARA O LOGIN AUTOMÁTICO NO LOGIN LOCAL TAMBÉM
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_email', emailDigitado);

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => HomeScreen(userEmail: emailDigitado),
              ),
            );
          }
        } else {
          // SE NÃO PASSAR NO BANCO LOCAL, BLOQUEIA DE VERDADE!
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('E-mail ou senha inválidos!'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Erro no login: $e");
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterUserScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Neon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.neonGreen, width: 2.5),
                    color: AppTheme.surfaceColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonGreen.withValues(alpha: 0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: AppTheme.neonGreen,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'FitStart',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sua jornada Cyberpunk começa aqui',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 48),

                // Formulário
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppTheme.neonGreen),
                        ),
                        validator: (value) =>
                            (value == null || !value.contains('@'))
                                ? 'E-mail inválido'
                                : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppTheme.neonGreen),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) =>
                            (value == null || value.length < 6)
                                ? 'Mínimo 6 caracteres'
                                : null,
                      ),
                      const SizedBox(height: 36),

                      // Botão de Login com Loading
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: AppTheme.neonGreen))
                            : ElevatedButton.icon(
                                onPressed: _handleLogin,
                                icon: const Icon(Icons.bolt),
                                label: const Text('ENTRAR NO SISTEMA'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.neonGreen,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Novo por aqui?',
                style: TextStyle(color: AppTheme.textSecondary)),
            TextButton(
              onPressed: _navigateToRegister,
              child: const Text(
                'Cadastre-se',
                style: TextStyle(
                    color: AppTheme.neonGreen, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
