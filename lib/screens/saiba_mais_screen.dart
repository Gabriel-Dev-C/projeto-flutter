import 'package:flutter/material.dart';
import 'package:projeto_flutter/theme/app_theme.dart';

class SaibaMaisScreen extends StatelessWidget {
  const SaibaMaisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saiba Mais'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.neonGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.neonGreen, width: 1),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 60,
                    color: AppTheme.neonGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Por que criar hábitos fitness?',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hábitos consistentes são a base de qualquer transformação física. '
                    'Pequenas ações diárias geram grandes resultados ao longo do tempo.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Dicas para Iniciantes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            _buildTipCard(
              context,
              icon: Icons.schedule,
              title: 'Comece devagar',
              description:
                  'Inicie com treinos de 3x por semana e aumente a frequência '
                  'progressivamente. Consistência é mais importante do que intensidade no início.',
            ),
            const SizedBox(height: 14),

            _buildTipCard(
              context,
              icon: Icons.restaurant_menu,
              title: 'Alimentação equilibrada',
              description:
                  'Uma dieta balanceada é fundamental para o progresso. '
                  'Priorize proteínas, carboidratos complexos e gorduras saudáveis.',
            ),
            const SizedBox(height: 14),

            _buildTipCard(
              context,
              icon: Icons.water_drop,
              title: 'Hidratação',
              description: 'Beba pelo menos 2 litros de água por dia. '
                  'Durante os treinos, mantenha-se hidratado para garantir melhor desempenho.',
            ),
            const SizedBox(height: 14),

            _buildTipCard(
              context,
              icon: Icons.bed,
              title: 'Descanso e recuperação',
              description:
                  'O músculo cresce durante o descanso. Durma de 7 a 9 horas por noite '
                  'e respeite os dias de recuperação entre os treinos.',
            ),
            const SizedBox(height: 14),

            _buildTipCard(
              context,
              icon: Icons.trending_up,
              title: 'Acompanhe seu progresso',
              description: 'Registre seus treinos, peso e medidas. '
                  'Ver a evolução ao longo do tempo é o maior motivador para continuar.',
            ),
            const SizedBox(height: 28),

            // CTA section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Pronto para começar?',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Volte para a tela principal e comece sua jornada hoje mesmo!',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('VOLTAR'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.neonGreen, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
