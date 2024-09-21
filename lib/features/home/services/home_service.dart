import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udetxen/shared/config/constants.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/types/models/venue.dart';

class HomeService {
  final FirebaseFirestore _firestore;
  HomeService(this._firestore);

  Stream<List<Trip>> availableTours() {
    return _firestore
        .collection(tripCollection)
        .where('creatorUid', isNull: true) //
        .snapshots()
        .asyncMap((snapshot) async {
      final tours = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();

        data['departure'] = await getVenue(data['departureUid'])
            .then((value) => value.toJson());
        data['destination'] = await getVenue(data['destinationUid'])
            .then((value) => value.toJson());

        return Trip.fromJson(data);
      }).toList());

      return tours;
    });
  }

  Stream<List<Venue>> popularVenues() {
    return _firestore.collection(venueCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Venue.fromJson(doc.data())).toList();
    });
  }

  Future<Venue> getVenue(String venueId) async {
    final doc = await _firestore.collection(venueCollection).doc(venueId).get();
    final data = doc.data();
    return Venue.fromJson(data!);
  }
}
