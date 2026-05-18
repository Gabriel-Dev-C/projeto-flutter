import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:projeto_flutter/theme/app_theme.dart';
import 'package:projeto_flutter/database/db_helper.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:projeto_flutter/services/background_service.dart';
import 'package:projeto_flutter/services/ai_handler.dart';
import 'package:projeto_flutter/services/file_service.dart';
import 'package:projeto_flutter/services/image_service.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail; // Recebe o e-mail do usuário logado
  const HomeScreen({super.key, required this.userEmail});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ValueNotifier<String> _userNameNotifier = ValueNotifier<String>("...");
  String? _fotoPerfilPath;

  bool _isTrainingActive = false;
  String _stopwatchDisplay = "00:00";

  final List<String> _frases = [
    "Sabe onde ela tá agora?!!",
    "Vai fazer o mínimo? igual ela fez por você?!!",
    "Criticar é fácil, difícil é te elogiar.",
    "Enquanto você perde tempo lendo isso, tem nego ocupado com ela!!",
  ];
  String _fraseDoDia = "";

  int _mlConsumidos = 0;
  final int _metaAgua = 2000;
  final Map<String, bool> _habitsChecked = {
    'Treino na academia': false,
    'Alimentação saudável': false,
    'Dormir bem': false,
  };
  void _mostrarMenuFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 25),

            // 📸 OPÇÃO 1: CÂMERA (DIRETA E INDEPENDENTE)
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.neonGreen),
              title: const Text("Tirar Foto (Câmera)",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context); // Fecha o menu
                try {
                  final XFile? image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    imageQuality: 40,
                  );
                  if (image != null) {
                    await DbHelper()
                        .updateUserPhoto(widget.userEmail, image.path);
                    setState(() => _fotoPerfilPath = image.path);
                  }
                } catch (e) {
                  debugPrint("Erro na câmera: $e");
                }
              },
            ),

            // 🖼️ OPÇÃO 2: GALERIA (CHAMA O SEU IMAGE_SERVICE DO JEITO QUE ELE TÁ HOJE)
            // 📸 OPÇÃO 1: CÂMERA (DIRETA, LEVE E BLINDADA)
            // 🖼️ OPÇÃO 2: ESCOLHER DA GALERIA (CORRIGIDO TEXTO E ÍCONE)
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: AppTheme.neonGreen), // Ícone de Galeria
              title: const Text("Escolher da Galeria", // Texto correto
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);

                String? path = await ImageService().selecionarFoto();

                if (path != null) {
                  await DbHelper().updateUserPhoto(widget.userEmail, path);
                  setState(() => _fotoPerfilPath = path);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _fraseDoDia = _frases[Random().nextInt(_frases.length)];
    _listenToBackgroundService();
  }

  // --- ATUALIZADO: Carrega o Nome e a Foto persistidos do SQLite de forma segura ---
  Future<void> _loadInitialData() async {
    try {
      final userData = await DbHelper().getUserDataByEmail(widget.userEmail);

      if (userData != null) {
        _userNameNotifier.value = userData['name'] ?? "Recruta";
        setState(() {
          _fotoPerfilPath = userData['profile_photo'];
        });
      } else {
        _userNameNotifier.value = "Recruta";
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados iniciais: $e");
      _userNameNotifier.value = "Recruta";
    }
  }

  void _listenToBackgroundService() {
    FlutterBackgroundService().on('update').listen((event) {
      if (mounted && _isTrainingActive) {
        setState(() {
          int seconds = event!['seconds'];
          int mins = seconds ~/ 60;
          int secs = seconds % 60;
          _stopwatchDisplay =
              "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
        });
      }
    });
  }

  int _calculateCurrentXP() {
    int habitXP = _habitsChecked.values.where((v) => v).length * 100;
    int waterXP = (_mlConsumidos >= _metaAgua) ? 100 : 0;
    return habitXP + waterXP;
  }

  void _processarFeedbackIA(String tempo) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
          child: CircularProgressIndicator(color: AppTheme.neonGreen)),
    );

    String feedback = await AiHandler.getCoachFeedback(tempo);
    String nomeAtual = _userNameNotifier.value;

    await FileService().salvarNoLog(tempo, feedback, nomeAtual);

    if (mounted) {
      Navigator.pop(context);
      _showAiResponseDialog(feedback);
    }
  }

  void _showAiResponseDialog(String feedback) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppTheme.neonGreen, width: 1),
            borderRadius: BorderRadius.circular(15)),
        title: const Text("RELATÓRIO DO COACH IA",
            style: TextStyle(
                color: AppTheme.neonGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        content: Text(feedback,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("SISTEMA OTIMIZADO",
                style: TextStyle(
                    color: AppTheme.neonGreen, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- ABA 0: DASHBOARD ---
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
                    fontWeight: FontWeight.bold)),
          ),
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

  // --- ABA 1: TREINOS ---
  Widget _buildTrainingTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt,
              size: 100,
              color: _isTrainingActive ? AppTheme.neonGreen : Colors.white24),
          const SizedBox(height: 20),
          Text(_stopwatchDisplay,
              style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'monospace')),
          const SizedBox(height: 40),
          SizedBox(
            width: 280,
            height: 70,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (!_isTrainingActive) {
                  await initializeService();
                  FlutterBackgroundService().startService();

                  Future.delayed(const Duration(milliseconds: 300), () {
                    FlutterBackgroundService().invoke("resetTimer");
                  });

                  setState(() {
                    _isTrainingActive = true;
                    _stopwatchDisplay = "00:00";
                  });
                } else {
                  String tempoFinal = _stopwatchDisplay;
                  FlutterBackgroundService().invoke("stopService");
                  setState(() {
                    _isTrainingActive = false;
                    _stopwatchDisplay = "00:00";
                  });
                  _processarFeedbackIA(tempoFinal);
                }
              },
              icon: Icon(_isTrainingActive ? Icons.stop : Icons.play_arrow,
                  size: 30),
              label: Text(
                  _isTrainingActive ? "ENCERRAR PROTOCOLO" : "INICIAR TREINO",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isTrainingActive ? Colors.redAccent : AppTheme.neonGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ABA 2: PERFIL (BLINDADA CONTRA CRASHES) ---
  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              // 🔥 CORRIGIDO: Agora chama o menu flutuante em vez do service direto
              onTap: _mostrarMenuFoto,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.neonGreen, width: 2)),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.cardColor,
                  // 🔥 BLINDAGEM: Só tenta ler o arquivo se ele existir fisicamente no disco
                  backgroundImage: (_fotoPerfilPath != null &&
                          _fotoPerfilPath!.isNotEmpty &&
                          File(_fotoPerfilPath!).existsSync())
                      ? FileImage(File(_fotoPerfilPath!))
                      : null,
                  child: (_fotoPerfilPath == null ||
                          _fotoPerfilPath!.isEmpty ||
                          !File(_fotoPerfilPath!).existsSync())
                      ? const Icon(Icons.camera_alt,
                          size: 40, color: AppTheme.neonGreen)
                      : null,
                ),
              ),
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
              title: "Ver Log de Upgrade",
              desc: "Registros no filesystem (.txt)",
              icon: Icons.history,
              color: AppTheme.neonGreen,
              onTap: () async {
                String nomeAtual = _userNameNotifier.value;
                String log = await FileService().lerHistorico(nomeAtual);
                _showLogDialog(log);
              }),
          _buildActionCard(
              title: "Editar Dados",
              desc: "Mudar nome no banco",
              icon: Icons.edit,
              color: Colors.orangeAccent,
              onTap: _showEditNameDialog),
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
  void _showLogDialog(String conteudo) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.surfaceColor,
              title: const Text("HISTÓRICO LOCAL",
                  style: TextStyle(color: AppTheme.neonGreen)),
              content: SingleChildScrollView(
                  child: Text(conteudo,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("FECHAR"))
              ],
            ));
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _userNameNotifier.value);
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.surfaceColor,
              title: const Text('Editar Nome',
                  style: TextStyle(color: Colors.white)),
              content: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Novo Nome',
                      labelStyle: TextStyle(color: AppTheme.neonGreen))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                ElevatedButton(
                    onPressed: () async {
                      if (controller.text.isNotEmpty) {
                        await DbHelper().updateUserName(controller.text);
                        _userNameNotifier.value = controller.text;
                        if (context.mounted) {
                          Navigator.pop(ctx);
                        }
                      }
                    },
                    child: const Text('SALVAR'))
              ],
            ));
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Excluir Conta',
            style: TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: const Text('Esta ação é irreversível.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx); // Fecha o pop-up

              try {
                // 🗄️ 1. CORRIGIDO: Passando o e-mail dinâmico em vez do número 1
                await DbHelper().deleteUser(widget.userEmail);

                // 💾 2. ADICIONADO: Limpa a memória do celular para travar o login automático
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_email');

                // 🚀 3. Redireciona para a tela de login limpando o histórico
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                debugPrint("Erro ao deletar conta: $e");
              }
            },
            child: const Text('EXCLUIR',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- BANNER DA HOME PROTEGIDO CONTRA CRASHES ---
  Widget _buildWelcomeBanner(int cur, int tot) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3))),
      child: Column(children: [
        Row(children: [
          CircleAvatar(
            backgroundColor: AppTheme.cardColor,
            // 🔥 BLINDAGEM: Proteção igual na renderização do topo da Home
            backgroundImage: (_fotoPerfilPath != null &&
                    _fotoPerfilPath!.isNotEmpty &&
                    File(_fotoPerfilPath!).existsSync())
                ? FileImage(File(_fotoPerfilPath!))
                : null,
            child: (_fotoPerfilPath == null ||
                    _fotoPerfilPath!.isEmpty ||
                    !File(_fotoPerfilPath!).existsSync())
                ? const Icon(Icons.bolt, color: AppTheme.neonGreen)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
              child: ValueListenableBuilder(
                  valueListenable: _userNameNotifier,
                  builder: (context, name, _) => Text('E aí, $name!',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)))),
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

  Widget _buildQuoteCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.1))),
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
                  letterSpacing: 1.2))
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3))),
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
              value: (_mlConsumidos / _metaAgua).clamp(0, 1),
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
                          ? AppTheme.neonGreen.withValues(alpha: 0.05)
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

  Widget _buildStatCard(
      {required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.1))),
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
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3))),
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

  @override
  Widget build(BuildContext context) {
    int currentXP = _calculateCurrentXP();
    final List<Widget> screens = [
      _buildHomeContent(currentXP, 400),
      _buildTrainingTab(),
      _buildProfileContent()
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 2
            ? 'Meu Perfil'
            : (_currentIndex == 1 ? 'Treino Ativo' : 'FitStart')),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.neonGreen),
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen())))
        ],
      ),
      body: screens[_currentIndex],
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
}
