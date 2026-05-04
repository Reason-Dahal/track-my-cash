import 'package:flutter/material.dart';
import '../models/budget.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final controller = TextEditingController();

  void submit() {
    final amount = double.tryParse(controller.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid budget")));
      return;
    }

    Navigator.pop(
      context,
      Budget(
        amount: amount,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 30)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set Budget")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: "Budget Amount"),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(onPressed: submit, child: Text("Set Budget"))
          ],
        ),
      ),
    );
  }
}