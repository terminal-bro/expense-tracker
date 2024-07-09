class Expense {
  int? id;
  DateTime date;
  double amount;
  String description;

  Expense(
      {this.id,
      required this.date,
      required this.amount,
      required this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'description': description,
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      description: map['description'],
    );
  }
}
