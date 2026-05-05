class Budget {
  int? id;
  double amount;
  DateTime startDate;
  DateTime endDate;
  String period; // 🔥 NEW

  Budget({
    this.id,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.period,
  });
}
