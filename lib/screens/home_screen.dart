import 'package:flutter/material.dart';
import 'dart:math';
import 'package:projeto_flutter/theme/app_theme.dart';
import 'package:projeto_flutter/database/db_helper.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- ESTADO E NAVEGAÇÃO ---
  int _currentIndex = 0;
  final ValueNotifier<String> _userNameNotifier = ValueNotifier<String>("...");

  // --- FRASE MOTIVACIONAL ---
  final List<String> _frases = [
    "Sabe onde ela está agora?!!",
    "Vai fazer o minímo? igual ela fez por você?!!",
    "Críticar é facil, dificíl é te elogiar.",
  ];
  String _fraseDoDia = "";

  // --- ÁGUA E HÁBITOS ---
  int _mlConsumidos = 0;
  final int _metaAgua = 2000;
  final Map<String, bool> _habitsChecked = {
    'Treino na academia': false,
    'Alimentação saudável': false,
    'Dormir bem': false,
  };

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _fraseDoDia = _frases[Random().nextInt(_frases.length)];
  }

  Future<void> _loadInitialData() async {
    final name = await DbHelper().getLastName();
    _userNameNotifier.value = name;
  }

  // --- CÁLCULO DE XP (PONTOS REAIS) ---
  int _calculateCurrentXP() {
    int habitXP = _habitsChecked.values.where((v) => v).length * 100;
    int waterXP = (_mlConsumidos >= _metaAgua) ? 100 : 0;
    return habitXP + waterXP;
  }

  int _calculateTotalPossibleXP() => (_habitsChecked.length + 1) * 100;

  // --- FUNÇÕES CRUD (PERFIL) ---
  void _showEditNameDialog() {
    final controller = TextEditingController(text: _userNameNotifier.value);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Editar Nome', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Novo Nome',
            labelStyle: TextStyle(color: AppTheme.neonGreen),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.neonGreen)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await DbHelper().updateUserName(controller.text);
                _userNameNotifier.value = controller.text;
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Excluir Conta',
            style: TextStyle(color: Colors.redAccent)),
        content:
            const Text('Ação irreversível. Deseja apagar todos os seus dados?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await DbHelper().deleteUser(1); // Exclui o ID 1 do SQLite
              if (!mounted) return;
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      _buildHomeContent(),
      const Center(
          child: Text("Treinos",
              style: TextStyle(color: AppTheme.neonGreen, fontSize: 18))),
      _buildProfileContent(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitStart'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.neonGreen),
              onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.neonGreen,
        unselectedItemColor: AppTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'Treinos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  // --- CONTEÚDO DA HOME ---
  Widget _buildHomeContent() {
    int currentXP = _calculateCurrentXP();
    int totalXP = _calculateTotalPossibleXP();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildWelcomeBanner(currentXP, totalXP)),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 12, 25, 0),
            child: Text("\"$_fraseDoDia\"",
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                    fontSize: 13)),
          ),
          const SizedBox(height: 24),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildWaterTracker()),
          const SizedBox(height: 24),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Hábitos de Hoje',
                  style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _habitsChecked.keys
                  .map((title) => _buildHabitCarouselItem(
                        title: title,
                        isChecked: _habitsChecked[title]!,
                        onTap: () => setState(() =>
                            _habitsChecked[title] = !_habitsChecked[title]!),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        value: '0',
                        label: 'Treinos')),
                const SizedBox(width: 14),
                Expanded(
                    child: _buildStatCard(
                        icon: Icons.calendar_today, value: '0', label: 'Dias')),
                const SizedBox(width: 14),
                Expanded(
                    child: _buildStatCard(
                        icon: Icons.emoji_events, value: '0', label: 'Metas')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CONTEÚDO DO PERFIL (AQUI ESTÁ O QUE FALTAVA) ---
  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar com borda neon
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.neonGreen, width: 2)),
              child: const CircleAvatar(
                  radius: 55,
                  backgroundColor: AppTheme.cardColor,
                  child:
                      Icon(Icons.person, size: 65, color: AppTheme.neonGreen)),
            ),
          ),
          const SizedBox(height: 30),
          // Info Tile com ValueNotifier para atualizar o nome em tempo real
          ValueListenableBuilder(
            valueListenable: _userNameNotifier,
            builder: (context, name, _) =>
                _buildProfileInfoCard("Usuário FitStart", name, Icons.badge),
          ),
          const SizedBox(height: 40),
          // Botões do CRUD
          _buildActionCard(
            title: "Editar Dados",
            desc: "Alterar o seu nome no sistema",
            icon: Icons.edit,
            color: Colors.orangeAccent,
            onTap: _showEditNameDialog,
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            title: "Excluir Conta",
            desc: "Remover permanentemente os seus dados",
            icon: Icons.delete_forever,
            color: Colors.redAccent,
            onTap: _showDeleteDialog,
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES (MODULARIZADOS) ---

  Widget _buildWelcomeBanner(int currentXP, int totalXP) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3))),
      child: Column(children: [
        Row(children: [
          const CircleAvatar(
              backgroundColor: AppTheme.cardColor,
              child: Icon(Icons.bolt, color: AppTheme.neonGreen)),
          const SizedBox(width: 12),
          Expanded(
              child: ValueListenableBuilder(
                  valueListenable: _userNameNotifier,
                  builder: (context, name, _) => Text('E aí, $name!',
                      style: Theme.of(context).textTheme.titleLarge))),
        ]),
        const SizedBox(height: 20),
        LinearProgressIndicator(
            value: currentXP / totalXP,
            backgroundColor: Colors.white10,
            color: AppTheme.neonGreen,
            minHeight: 10),
        const SizedBox(height: 8),
        Align(
            alignment: Alignment.centerRight,
            child: Text("$currentXP / $totalXP XP",
                style: const TextStyle(
                    color: AppTheme.neonGreen, fontWeight: FontWeight.bold))),
      ]),
    );
  }

  Widget _buildWaterTracker() {
    double aguaPercent = _mlConsumidos / _metaAgua;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3))),
      child: Row(children: [
        const Icon(Icons.water_drop, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("$_mlConsumidos/$_metaAgua ml",
              style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
              value: aguaPercent > 1.0 ? 1.0 : aguaPercent,
              backgroundColor: Colors.white10,
              color: Colors.blueAccent),
        ])),
        IconButton(
            onPressed: () {
              if (_mlConsumidos >= 250) setState(() => _mlConsumidos -= 250);
            },
            icon: const Icon(Icons.remove_circle_outline,
                color: Colors.redAccent)),
        IconButton(
            onPressed: () => setState(() => _mlConsumidos += 250),
            icon: const Icon(Icons.add_circle, color: Colors.blueAccent)),
      ]),
    );
  }

  Widget _buildProfileInfoCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10)),
      child: Row(children: [
        Icon(icon, color: AppTheme.textSecondary),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }

  Widget _buildActionCard(
      {required String title,
      required String desc,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3))),
      child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: color, size: 28),
          title: Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(desc,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12))),
    );
  }

  Widget _buildHabitCarouselItem(
      {required String title,
      required bool isChecked,
      required VoidCallback onTap}) {
    return Container(
      width: 240,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: isChecked
            ? AppTheme.neonGreen.withOpacity(0.05)
            : AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: isChecked ? AppTheme.neonGreen : Colors.white10)),
        child: ListTile(
          onTap: onTap,
          title: Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  decoration: isChecked ? TextDecoration.lineThrough : null)),
          trailing: Icon(isChecked ? Icons.check_circle : Icons.circle_outlined,
              color: isChecked ? AppTheme.neonGreen : AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      {required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Icon(icon, color: AppTheme.neonGreen, size: 28),
        Text(value,
            style: const TextStyle(
                color: AppTheme.neonGreen,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ]),
    );
  }
}
