import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import 'detailed_report_screen.dart';

class ReportScreen extends StatefulWidget {
  final List<Expense> expenses;

  const ReportScreen({super.key, required this.expenses});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Expense> filteredExpenses = [];

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    applyFilter(days: 7); // default
  }

  // 🔥 FILTER LOGIC
  void applyFilter({int? days}) {
    final now = DateTime.now();

    if (days != null) {
      startDate = now.subtract(Duration(days: days));
      endDate = now;
    }

    setState(() {
      filteredExpenses = widget.expenses.where((e) {
        if (startDate == null || endDate == null) return true;
        return e.date.isAfter(startDate!) &&
            e.date.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    });
  }

  // 🔥 CUSTOM DATE PICKER
  Future<void> pickCustomRange() async {
    final pickedStart = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedStart == null) return;

    final pickedEnd = await showDatePicker(
      context: context,
      initialDate: pickedStart,
      firstDate: pickedStart,
      lastDate: DateTime.now(),
    );

    if (pickedEnd == null) return;

    startDate = pickedStart;
    endDate = pickedEnd;

    applyFilter();
  }

  // 🔥 CATEGORY TOTALS
  Map<String, double> getCategoryTotals() {
    Map<String, double> data = {};

    for (var e in filteredExpenses) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }

    return data;
  }

  double getTotal() {
    return filteredExpenses.fold(0, (sum, e) => sum + e.amount);
  }

  final List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  // 🔥 PIE CHART
  Widget buildPieChart() {
    final data = getCategoryTotals();

    if (data.isEmpty) return const Text("No data");

    int i = 0;

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sections: data.entries.map((entry) {
            final percent = (entry.value / getTotal()) * 100;

            return PieChartSectionData(
              value: entry.value,
              color: colors[i++ % colors.length],
              title: "${percent.toStringAsFixed(1)}%",
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  // 🔥 BAR CHART
  Widget buildBarChart() {
    final data = getCategoryTotals();

    if (data.isEmpty) return const Text("No data");

    int i = 0;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          barGroups: data.entries.map((entry) {
            return BarChartGroupData(
              x: i++,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: colors[(i - 1) % colors.length],
                  width: 15,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final keys = data.keys.toList();
                  if (value.toInt() >= keys.length) return const Text('');
                  return Text(
                    keys[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  // 🔥 LEGEND
  Widget buildLegend() {
    final data = getCategoryTotals();

    int i = 0;

    return Column(
      children: data.entries.map((entry) {
        final percent = (entry.value / getTotal()) * 100;

        return Row(
          children: [
            Container(
              width: 15,
              height: 15,
              color: colors[i++ % colors.length],
            ),
            const SizedBox(width: 10),
            Text(
              "${entry.key} - Rs ${entry.value.toStringAsFixed(0)} (${percent.toStringAsFixed(1)}%)",
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget buildFilterButtons() {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton(
          onPressed: () => applyFilter(days: 7),
          child: const Text("7D"),
        ),
        ElevatedButton(
          onPressed: () => applyFilter(days: 30),
          child: const Text("30D"),
        ),
        ElevatedButton(
          onPressed: () => applyFilter(days: 90),
          child: const Text("90D"),
        ),
        ElevatedButton(
          onPressed: () => applyFilter(days: 180),
          child: const Text("6M"),
        ),
        ElevatedButton(
          onPressed: () => applyFilter(days: 365),
          child: const Text("1Y"),
        ),
        ElevatedButton(onPressed: pickCustomRange, child: const Text("Custom")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            buildFilterButtons(),
            const SizedBox(height: 15),

            Text(
              "Total: Rs ${getTotal().toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            buildPieChart(),

            const SizedBox(height: 20),

            buildLegend(),

            const SizedBox(height: 20),

            buildBarChart(),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DetailedReportScreen(expenses: filteredExpenses),
                  ),
                );
              },
              child: const Text("Show Detailed Report"),
            ),
          ],
        ),
      ),
    );
  }
}
