import 'package:flutter/material.dart';
import 'package:projeto_flutter/theme/app_theme.dart';
import 'package:projeto_flutter/database/db_helper.dart';
import 'package:projeto_flutter/services/auth_service.dart'; // Certifique-se de criar este arquivo
import 'home_screen.dart';
import 'register_user_screen.dart';

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

  // --- LÓGICA DE LOGIN COM JWT (CHECKPOINT 1) ---
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. TENTA AUTENTICAÇÃO JWT (API EXTERNA)
      // Dica para teste: e-mail "eve.holt@reqres.in" funciona sempre nesta API
      String? token = await AuthService().login(
        _emailController.text,
        _passwordController.text,
      );

      if (token != null) {
        // SUCESSO NO JWT
        debugPrint("---------------------------------");
        debugPrint("TOKEN JWT RECEBIDO: $token");
        debugPrint("---------------------------------");

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        // 2. SE FALHAR NA API, TENTA NO BANCO LOCAL (SQLITE)
        // Isso garante que seus usuários cadastrados offline ainda entrem
        bool loginLocalSucesso = await DbHelper().checkLogin(
          _emailController.text,
          _passwordController.text,
        );

        setState(() => _isLoading = false);

        if (loginLocalSucesso) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('E-mail ou senha inválidos (API & Local)!'),
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
                        color: AppTheme.neonGreen.withOpacity(0.2),
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
