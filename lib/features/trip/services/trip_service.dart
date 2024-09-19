import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/shared/config/constants.dart';
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
    trip.creator = await _authService.currentUser;
    trip.endDate = trip.startDate?.add(Duration(days: trip.duration));
    trip.updatedAt = DateTime.now();

    if (trip.type == 'group') {
      trip.participants = [
        Participant(participantUid: trip.creator!.uid!),
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
    trip.creator = await _authService.currentUser;
    trip.endDate = trip.startDate?.add(Duration(days: trip.duration));
    trip.updatedAt = DateTime.now();

    if (trip.type == 'group') {
      trip.participants = [
        Participant(participantUid: trip.creator!.uid!),
      ];
    }
    await docRef.set(trip.toJson());

    return trip;
  }

  Future<String> updateForkedTrip(Trip trip) async {
    trip.updatedAt = DateTime.now();

    if (trip.type == 'group') {
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

  Future<void> deleteTrip(String tripId) async {
    await _firestore.collection(tripCollection).doc(tripId).delete();
  }

  Future<Stream<List<Trip>>> getUserTrips({TripStatus? status}) async {
    final currentUser = await _authService.currentUser;
    final userId = currentUser.uid;

    Query individualQuery = _firestore
        .collection(tripCollection)
        .where('type', isEqualTo: 'individual')
        .where('creator.uid', isEqualTo: userId)
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

    final individualTripsStream = individualQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data()!;
        return Trip.fromJson(data as Map<String, dynamic>);
      }).toList();
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

    final groupTripsStream = groupQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data()!;
        return Trip.fromJson(data as Map<String, dynamic>);
      }).toList();
    });

    individualTripsStream.listen((individualTrips) {
      print('Individual Trips:');
      individualTrips.forEach((trip) {
        print(trip.toJson());
      });
    });

    groupTripsStream.listen((groupTrips) {
      print('Group Trips:');
      groupTrips.forEach((trip) {
        print(trip.toJson());
      });
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
        .map((snapshot) {
      return Trip.fromJson(snapshot.data()!);
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

  Stream<List<User>> getUser(String tripId, {String? email}) {
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
}
