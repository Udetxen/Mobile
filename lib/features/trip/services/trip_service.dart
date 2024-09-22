import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/shared/config/constants.dart';
import 'package:udetxen/shared/types/models/expense.dart';
import 'package:udetxen/shared/types/models/expense_category.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/types/models/user.dart';
import 'package:udetxen/shared/types/models/venue.dart';

import '../models/trip_status.dart';

class TripService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  TripService(this._firestore, this._authService);

  Future<String> createTrip(Trip trip) async {
    final docRef = _firestore.collection(tripCollection).doc();
    trip.uid = docRef.id;
    trip.creatorUid = await _authService.currentUser.then((u) => u.uid);
    trip.endDate = trip.startDate?.add(Duration(days: trip.duration));
    trip.updatedAt = DateTime.now();

    if (trip.type == 'group') {
      trip.participants = [
        Participant(participantUid: trip.creatorUid!),
        ...?trip.participants,
      ];
      trip.participantUids =
          trip.participants?.map((p) => p.participantUid).toList();
    } else if (trip.type == 'individual') {
      trip.participantUids = null;
      trip.participants = null;
    }

    await docRef.set(trip.toJson());

    return docRef.id;
  }

  Future<Trip> forkTrip(Trip trip) async {
    final docRef = _firestore.collection(tripCollection).doc();

    trip.uid = docRef.id;
    trip.creatorUid = await _authService.currentUser.then((u) => u.uid);
    trip.endDate = trip.startDate?.add(Duration(days: trip.duration));
    trip.updatedAt = DateTime.now();

    if (trip.type == 'group') {
      trip.participants = [
        Participant(participantUid: trip.creatorUid!),
      ];
    }

    if (trip.expenseUids != null && trip.expenseUids!.isNotEmpty) {
      final newExpenseUids =
          await Future.wait(trip.expenseUids!.map((uid) async {
        final expenseDoc =
            await _firestore.collection(expenseCollection).doc(uid).get();
        final expenseData = expenseDoc.data();
        if (expenseData != null) {
          final newExpenseDoc = _firestore.collection(expenseCollection).doc();
          final newExpense = Expense.fromJson(expenseData);
          newExpense.uid = newExpenseDoc.id;
          await newExpenseDoc.set(newExpense.toJson());
          return newExpense.uid;
        }
        return null;
      }).toList());
      trip.expenseUids = newExpenseUids.whereType<String>().toList();
    }

    await docRef.set(trip.toJson());

    return trip;
  }

  Future<String> updateForkedTrip(Trip trip) async {
    trip.updatedAt = DateTime.now();

    if (trip.type == 'group') {
      if (trip.participants == null ||
          !trip.participants!.any((p) => p.participantUid == trip.creatorUid)) {
        trip.participants = [
          Participant(participantUid: trip.creatorUid!),
          ...?trip.participants,
        ];
      }
      trip.participantUids =
          trip.participants?.map((p) => p.participantUid).toList();
    } else if (trip.type == 'individual') {
      trip.participantUids = null;
      trip.participants = null;
    }

    await _firestore
        .collection(tripCollection)
        .doc(trip.uid)
        .update(trip.toJson());

    return trip.uid!;
  }

  Future<String> updateTrip(Trip trip) {
    trip.updatedAt = DateTime.now();

    return _firestore
        .collection(tripCollection)
        .doc(trip.uid)
        .update(trip.toJson())
        .then((_) => trip.uid!);
  }

  Future<void> deleteTrip(String tripId) async {
    await _firestore.collection(tripCollection).doc(tripId).delete();
  }

  Future<Stream<List<Trip>>> getUserTrips(
      {String? userUid, TripStatus? status}) async {
    final userId = userUid ?? await _authService.currentUser.then((u) => u.uid);

    Query individualQuery = _firestore
        .collection(tripCollection)
        .where('type', isEqualTo: 'individual')
        .where('creatorUid', isEqualTo: userId)
        .orderBy('startDate');

    if (status != null) {
      final now = Timestamp.now();
      switch (status) {
        case TripStatus.notStarted:
          individualQuery =
              individualQuery.where('startDate', isGreaterThan: now);
          break;

        case TripStatus.active:
          individualQuery = individualQuery
              .where('startDate', isLessThanOrEqualTo: now)
              .where('endDate', isGreaterThanOrEqualTo: now);
          break;

        case TripStatus.completed:
          individualQuery = individualQuery.where('endDate', isLessThan: now);
          break;
      }
    }

    final individualTripsStream =
        individualQuery.snapshots().asyncMap((snapshot) async {
      final trips = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data()! as Map<String, dynamic>;

        data['departure'] = await getVenue(data['departureUid'])
            .then((value) => value.toJson());
        data['destination'] = await getVenue(data['destinationUid'])
            .then((value) => value.toJson());

        return Trip.fromJson(data);
      }).toList());
      return trips;
    });

    Query groupQuery = _firestore
        .collection(tripCollection)
        .where('type', isEqualTo: 'group')
        .where('participantUids', arrayContains: userId);

    if (status != null) {
      final now = Timestamp.now();
      switch (status) {
        case TripStatus.notStarted:
          groupQuery = groupQuery.where('startDate', isGreaterThan: now);
          break;

        case TripStatus.active:
          groupQuery = groupQuery
              .where('startDate', isLessThanOrEqualTo: now)
              .where('endDate', isGreaterThanOrEqualTo: now);
          break;

        case TripStatus.completed:
          groupQuery = groupQuery.where('endDate', isLessThan: now);
          break;
      }
    }

    final groupTripsStream = groupQuery.snapshots().asyncMap((snapshot) async {
      final trips = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data()! as Map<String, dynamic>;

        data['departure'] = await getVenue(data['departureUid'])
            .then((value) => value.toJson());
        data['destination'] = await getVenue(data['destinationUid'])
            .then((value) => value.toJson());

        return Trip.fromJson(data);
      }).toList());
      return trips;
    });

    return Rx.combineLatest2<List<Trip>, List<Trip>, List<Trip>>(
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

  Stream<Trip> getTrip(String tripId) {
    return _firestore
        .collection(tripCollection)
        .doc(tripId)
        .snapshots()
        .asyncMap((snapshot) async {
      final data = snapshot.data()!;

      data['expenses'] = await getExpenses(data['expenseUids'] != null
              ? data['expenseUids'].cast<String>()
              : [])
          .then((value) => value.map((e) => e.toJson()).toList());
      data['departure'] =
          await getVenue(data['departureUid']).then((value) => value.toJson());
      data['destination'] = await getVenue(data['destinationUid'])
          .then((value) => value.toJson());

      if (data['participants'] != null) {
        data['participants'] = await Future.wait(
          (data['participants'] as List<dynamic>).map((participantData) async {
            final participant = Participant.fromJson(participantData);

            participant.expenses = participant.expenseUids != null
                ? await getExpenses(participant.expenseUids!)
                : [];

            return participant.toJson();
          }).toList(),
        );
      }

      return Trip.fromJson(data);
    });
  }

  Stream<List<Venue>> getVenues({String? name}) {
    if (name != null && name.isNotEmpty) {
      String searchLower = name.toLowerCase();
      String searchUpper = name.toUpperCase();

      return _firestore
          .collection(venueCollection)
          .where('name', isGreaterThanOrEqualTo: searchLower)
          .where('name', isLessThanOrEqualTo: '$searchUpper\uf8ff')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Venue.fromJson(data);
        }).toList();
      });
    } else {
      return _firestore.collection(venueCollection).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Venue.fromJson(data);
        }).toList();
      });
    }
  }

  Future<void> addParticipant(String tripId, String participantUid) async {
    final participantData = Participant(participantUid: participantUid);

    await _firestore.collection(tripCollection).doc(tripId).update({
      'participants': FieldValue.arrayUnion([participantData.toJson()])
    });
  }

  Stream<List<User>> getUsers(String tripId, {String? email}) {
    return _firestore
        .collection(userCollection)
        .where('email', isEqualTo: email)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return User.fromJson(data);
      }).toList();
    });
  }

  Future<Venue> getVenue(String venueId) async {
    final doc = await _firestore.collection(venueCollection).doc(venueId).get();
    final data = doc.data();
    return Venue.fromJson(data!);
  }

  Future<List<Expense>> getExpenses(List<String> expenseUids) async {
    final expenses = await Future.wait(expenseUids.map((uid) async {
      final doc = await _firestore.collection(expenseCollection).doc(uid).get();
      final data = doc.data();
      final expense = Expense.fromJson(data!);

      // Fetch and set the categories for the expense
      if (expense.categoryUids.isNotEmpty) {
        final categories =
            await Future.wait(expense.categoryUids.map((categoryUid) async {
          final categoryDoc = await _firestore
              .collection(expenseCategoryCollection)
              .doc(categoryUid)
              .get();
          final categoryData = categoryDoc.data();
          if (categoryData != null) {
            return ExpenseCategory.fromJson(categoryData);
          }
          return null;
        }).toList());
        expense.categories = categories.cast<ExpenseCategory>();
      }

      return expense;
    }).toList());

    return expenses;
  }
}
