import 'package:flutter/material.dart';
import 'package:projeto_flutter/theme/app_theme.dart';
import 'login_screen.dart';
import 'saiba_mais_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleLogoff(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Sair',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Deseja realmente sair da sua conta?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('SAIR'),
          ),
        ],
      ),
    );
  }

  void _navigateToSaibaMais(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SaibaMaisScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitStart'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout, color: AppTheme.neonGreen),
            onPressed: () => _handleLogoff(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.neonGreen.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.neonGreen,
                        width: 2,
                      ),
                      color: AppTheme.cardColor,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.neonGreen,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bem-vindo(a)!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pronto para mais um treino?',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Sua Jornada',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Stats cards row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.local_fire_department,
                    value: '0',
                    label: 'Treinos',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.calendar_today,
                    value: '0',
                    label: 'Dias',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.emoji_events,
                    value: '0',
                    label: 'Metas',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Text(
              'Hábitos de Hoje',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            _buildHabitItem(
              context,
              icon: Icons.fitness_center,
              title: 'Treino na academia',
              subtitle: 'Mantenha a consistência!',
            ),
            const SizedBox(height: 12),
            _buildHabitItem(
              context,
              icon: Icons.water_drop,
              title: 'Hidratação diária',
              subtitle: '8 copos de água por dia',
            ),
            const SizedBox(height: 12),
            _buildHabitItem(
              context,
              icon: Icons.restaurant_menu,
              title: 'Alimentação saudável',
              subtitle: 'Proteínas e vegetais no prato',
            ),
            const SizedBox(height: 12),
            _buildHabitItem(
              context,
              icon: Icons.bed,
              title: 'Dormir bem',
              subtitle: '7-9 horas de sono reparador',
            ),
            const SizedBox(height: 32),

            // Saiba Mais button
            OutlinedButton.icon(
              onPressed: () => _navigateToSaibaMais(context),
              icon: const Icon(Icons.info_outline),
              label: const Text('SAIBA MAIS'),
            ),
            const SizedBox(height: 14),

            // Logoff button
            ElevatedButton.icon(
              onPressed: () => _handleLogoff(context),
              icon: const Icon(Icons.logout),
              label: const Text('SAIR DA CONTA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.neonGreen, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.neonGreen,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.neonGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.neonGreen, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: const Icon(
          Icons.check_circle_outline,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
