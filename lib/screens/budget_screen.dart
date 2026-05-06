import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../services/db_helper.dart';

class BudgetScreen extends StatefulWidget {
  final Budget? existingBudget;

  const BudgetScreen({super.key, this.existingBudget});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final amountController = TextEditingController();

  String selectedPeriod = "7 Days";

  final List<String> periods = [
    "7 Days",
    "1 Month",
    "3 Months",
    "6 Months",
    "1 Year",
    "Custom",
  ];

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  List<Budget> allBudgets = [];

  @override
  void initState() {
    super.initState();
    loadBudgets();

    if (widget.existingBudget != null) {
      final b = widget.existingBudget!;

      amountController.text = b.amount.toString();
      selectedPeriod = b.period;
      startDate = b.startDate;
      endDate = b.endDate;
    } else {
      calculateDates();
    }
  }

  // 🔥 LOAD ALL BUDGETS
  void loadBudgets() async {
    final data = await DBHelper.getBudgets();
    setState(() {
      allBudgets = data;
    });
  }

  void deleteBudget(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this budget?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await DBHelper.deleteBudget(id);

              Navigator.pop(ctx);

              loadBudgets(); // 🔥 refresh list
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 🔥 AUTO DATE CALCULATION
  void calculateDates() {
    final now = DateTime.now();

    switch (selectedPeriod) {
      case "7 Days":
        endDate = now.add(const Duration(days: 7));
        break;
      case "1 Month":
        endDate = DateTime(now.year, now.month + 1, now.day);
        break;
      case "3 Months":
        endDate = DateTime(now.year, now.month + 3, now.day);
        break;
      case "6 Months":
        endDate = DateTime(now.year, now.month + 6, now.day);
        break;
      case "1 Year":
        endDate = DateTime(now.year + 1, now.month, now.day);
        break;
    }

    startDate = now;
  }

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  // 🔥 SAVE OR UPDATE
  void submit() {
    final amount = double.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid amount")));
      return;
    }

    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End date must be after start date")),
      );
      return;
    }

    if (selectedPeriod != "Custom") {
      calculateDates();
    }

    final budget = Budget(
      id: widget.existingBudget?.id,
      amount: amount,
      startDate: startDate,
      endDate: endDate,
      period: selectedPeriod,
    );

    // SHOW CONFIRMATION FIRST
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingBudget == null
              ? "✅ Budget Created"
              : "✅ Budget Updated",
        ),
      ),
    );

    // DELAY THEN CLOSE
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context, budget);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Budget Manager")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🔹 INPUT SECTION
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Budget Amount"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 10),

            DropdownButton<String>(
              value: selectedPeriod,
              isExpanded: true,
              items: periods
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedPeriod = val!;
                  if (val != "Custom") {
                    calculateDates();
                  }
                });
              },
            ),

            const SizedBox(height: 10),

            if (selectedPeriod == "Custom") ...[
              Row(
                children: [
                  Text(
                    "Start: ${startDate.toLocal().toString().split(' ')[0]}",
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => pickDate(true),
                    child: const Text("Select"),
                  ),
                ],
              ),
              Row(
                children: [
                  Text("End: ${endDate.toLocal().toString().split(' ')[0]}"),
                  const Spacer(),
                  TextButton(
                    onPressed: () => pickDate(false),
                    child: const Text("Select"),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: submit,
              child: Text(
                widget.existingBudget == null ? "Add Budget" : "Update Budget",
              ),
            ),

            const SizedBox(height: 20),

            const Divider(),

            // 🔹 LIST OF ALL BUDGETS
            Expanded(
              child: allBudgets.isEmpty
                  ? const Center(child: Text("No budgets yet"))
                  : ListView.builder(
                      itemCount: allBudgets.length,
                      itemBuilder: (context, index) {
                        final b = allBudgets[index];

                        return Card(
                          child: ListTile(
                            title: Text("Rs ${b.amount} (${b.period})"),
                            subtitle: Text(
                              "${b.startDate.toLocal().toString().split(' ')[0]} → "
                              "${b.endDate.toLocal().toString().split(' ')[0]}",
                            ),

                            // ACTION BUTTONS
                            trailing: SizedBox(
                              width: 100, //  gives enough space
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        amountController.text = b.amount
                                            .toString();
                                        selectedPeriod = b.period;
                                        startDate = b.startDate;
                                        endDate = b.endDate;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      if (b.id != null) {
                                        deleteBudget(b.id!);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // optional: tap = edit
                            onTap: () {
                              setState(() {
                                amountController.text = b.amount.toString();
                                selectedPeriod = b.period;
                                startDate = b.startDate;
                                endDate = b.endDate;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
