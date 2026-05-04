class Expense {
  int? id;
  double amount;
  String category;
  String description;
  DateTime date;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });
}