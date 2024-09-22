import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:udetxen/shared/config/constants.dart';
import 'package:udetxen/shared/types/models/venue.dart';

class DashboardVenueService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DashboardVenueService(this._firestore, this._storage);

  Stream<List<Venue>> getVenues({String? name}) {
    Query query = _firestore.collection(venueCollection);
    if (name != null && name.isNotEmpty) {
      query = query.where('name', isEqualTo: name);
    }
    return query.snapshots().asyncMap((snapshot) async {
      final venues = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        return Venue.fromJson(data as Map<String, dynamic>);
      }).toList());
      return venues;
    });
  }

  Future<Venue> getVenueDetail(String venueId) async {
    final doc = await _firestore.collection(venueCollection).doc(venueId).get();
    if (!doc.exists) {
      throw Exception('Venue not found');
    }
    return Venue.fromJson(doc.data()!);
  }

  Future<Venue> addVenue(Venue venue) async {
    final docRef = _firestore.collection(venueCollection).doc();
    venue.uid = docRef.id;

    await docRef.set(venue.toJson());
    final doc = await docRef.get();
    return Venue.fromJson(doc.data()!);
  }

  Future<void> updateVenue(Venue venue) async {
    if (venue.uid == null) {
      throw Exception('Venue UID must not be null for update.');
    }

    await _firestore
        .collection(venueCollection)
        .doc(venue.uid)
        .update(venue.toJson());
  }

  Future<void> deleteVenueImage(String venueId, String imageUrl) async {
    final ref = _storage.refFromURL(imageUrl);
    await ref.delete();

    final doc = await _firestore.collection(venueCollection).doc(venueId).get();
    if (!doc.exists) {
      throw Exception('Venue not found');
    }

    final venue = Venue.fromJson(doc.data()!);
    venue.imageUrls.remove(imageUrl);

    await _firestore.collection(venueCollection).doc(venueId).update({
      'imageUrls': venue.imageUrls,
    });
  }

  Future<void> uploadVenueImage(String venueId, File imageFile) async {
    final ref = _storage
        .ref()
        .child('venues/$venueId/${imageFile.path.split('/').last}');
    await ref.putFile(imageFile);
    final imageUrl = await ref.getDownloadURL();

    final doc = await _firestore.collection(venueCollection).doc(venueId).get();
    if (!doc.exists) {
      throw Exception('Venue not found');
    }

    final venue = Venue.fromJson(doc.data()!);
    venue.imageUrls.add(imageUrl);

    await _firestore.collection(venueCollection).doc(venueId).update({
      'imageUrls': venue.imageUrls,
    });
  }

  Stream<Venue> getVenue(String venueId) {
    return _firestore
        .collection(venueCollection)
        .doc(venueId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Venue not found');
      }
      return Venue.fromJson(snapshot.data()!);
    });
  }

  Future<void> deleteVenue(String venueId) async {
    final doc = await _firestore.collection(venueCollection).doc(venueId).get();
    if (!doc.exists) {
      throw Exception('Venue not found');
    }

    final venue = Venue.fromJson(doc.data()!);
    for (String imageUrl in venue.imageUrls) {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    }

    await _firestore.collection(venueCollection).doc(venueId).delete();
  }
}
