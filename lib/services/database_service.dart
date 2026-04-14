import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/debt.dart';

class DatabaseService {
  static final DatabaseService _i = DatabaseService._();
  factory DatabaseService() => _i;
  DatabaseService._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'debt_pro_v2.db');
    return openDatabase(path, version: 1, onCreate: (d, _) async {
      await d.execute('''
        CREATE TABLE debts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          amount REAL NOT NULL,
          paid_amount REAL NOT NULL DEFAULT 0,
          type TEXT NOT NULL,
          note TEXT,
          created_at TEXT NOT NULL,
          due_date TEXT,
          is_settled INTEGER NOT NULL DEFAULT 0
        )
      ''');
    });
  }

  Future<int> insert(Debt debt) async {
    final d = await db;
    return d.insert('debts', debt.toMap()..remove('id'));
  }

  Future<List<Debt>> getAll() async {
    final d = await db;
    final rows = await d.query('debts', orderBy: 'created_at DESC');
    return rows.map(Debt.fromMap).toList();
  }

  Future<void> update(Debt debt) async {
    final d = await db;
    await d.update('debts', debt.toMap(),
        where: 'id = ?', whereArgs: [debt.id]);
  }

  Future<void> delete(int id) async {
    final d = await db;
    await d.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final d = await db;
    await d.delete('debts');
  }
}
