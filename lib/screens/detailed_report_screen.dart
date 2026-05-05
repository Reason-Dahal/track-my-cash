import 'package:flutter/material.dart';
import '../models/expense.dart';

class DetailedReportScreen extends StatelessWidget {
  final List<Expense> expenses;

  const DetailedReportScreen({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detailed Report")),
      body: expenses.isEmpty
          ? const Center(child: Text("No data"))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final e = expenses[index];

                return Card(
                  child: ListTile(
                    title: Text("Rs ${e.amount} (${e.category})"),
                    subtitle: Text(
                      "${e.description}\n${e.date.toLocal().toString().split('.')[0]}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}
