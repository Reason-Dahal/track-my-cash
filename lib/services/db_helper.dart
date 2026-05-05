import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/budget.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final path = join(await getDatabasesPath(), 'expenses.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            category TEXT,
            description TEXT,
            date TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE budgets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            startDate TEXT,
            endDate TEXT,
            period TEXT
          )
        ''');
      },
    );

    return _database!;
  }

  // ===================== EXPENSE =====================

  // INSERT EXPENSE
  static Future<int> insertExpense(Expense e) async {
    final db = await getDatabase();

    return await db.insert('expenses', {
      'amount': e.amount,
      'category': e.category,
      'description': e.description,
      'date': e.date.toIso8601String(),
    });
  }

  // GET ALL EXPENSES
  static Future<List<Expense>> getExpenses() async {
    final db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('expenses');

    return maps.map((map) {
      return Expense(
        id: map['id'] as int,
        amount: (map['amount'] as num).toDouble(), // ✅ FIXED
        category: map['category'] as String,
        description: map['description'] as String,
        date: DateTime.parse(map['date'] as String),
      );
    }).toList();
  }

  // DELETE EXPENSE
  static Future<void> deleteExpense(int id) async {
    final db = await getDatabase();

    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // UPDATE EXPENSE
  static Future<void> updateExpense(Expense e) async {
    final db = await getDatabase();

    await db.update(
      'expenses',
      {
        'amount': e.amount,
        'category': e.category,
        'description': e.description,
        'date': e.date.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [e.id],
    );
  }

  // ===================== BUDGET =====================

  // INSERT BUDGET
  static Future<void> insertBudget(Budget b) async {
    final db = await getDatabase();

    await db.insert('budgets', {
      'amount': b.amount,
      'startDate': b.startDate.toIso8601String(),
      'endDate': b.endDate.toIso8601String(),
      'period': b.period,
    });
  }

  static Future<List<Budget>> getBudgets() async {
    final db = await getDatabase();
    final maps = await db.query('budgets');

    return maps.map((map) {
      return Budget(
        id: map['id'] as int,
        amount: (map['amount'] as num).toDouble(),
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: DateTime.parse(map['endDate'] as String),
        period: map['period'] as String,
      );
    }).toList();
  }

  static Future<void> updateBudget(Budget b) async {
    final db = await getDatabase();

    await db.update(
      'budgets',
      {
        'amount': b.amount,
        'startDate': b.startDate.toIso8601String(),
        'endDate': b.endDate.toIso8601String(),
        'period': b.period,
      },
      where: 'id = ?',
      whereArgs: [b.id],
    );
  }

  static Future<void> deleteBudget(int id) async {
    final db = await getDatabase();

    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}
