import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart'; // Certifique-se que o caminho está correto

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
            password TEXT
          )
        ''');
      },
    );
  }

  // No seu db_helper.dart
  Future<String> getLastName() async {
    Database db = await database;
    // Busca o último ID inserido na tabela
    List<Map> result = await db.query('users', orderBy: 'id DESC', limit: 1);

    if (result.isNotEmpty) {
      return result.first['name'] as String;
    }
    return "Usuário"; // Nome padrão caso o banco esteja vazio
  }

  // --- 1. CREATE (Salvar usuário do seu Model) ---
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  // --- 2. READ (Login por Email e Senha) ---
  Future<bool> checkLogin(String email, String password) async {
    Database db = await database;
    List<Map> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
  }

  // --- 3. DELETE (Remover usuário) ---
  Future<int> deleteUser(int id) async {
    Database db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
