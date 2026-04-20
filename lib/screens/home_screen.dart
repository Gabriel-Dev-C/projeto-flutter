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
  // --- CONTROLE DE ESTADO E NAVEGAÇÃO ---
  int _currentIndex = 0;
  final ValueNotifier<String> _userNameNotifier = ValueNotifier<String>("...");

  // --- LÓGICA DA FRASE (TÓXICA) ---
  final List<String> _frases = [
    "Sabe onde ela tá agora?!!",
    "Vai fazer o mínimo? igual ela fez por você?!!",
    "Criticar é fácil, difícil é te elogiar.",
    "Enquanto você perde tempo lendo isso, tem nego ocupado com ela!!",
  ];
  String _fraseDoDia = "";

  // --- LÓGICA DA ÁGUA ---
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

  int _calculateCurrentXP() {
    int habitXP = _habitsChecked.values.where((v) => v).length * 100;
    int waterXP = (_mlConsumidos >= _metaAgua) ? 100 : 0;
    return habitXP + waterXP;
  }

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

  // --- CRUD: DELETE (EXCLUIR CONTA) ---
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Excluir Conta',
            style: TextStyle(color: Colors.redAccent)),
        content:
            const Text('Esta ação é irreversível. Deseja apagar seus dados?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await DbHelper().deleteUser(1); // Exclui ID 1
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
    int currentXP = _calculateCurrentXP();
    int totalXP = (_habitsChecked.length + 1) * 100;

    final List<Widget> _screens = [
      _buildHomeContent(currentXP, totalXP),
      const Center(
          child: Text("Treinos",
              style: TextStyle(color: AppTheme.neonGreen, fontSize: 18))),
      _buildProfileContent(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 2 ? 'Meu Perfil' : 'FitStart'),
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

  // --- ABA 0: HOME ---
  Widget _buildHomeContent(int currentXP, int totalXP) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildWelcomeBanner(currentXP, totalXP)),
          _buildQuoteCard(),
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
          _buildHabitCarousel(),
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

  // --- ABA 2: PERFIL (ESTILIZADA COM CRUD) ---
  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.neonGreen, width: 2)),
              child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.cardColor,
                  child:
                      Icon(Icons.person, size: 60, color: AppTheme.neonGreen)),
            ),
          ),
          const SizedBox(height: 30),
          ValueListenableBuilder(
            valueListenable: _userNameNotifier,
            builder: (context, name, _) => _buildInfoTile(
                label: "Nome de Usuário", value: name, icon: Icons.badge),
          ),
          const SizedBox(height: 40),
          _buildActionCard(
              title: "Editar Dados",
              desc: "Atualizar seu nome no banco",
              icon: Icons.edit,
              color: Colors.orangeAccent,
              onTap: _showEditNameDialog),
          const SizedBox(height: 16),
          _buildActionCard(
              title: "Excluir Conta",
              desc: "Remover dados permanentemente",
              icon: Icons.delete_forever,
              color: Colors.redAccent,
              onTap: _showDeleteDialog),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildQuoteCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neonGreen.withOpacity(0.1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: AppTheme.neonGreen, size: 16),
          SizedBox(width: 8),
          Text("AVISO DE FOCO",
              style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
        ]),
        const SizedBox(height: 10),
        Text("\"$_fraseDoDia\"",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontStyle: FontStyle.italic)),
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

  Widget _buildHabitCarousel() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
          children: _habitsChecked.keys
              .map((title) => Container(
                    width: 220,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      color: _habitsChecked[title]!
                          ? AppTheme.neonGreen.withOpacity(0.05)
                          : AppTheme.surfaceColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              color: _habitsChecked[title]!
                                  ? AppTheme.neonGreen
                                  : Colors.white10)),
                      child: ListTile(
                        onTap: () => setState(() =>
                            _habitsChecked[title] = !_habitsChecked[title]!),
                        title: Text(title,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                        trailing: Icon(
                            _habitsChecked[title]!
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: _habitsChecked[title]!
                                ? AppTheme.neonGreen
                                : AppTheme.textSecondary),
                      ),
                    ),
                  ))
              .toList()),
    );
  }

  Widget _buildWelcomeBanner(int cur, int tot) {
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
            value: cur / tot,
            backgroundColor: Colors.white10,
            color: AppTheme.neonGreen,
            minHeight: 10),
        const SizedBox(height: 8),
        Align(
            alignment: Alignment.centerRight,
            child: Text("$cur / $tot XP",
                style: const TextStyle(
                    color: AppTheme.neonGreen, fontWeight: FontWeight.bold))),
      ]),
    );
  }

  Widget _buildStatCard(
      {required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neonGreen.withOpacity(0.1))),
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

  Widget _buildActionCard(
      {required String title,
      required String desc,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3))),
      child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: color),
          title: Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(desc,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12))),
    );
  }

  Widget _buildInfoTile(
      {required String label, required String value, required IconData icon}) {
    return Container(
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }
}
