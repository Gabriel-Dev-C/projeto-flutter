import 'package:flutter/material.dart';
import 'package:projeto_flutter/theme/app_theme.dart';
import 'home_screen.dart';
import 'register_user_screen.dart';
import 'package:projeto_flutter/database/db_helper.dart';

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

    // 1. CONSULTAR O BANCO (Ação de leitura do CRUD)
    bool loginSucesso = await DbHelper().checkLogin(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (loginSucesso) {
      // Se o banco retornou true, vai pra Home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // Se não encontrou no banco, avisa o erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail ou senha não cadastrados!')),
      );
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
                // Logo / Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.neonGreen, width: 2.5),
                    color: AppTheme.surfaceColor,
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: AppTheme.neonGreen,
                  ),
                ),
                const SizedBox(height: 24),

                // App name
                Text(
                  'FitStart',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Comece sua jornada fitness',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 48),

                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          hintText: 'seu@email.com',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppTheme.neonGreen,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe seu e-mail';
                          }
                          if (!value.contains('@')) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          hintText: '••••••••',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppTheme.neonGreen,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe sua senha';
                          }
                          if (value.length < 6) {
                            return 'A senha deve ter ao menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 36),

                      // Login button
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: AppTheme.neonGreen,
                            )
                          : ElevatedButton.icon(
                              onPressed: _handleLogin,
                              icon: const Icon(Icons.login),
                              label: const Text('ENTRAR'),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // --- BOTÃO DE REGISTRO FIXO NO RODAPÉ ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Não tem uma conta?',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            TextButton(
              onPressed: _navigateToRegister,
              child: const Text(
                'Cadastre-se',
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
