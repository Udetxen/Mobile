import 'expense_category.dart';

class Expense {
  String? uid;
  String name;
  double budget;
  double? expense;
  String? invoiceImageUrl;
  String? note;
  List<String> categoryUids;
  List<ExpenseCategory>? categories;

  Expense({
    this.uid,
    required this.name,
    required this.budget,
    this.expense,
    this.invoiceImageUrl,
    this.note,
    required this.categoryUids,
    this.categories,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      uid: json['uid'],
      name: json['name'],
      budget: json['budget'],
      expense: json['expense'],
      invoiceImageUrl: json['invoiceImageUrl'],
      note: json['note'],
      categoryUids: List<String>.from(json['categoryUids']),
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((category) => ExpenseCategory.fromJson(category))
              .toList()
          : null,
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
      'categoryUids': categoryUids,
    };
  }
}
