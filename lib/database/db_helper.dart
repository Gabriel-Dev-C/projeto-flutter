import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'fitstart.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            password TEXT,
            profile_photo TEXT --
          )
        ''');
      },
    );
  }

  //  BUSCA DADOS COMPLETOS  PELO EMAIL ---
  Future<Map<String, dynamic>?> getUserDataByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim()],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ATUALIZA O CAMINHO DA FOTO DE PERFIL ---
  Future<int> updateUserPhoto(String email, String photoPath) async {
    final db = await database;

    // Patch de segurança: Se o banco já existia no celular sem a coluna da foto,
    // o comando abaixo injeta ela na marra sem quebrar nada.
    try {
      await db.execute("ALTER TABLE users ADD COLUMN profile_photo TEXT;");
    } catch (_) {}

    return await db.update(
      'users',
      {'profile_photo': photoPath},
      where: 'email = ?',
      whereArgs: [email.trim()],
    );
  }

  
  Future<String> getUserNameByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['name'],
      where: 'email = ?',
      whereArgs: [email.trim()],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['name'] as String;
    }
    return "Recruta";
  }

  // --- 1. CREATE (Salvar usuário do seu Model) ---
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  // --- 2. READ (Login por Email e Senha) ---
  Future<bool> checkLogin(String email, String password) async {
    try {
      final db = await database;

      //  BUSCA EXATAMENTE PELO EMAIL E PELA SENHA JUNTOS
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email.trim().toLowerCase(), password],
      );

      // Se encontrou pelo menos 1 registro que bate com os dois critérios, o login é válido
      if (maps.isNotEmpty) {
        debugPrint("🔐 VALIDAÇÃO SQLITE: Usuário e senha corretos!");
        return true;
      }

      debugPrint("❌ VALIDAÇÃO SQLITE: E-mail ou senha incorretos.");
      return false;
    } catch (e) {
      debugPrint("Erro ao verificar login no banco: $e");
      return false;
    }
  }

  // --- 3. DELETE (Remover usuário) ---
  Future<int> deleteUser(String email) async {
    final db = await database; // Instância do seu banco SQLite
    return await db.delete(
      'users', // 🔥 VEJA SE O NOME DA SUA TABELA É 'users' OU 'usuarios'
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
  }

  // --- 4. UPDATE: Para alterar o nome do usuário ---
  Future<int> updateUserName(String newName) async {
    final db = await database;
    return await db.update(
      'users',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
