import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../services/db_helper.dart';
import 'budget_screen.dart';

class BudgetHistoryScreen extends StatefulWidget {
  const BudgetHistoryScreen({super.key});

  @override
  State<BudgetHistoryScreen> createState() => _BudgetHistoryScreenState();
}

class _BudgetHistoryScreenState extends State<BudgetHistoryScreen> {
  List<Budget> budgets = [];

  @override
  void initState() {
    super.initState();
    loadBudgets();
  }

  void loadBudgets() async {
    final data = await DBHelper.getBudgets();
    setState(() {
      budgets = data;
    });
  }

  void deleteBudget(int index) async {
    final b = budgets[index];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Budget"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await DBHelper.deleteBudget(b.id!);
              Navigator.pop(context);
              loadBudgets();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Budget History")),
      body: ListView.builder(
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final b = budgets[index];

          return ListTile(
            title: Text("Rs ${b.amount} (${b.period})"),
            subtitle: Text("${b.startDate.toLocal()} → ${b.endDate.toLocal()}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BudgetScreen(existingBudget: b),
                      ),
                    );

                    if (updated != null) {
                      await DBHelper.updateBudget(updated);
                      loadBudgets();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteBudget(index),
                ),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newBudget = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BudgetScreen()),
          );

          if (newBudget != null) {
            await DBHelper.insertBudget(newBudget);
            loadBudgets();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
