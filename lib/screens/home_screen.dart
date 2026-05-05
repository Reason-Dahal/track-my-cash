import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';
// import 'budget_screen.dart';
import 'report_screen.dart';
import 'budget_history_screen.dart';
import '../services/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];
  List<Budget> budgets = [];
  Budget? activeBudget;

  double lastAlertPercent = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // 🔥 LOAD EVERYTHING
  void loadData() async {
    final exp = await DBHelper.getExpenses();
    final bud = await DBHelper.getBudgets();

    setState(() {
      expenses = exp;
      budgets = bud;
      activeBudget = getActiveBudget();
    });

    checkBudgetAlerts();
  }

  // 🔥 ACTIVE BUDGET (TIME BASED)
  Budget? getActiveBudget() {
    final now = DateTime.now();

    try {
      return budgets.firstWhere(
        (b) =>
            (now.isAfter(b.startDate) || now.isAtSameMomentAs(b.startDate)) &&
            (now.isBefore(b.endDate) || now.isAtSameMomentAs(b.endDate)),
      );
    } catch (e) {
      return null;
    }
  }

  // 🔥 EXPENSE INSIDE BUDGET RANGE
  double getBudgetExpense() {
    if (activeBudget == null) return 0;

    final relevant = expenses.where((e) {
      return e.date.isAfter(activeBudget!.startDate) &&
          e.date.isBefore(activeBudget!.endDate.add(const Duration(days: 1)));
    });

    return relevant.fold(0, (sum, e) => sum + e.amount);
  }

  double getTotalExpense() {
    return expenses.fold(0, (sum, e) => sum + e.amount);
  }

  // 🔥 SMART ALERT SYSTEM
  void checkBudgetAlerts() {
    if (activeBudget == null) return;

    final used = getBudgetExpense();
    final percent = (used / activeBudget!.amount) * 100;

    String? message;

    if (percent >= 100 && lastAlertPercent < 100) {
      message = "❌ Budget exceeded!";
    } else if (percent >= 80 && lastAlertPercent < 80) {
      message = "🚨 80% budget used!";
    } else if (percent >= 50 && lastAlertPercent < 50) {
      message = "⚠ 50% budget used!";
    }

    if (message != null) {
      lastAlertPercent = percent;

      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(message),
          backgroundColor: percent >= 100
              ? Colors.red
              : percent >= 80
              ? Colors.orange
              : Colors.yellow,
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text("DISMISS"),
            ),
          ],
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      });
    }
  }

  // 🔥 ADD EXPENSE
  void addExpense(Expense expense) async {
    await DBHelper.insertExpense(expense);
    loadData();
  }

  // 🔥 DELETE
  void deleteExpense(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final expense = expenses[index];

              if (expense.id != null) {
                await DBHelper.deleteExpense(expense.id!);
              }

              Navigator.pop(ctx);
              loadData();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 🔥 SET BUDGET
  void setBudget(Budget b) async {
    await DBHelper.insertBudget(b);
    loadData();
  }

  // 🔥 PROGRESS %
  double getBudgetPercent() {
    if (activeBudget == null) return 0;
    return getBudgetExpense() / activeBudget!.amount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TrackMyCash 💰"),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportScreen(expenses: expenses),
                ),
              );
            },
          ),

          // 🔥 OPEN BUDGET HISTORY
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BudgetHistoryScreen()),
              );
              loadData();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔥 ACTIVE BUDGET CARD
          if (activeBudget != null)
            Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                      "Budget (${activeBudget!.period})",
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Rs ${getBudgetExpense().toStringAsFixed(0)} / ${activeBudget!.amount}",
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: getBudgetPercent().clamp(0, 1),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Total Expense: Rs ${getTotalExpense()}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text("No expenses yet"))
                : ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      return ExpenseCard(
                        expense: expenses[index],
                        onDelete: () => deleteExpense(index),
                        onEdit: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddExpenseScreen(
                                existingExpense: expenses[index],
                              ),
                            ),
                          );

                          if (updated != null) {
                            await DBHelper.updateExpense(updated);
                            loadData();
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newExpense = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddExpenseScreen()),
          );

          if (newExpense != null) addExpense(newExpense);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
