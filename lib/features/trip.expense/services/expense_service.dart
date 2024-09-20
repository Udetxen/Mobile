import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udetxen/shared/config/constants.dart';
import 'package:udetxen/shared/types/models/expense.dart';
import 'package:udetxen/shared/types/models/expense_category.dart';
import 'package:udetxen/shared/types/models/trip.dart';

class ExpenseService {
  final FirebaseFirestore _firestore;

  ExpenseService(this._firestore);

  Future<Trip> createExpenseForTrip(String tripUid, Expense expense) async {
    DocumentReference tripRef =
        _firestore.collection(tripCollection).doc(tripUid);
    DocumentReference expenseRef =
        _firestore.collection(expenseCollection).doc();

    // Fetch the trip data
    DocumentSnapshot tripSnapshot = await tripRef.get();
    Trip trip = Trip.fromJson(tripSnapshot.data() as Map<String, dynamic>);

    // Fetch all expenses for the trip
    QuerySnapshot expensesSnapshot = await _firestore
        .collection(expenseCollection)
        .where(FieldPath.documentId, whereIn: trip.expenseUids)
        .get();

    // Calculate the total budget of existing expenses
    double totalBudgets = expensesSnapshot.docs.fold(0.0, (sum, doc) {
      Expense existingExpense =
          Expense.fromJson(doc.data() as Map<String, dynamic>);
      return sum + existingExpense.budget;
    });

    // Check if adding the new expense exceeds the trip budget
    if (totalBudgets + expense.budget > trip.budget) {
      throw Exception('Total expenses exceed the trip budget'); // TODO
    }

    // Set the expense UID
    expense.uid = expenseRef.id;

    // Add the new expense
    await expenseRef.set(expense.toJson());

    // Update the trip with the new expense UID
    await tripRef.update({
      'expenseUids': FieldValue.arrayUnion([expenseRef.id]),
    });

    // Return the updated trip
    return tripRef
        .get()
        .then((doc) => Trip.fromJson(doc.data() as Map<String, dynamic>));
  }

  Future<void> updateExpense(String expenseUid, Expense expense) async {
    DocumentReference expenseRef =
        _firestore.collection(expenseCollection).doc(expenseUid);

    await expenseRef.update(expense.toJson());
  }

  Future<void> deleteExpense(String tripUid, String expenseUid) async {
    DocumentReference tripRef =
        _firestore.collection(tripCollection).doc(tripUid);
    DocumentReference expenseRef =
        _firestore.collection(expenseCollection).doc(expenseUid);

    await expenseRef.delete();

    await tripRef.update({
      'expenseUids': FieldValue.arrayRemove([expenseUid]),
    });
  }

  Stream<List<Expense>> getExpenses(List<String> expenseUids) {
    Query query = _firestore.collection(expenseCollection);

    if (expenseUids.isNotEmpty) {
      query = query.where(FieldPath.documentId, whereIn: expenseUids);
    }

    return query.snapshots().asyncMap((snapshot) async {
      final expenses = snapshot.docs.map((doc) {
        final res = Expense.fromJson(doc.data() as Map<String, dynamic>);
        return res;
      }).toList();

      for (var expense in expenses) {
        if (expense.categoryUids.isNotEmpty) {
          final categoriesSnapshot = await _firestore
              .collection(expenseCategoryCollection)
              .where(FieldPath.documentId, whereIn: expense.categoryUids)
              .get();

          expense.categories = categoriesSnapshot.docs.map((doc) {
            return ExpenseCategory.fromJson(doc.data());
          }).toList();
        }
      }

      return expenses;
    });
  }

  Future<List<ExpenseCategory>> getExpenseCategories() async {
    QuerySnapshot snapshot =
        await _firestore.collection(expenseCategoryCollection).get();
    return snapshot.docs
        .map((doc) =>
            ExpenseCategory.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
