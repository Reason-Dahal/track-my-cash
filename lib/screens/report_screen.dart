import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ReportScreen extends StatefulWidget {
  final List<Expense> expenses;

  ReportScreen({required this.expenses});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime? startDate;
  DateTime? endDate;

  String selectedFilter = "7D";

  // 📌 QUICK FILTER HANDLER
  void applyQuickFilter(String filter) {
    DateTime now = DateTime.now();

    setState(() {
      selectedFilter = filter;

      switch (filter) {
        case "7D":
          startDate = now.subtract(Duration(days: 7));
          break;
        case "30D":
          startDate = now.subtract(Duration(days: 30));
          break;
        case "90D":
          startDate = now.subtract(Duration(days: 90));
          break;
        case "6M":
          startDate = DateTime(now.year, now.month - 6, now.day);
          break;
        case "1Y":
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
      }

      endDate = now;
    });
  }

  // 📌 DATE PICKERS
  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedFilter = "Custom";
        startDate = picked;
      });
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedFilter = "Custom";
        endDate = picked;
      });
    }
  }

  // 📌 FILTER LOGIC
  List<Expense> getFilteredExpenses() {
    if (startDate == null || endDate == null) {
      return widget.expenses;
    }

    return widget.expenses.where((e) {
      return e.date.isAfter(startDate!) &&
          e.date.isBefore(endDate!.add(Duration(days: 1)));
    }).toList();
  }

  // 📌 CATEGORY SUMMARY
  Map<String, double> getCategoryTotals(List<Expense> list) {
    Map<String, double> data = {};

    for (var e in list) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = getFilteredExpenses();
    final categoryData = getCategoryTotals(filtered);

    return Scaffold(
      appBar: AppBar(title: Text("Expense Report")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [

            // 🔹 QUICK FILTERS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["7D", "30D", "90D", "6M", "1Y"].map((f) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: selectedFilter == f,
                      onSelected: (_) => applyQuickFilter(f),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 10),

            // 🔹 CUSTOM DATE PICKERS
            Row(
              children: [
                Expanded(
                  child: Text(
                    startDate == null
                        ? "Start Date"
                        : DateFormat('yyyy-MM-dd').format(startDate!),
                  ),
                ),
                TextButton(onPressed: pickStartDate, child: Text("Select")),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    endDate == null
                        ? "End Date"
                        : DateFormat('yyyy-MM-dd').format(endDate!),
                  ),
                ),
                TextButton(onPressed: pickEndDate, child: Text("Select")),
              ],
            ),

            Divider(),

            // 🔹 CATEGORY SUMMARY
            Text(
              "Category Summary",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 5),

            SizedBox(
              height: 120,
              child: categoryData.isEmpty
                  ? Center(child: Text("No data"))
                  : ListView(
                      children: categoryData.entries.map((e) {
                        return ListTile(
                          dense: true,
                          title: Text(e.key),
                          trailing: Text("Rs ${e.value}"),
                        );
                      }).toList(),
                    ),
            ),

            Divider(),

            // 🔹 DETAILED LIST
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text("No expenses"))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final e = filtered[index];
                        final date =
                            DateFormat('yyyy-MM-dd HH:mm').format(e.date);

                        return Card(
                          child: ListTile(
                            title:
                                Text("${e.category} - Rs ${e.amount}"),
                            subtitle:
                                Text("${e.description}\n$date"),
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