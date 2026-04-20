import 'package:flutter/material.dart';
import 'package:projeto_flutter/theme/app_theme.dart';
import 'package:projeto_flutter/models/user_model.dart';
import 'package:projeto_flutter/database/db_helper.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Função para salvar no banco
  void _register() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validação básica
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem!')),
      );
      return;
    }

    // 1. Criar o objeto User
    User novoUsuario = User(
      name: name,
      email: email,
      password: password,
    );

    // 2. MANDAR PRO BANCO REAL
    await DbHelper().insertUser(novoUsuario);

    // 3. Feedback e Navegação
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
    );

    Navigator.pop(context); // Volta para a tela de Login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Cadastro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_add, size: 80, color: AppTheme.neonGreen),
            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nome de Usuário',
                prefixIcon:
                    Icon(Icons.person_outline, color: AppTheme.neonGreen),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon:
                    Icon(Icons.email_outlined, color: AppTheme.neonGreen),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock_outline, color: AppTheme.neonGreen),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Confirmar Senha',
                prefixIcon: Icon(Icons.lock_reset, color: AppTheme.neonGreen),
              ),
            ),
            const SizedBox(height: 32),

            // Botão Salvar CORRIGIDO
            ElevatedButton(
              onPressed: _register,
              child: const Text('CRIAR CONTA'),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCELAR',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
