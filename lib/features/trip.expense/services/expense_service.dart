import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/shared/config/constants.dart';
import 'package:udetxen/shared/types/models/expense.dart';
import 'package:udetxen/shared/types/models/expense_category.dart';
import 'package:udetxen/shared/types/models/trip.dart';

class ExpenseService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  ExpenseService(this._firestore, this._authService);

  Stream<List<Trip>> getUserTrips() async* {
    final userId = await _authService.currentUser.then((u) => u.uid);

    Query individualQuery = _firestore
        .collection(tripCollection)
        .where('type', isEqualTo: 'individual')
        .where('creatorUid', isEqualTo: userId)
        .orderBy('startDate');

    Query groupQuery = _firestore
        .collection(tripCollection)
        .where('type', isEqualTo: 'group')
        .where('participantUids', arrayContains: userId);

    final individualTripsStream = individualQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data()! as Map<String, dynamic>;
        return Trip.fromJson(data);
      }).toList();
    });

    final groupTripsStream = groupQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data()! as Map<String, dynamic>;
        return Trip.fromJson(data);
      }).toList();
    });

    yield* Rx.combineLatest2<List<Trip>, List<Trip>, List<Trip>>(
      individualTripsStream,
      groupTripsStream,
      (individualTrips, groupTrips) {
        final allTrips = [...individualTrips, ...groupTrips];
        allTrips.sort(
            (a, b) => b.updatedAt?.compareTo(a.updatedAt ?? DateTime(0)) ?? 0);
        return allTrips;
      },
    );
  }

  Future<Trip> createExpenseForTrip(String tripUid, Expense expense) async {
    DocumentReference tripRef =
        _firestore.collection(tripCollection).doc(tripUid);
    DocumentReference expenseRef =
        _firestore.collection(expenseCollection).doc();

    DocumentSnapshot tripSnapshot = await tripRef.get();
    Trip trip = Trip.fromJson(tripSnapshot.data() as Map<String, dynamic>);

    QuerySnapshot expensesSnapshot = await _firestore
        .collection(expenseCollection)
        .where(FieldPath.documentId, whereIn: trip.expenseUids)
        .get();

    double totalBudgets = expensesSnapshot.docs.fold(0.0, (sum, doc) {
      Expense existingExpense =
          Expense.fromJson(doc.data() as Map<String, dynamic>);
      return sum + existingExpense.budget;
    });

    if (totalBudgets + expense.budget > trip.budget) {
      throw Exception('Total expenses\' budget exceed the trip budget');
    }

    expense.uid = expenseRef.id;

    await expenseRef.set(expense.toJson());

    await tripRef.update({
      'expenseUids': FieldValue.arrayUnion([expenseRef.id]),
    });

    return tripRef
        .get()
        .then((doc) => Trip.fromJson(doc.data() as Map<String, dynamic>));
  }

  Future<void> updateExpense(
      String tripUid, String expenseUid, Expense expense) async {
    DocumentReference tripRef =
        _firestore.collection(tripCollection).doc(tripUid);
    DocumentReference expenseRef =
        _firestore.collection(expenseCollection).doc(expenseUid);

    DocumentSnapshot tripSnapshot = await tripRef.get();
    Trip trip = Trip.fromJson(tripSnapshot.data() as Map<String, dynamic>);

    QuerySnapshot expensesSnapshot = await _firestore
        .collection(expenseCollection)
        .where(FieldPath.documentId, whereIn: trip.expenseUids)
        .get();

    double totalBudgets = expensesSnapshot.docs.fold(0.0, (sum, doc) {
      Expense existingExpense =
          Expense.fromJson(doc.data() as Map<String, dynamic>);
      return sum + existingExpense.budget;
    });

    DocumentSnapshot existingExpenseSnapshot = await expenseRef.get();
    Expense existingExpense = Expense.fromJson(
        existingExpenseSnapshot.data() as Map<String, dynamic>);
    totalBudgets -= existingExpense.budget;

    if (totalBudgets + expense.budget > trip.budget) {
      throw Exception('Total expenses\' budget exceed the trip budget');
    }

    await expenseRef.update(expense.toJson());
  }

  Stream<List<Expense>> getExpenses(List<String> expenseUids) {
    if (expenseUids.isEmpty) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection(expenseCollection)
        .where(FieldPath.documentId, whereIn: expenseUids);

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

  Future<Trip> setPersonalBudget(String tripUid, double budget) async {
    final userId = await _authService.currentUser.then((u) => u.uid);
    DocumentReference tripRef =
        _firestore.collection(tripCollection).doc(tripUid);

    DocumentSnapshot tripSnapshot = await tripRef.get();
    Trip trip = Trip.fromJson(tripSnapshot.data() as Map<String, dynamic>);

    Participant? participant = trip.participants?.firstWhere(
      (p) => p.participantUid == userId,
      orElse: () => throw Exception('Participant not found'),
    );

    if (participant != null) {
      participant.personalBudget = budget;
      await tripRef.update({
        'participants': trip.participants?.map((p) => p.toJson()).toList(),
      });
    }

    return tripRef
        .get()
        .then((doc) => Trip.fromJson(doc.data() as Map<String, dynamic>));
  }

  Future<Trip> addOrUpdatePersonalExpense(
      String tripUid, Expense expense) async {
    final userId = await _authService.currentUser.then((u) => u.uid);
    DocumentReference tripRef =
        _firestore.collection(tripCollection).doc(tripUid);
    DocumentReference expenseRef =
        _firestore.collection(expenseCollection).doc(expense.uid);

    DocumentSnapshot tripSnapshot = await tripRef.get();
    Trip trip = Trip.fromJson(tripSnapshot.data() as Map<String, dynamic>);

    Participant? participant = trip.participants?.firstWhere(
      (p) => p.participantUid == userId,
      orElse: () => throw Exception('Participant not found'),
    );

    if (participant != null) {
      if (participant.personalBudget == null) {
        throw Exception('Personal budget is not set');
      }
      double personalBudget = participant.personalBudget!;

      List<String> expenseUids = participant.expenseUids ?? [];
      QuerySnapshot expensesSnapshot;

      if (expenseUids.isEmpty) {
        expensesSnapshot = await _firestore.collection(expenseCollection).get();
      } else {
        expensesSnapshot = await _firestore
            .collection(expenseCollection)
            .where(FieldPath.documentId, whereIn: expenseUids)
            .get();
      }

      double totalExpenses = expensesSnapshot.docs.fold(0.0, (sum, doc) {
        Expense existingExpense =
            Expense.fromJson(doc.data() as Map<String, dynamic>);
        return sum + existingExpense.budget;
      });

      if (expense.uid != null) {
        DocumentSnapshot existingExpenseSnapshot = await expenseRef.get();
        Expense existingExpense = Expense.fromJson(
            existingExpenseSnapshot.data() as Map<String, dynamic>);
        totalExpenses -= existingExpense.budget;
      }

      if (totalExpenses + expense.budget > personalBudget) {
        throw Exception('Total expenses exceed the personal budget');
      }

      if (expense.uid == null) {
        expense.uid = expenseRef.id;
        await expenseRef.set(expense.toJson());
      } else {
        await expenseRef.update(expense.toJson());
      }

      participant.expenseUids = (participant.expenseUids ?? [])
        ..add(expense.uid!);
      await tripRef.update({
        'participants': trip.participants?.map((p) => p.toJson()).toList(),
      });
    }

    return tripRef
        .get()
        .then((doc) => Trip.fromJson(doc.data() as Map<String, dynamic>));
  }
}
