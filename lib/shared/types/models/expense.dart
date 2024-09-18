import 'expense_category.dart';

class Expense {
  String uid;
  String name;
  double budget;
  double? expense;
  String? invoiceImageUrl;
  String? note;
  List<ExpenseCategory> categories;

  Expense({
    required this.uid,
    required this.name,
    required this.budget,
    this.expense,
    this.invoiceImageUrl,
    this.note,
    required this.categories,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      uid: json['uid'],
      name: json['name'],
      budget: json['budget'],
      expense: json['expense'],
      invoiceImageUrl: json['invoiceImageUrl'],
      note: json['note'],
      categories: (json['categories'] as List)
          .map((e) => ExpenseCategory.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'budget': budget,
      'expense': expense,
      'invoiceImageUrl': invoiceImageUrl,
      'note': note,
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }
}
