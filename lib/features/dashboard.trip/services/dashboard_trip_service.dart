import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udetxen/shared/config/constants.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/types/models/venue.dart';

class DashboardTripService {
  final FirebaseFirestore _firestore;

  DashboardTripService(this._firestore);

  Stream<List<Trip>> getAvailableTrips() {
    return _firestore
        .collection(tripCollection)
        .where('creatorUid', isNull: true)
        .orderBy('startDate')
        .snapshots()
        .asyncMap((snapshot) async {
      final trips = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();

        data['departure'] = await getVenue(data['departureUid'])
            .then((value) => value.toJson());
        data['destination'] = await getVenue(data['destinationUid'])
            .then((value) => value.toJson());

        return Trip.fromJson(data);
      }).toList());
      return trips;
    });
  }

  Future<String> createOrUpdateAvailableTrip(Trip trip) async {
    if (trip.uid == null) {
      final docRef = _firestore.collection(tripCollection).doc();
      trip.uid = docRef.id;
      trip.creatorUid = null;
      trip.startDate = null;
      trip.updatedAt = DateTime.now();

      await docRef.set(trip.toJson());

      return docRef.id;
    } else {
      if (trip.creatorUid != null) {
        throw Exception('Cannot update a trip that has a creator.');
      }

      trip.updatedAt = DateTime.now();
      await _firestore
          .collection(tripCollection)
          .doc(trip.uid)
          .update(trip.toJson());

      return trip.uid!;
    }
  }

  Future<void> deleteTrip(String tripId) async {
    await _firestore.collection(tripCollection).doc(tripId).delete();
  }

  Future<Venue> getVenue(String venueId) async {
    final doc = await _firestore.collection(venueCollection).doc(venueId).get();
    final data = doc.data();
    return Venue.fromJson(data!);
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

  Future<void> deleteAvailableTrip(String tripId) async {
    await _firestore.collection(tripCollection).doc(tripId).delete();
  }
}
