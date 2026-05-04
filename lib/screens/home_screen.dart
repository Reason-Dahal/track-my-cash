import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';
import 'budget_screen.dart';
import 'report_screen.dart';
import '../services/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];
  Budget? budget;

  @override
    void initState() {
      super.initState();
      loadExpenses();
    }

    void loadExpenses() async {
      final data = await DBHelper.getExpenses();
      setState(() {
        expenses = data;
      });
    }

  double getTotalExpense() {
    return expenses.fold(0, (sum, e) => sum + e.amount);
  }

  bool isNearLimit() {
    if (budget == null) return false;
    return getTotalExpense() >= (budget!.amount * 0.9);
  }

  void addExpense(Expense expense) async {
    await DBHelper.insertExpense(expense);

    setState(() {
      expenses.add(expense);
    });
  }

    void deleteExpense(int index) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this expense?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final expense = expenses[index];

                // ✅ DELETE FROM DATABASE
                if (expense.id != null) {
                  await DBHelper.deleteExpense(expense.id!);
                }

                // ✅ UPDATE UI
                setState(() {
                  expenses.removeAt(index);
                });

                Navigator.pop(ctx);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

  void setBudget(Budget newBudget) {
    setState(() {
      budget = newBudget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TrackMyCash 💰"),
        actions: [
          IconButton(
            icon: Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportScreen(expenses: expenses),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BudgetScreen()),
              );

              if (result != null) setBudget(result);
            },
          )
        ],
      ),
      body: Column(
        children: [
          if (budget != null)
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Budget: Rs ${budget!.amount}",
                style: TextStyle(fontSize: 18),
              ),
            ),

          if (isNearLimit())
            Container(
              width: double.infinity,
              color: Colors.red,
              padding: EdgeInsets.all(8),
              child: Text(
                "⚠ Budget almost exceeded!",
                style: TextStyle(color: Colors.white),
              ),
            ),

          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Total Expense: Rs ${getTotalExpense()}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: expenses.isEmpty
                ? Center(child: Text("No expenses yet"))
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
                            setState(() {
                              expenses[index] = updated;
                            });
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
        child: Icon(Icons.add),
      ),
    );
  }
}