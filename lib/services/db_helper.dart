import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final path = join(await getDatabasesPath(), 'expenses.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            category TEXT,
            description TEXT,
            date TEXT
          )
        ''');
      },
    );

    return _database!;
  }

  // INSERT
  static Future<int> insertExpense(Expense e) async {
  final db = await getDatabase();

  return await db.insert(
    'expenses',
    {
      'amount': e.amount,
      'category': e.category,
      'description': e.description,
      'date': e.date.toIso8601String(),
    },
  );
}

  // FETCH
  static Future<List<Expense>> getExpenses() async {
  final db = await getDatabase();

  final List<Map<String, dynamic>> maps =
      await db.query('expenses');

  return maps.map((map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }).toList();
}

  // DELETE
  static Future<void> deleteExpense(int id) async {
  final db = await getDatabase();

  await db.delete(
    'expenses',
    where: 'id = ?',
    whereArgs: [id],
  );
}
  //UPDATE
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

}