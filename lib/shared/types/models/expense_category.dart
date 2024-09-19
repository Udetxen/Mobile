class ExpenseCategory {
  String? uid;
  String name;

  ExpenseCategory({
    this.uid,
    required this.name,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      uid: json['uid'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
    };
  }
}
