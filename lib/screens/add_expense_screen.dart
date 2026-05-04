import 'package:flutter/material.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? existingExpense;

  AddExpenseScreen({this.existingExpense});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final customCategoryController = TextEditingController();

  String category = "Food";
  bool isCustom = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    if (widget.existingExpense != null) {
      amountController.text = widget.existingExpense!.amount.toString();

      descriptionController.text = widget.existingExpense!.description;

      category = widget.existingExpense!.category;
      selectedDate = widget.existingExpense!.date;
    }
  }

  void submit() {
    final amount = double.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Enter valid amount")));
      return;
    }

    if (selectedDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Future date not allowed")));
      return;
    }

    String finalCategory = isCustom ? customCategoryController.text : category;

    if (finalCategory.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Enter category")));
      return;
    }

    Navigator.pop(
      context,
      Expense(
        id: widget.existingExpense?.id, // MUST HAVE
        amount: amount,
        category: finalCategory,
        description: descriptionController.text,
        date: selectedDate,
      ),
    );
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Expense")),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),

            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "Description"),
            ),

            SizedBox(height: 10),

            DropdownButton<String>(
              value: category,
              isExpanded: true,
              items: [
                "Food",
                "Clothing",
                "Transportation",
                "Health",
                "Entertainment",
                "Other",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                setState(() {
                  category = val!;
                  isCustom = (val == "Other");
                });
              },
            ),

            if (isCustom)
              TextField(
                controller: customCategoryController,
                decoration: InputDecoration(labelText: "Custom Category"),
              ),

            SizedBox(height: 10),

            Row(
              children: [
                Text(
                  "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                ),
                Spacer(),
                TextButton(onPressed: pickDate, child: Text("Select Date")),
              ],
            ),

            SizedBox(height: 10),

            ElevatedButton(onPressed: submit, child: Text("Add Expense")),
          ],
        ),
      ),
    );
  }
}
