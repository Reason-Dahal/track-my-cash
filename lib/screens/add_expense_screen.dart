import 'package:flutter/material.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? existingExpense;

  const AddExpenseScreen({super.key, this.existingExpense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final customCategoryController = TextEditingController();

  final List<String> categories = [
    "Food",
    "Clothing",
    "Transportation",
    "Health",
    "Entertainment",
    "Other",
  ];

  String category = "Food";
  bool isCustom = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    if (widget.existingExpense != null) {
      final e = widget.existingExpense!;

      amountController.text = e.amount.toString();
      descriptionController.text = e.description;
      selectedDate = e.date;

      // 🔥 HANDLE CUSTOM CATEGORY SAFELY
      if (categories.contains(e.category)) {
        category = e.category;
        isCustom = false;
      } else {
        category = "Other";
        isCustom = true;
        customCategoryController.text = e.category;
      }
    }
  }

  void submit() {
    final amount = double.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid amount")));
      return;
    }

    if (selectedDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Future date not allowed")));
      return;
    }

    final finalCategory = isCustom
        ? customCategoryController.text.trim()
        : category;

    if (finalCategory.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter category")));
      return;
    }

    Navigator.pop(
      context,
      Expense(
        id: widget.existingExpense?.id, // 🔥 IMPORTANT FOR EDIT
        amount: amount,
        category: finalCategory,
        description: descriptionController.text.trim(),
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
    final safeCategory = categories.contains(category) ? category : "Other";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingExpense == null ? "Add Expense" : "Edit Expense",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 10),

            // 🔥 FIXED DROPDOWN
            DropdownButton<String>(
              value: safeCategory,
              isExpanded: true,
              items: categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
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
                decoration: const InputDecoration(labelText: "Custom Category"),
              ),

            const SizedBox(height: 10),

            Row(
              children: [
                Text(
                  "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                ),
                const Spacer(),
                TextButton(
                  onPressed: pickDate,
                  child: const Text("Select Date"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: submit,
              child: Text(
                widget.existingExpense == null
                    ? "Add Expense"
                    : "Update Expense",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
