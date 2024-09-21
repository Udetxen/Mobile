import 'package:udetxen/shared/types/models/trip.dart';

class Venue {
  String? uid;
  String name;
  List<String> imageUrls;
  List<Trip>? plannedTrips;

  Venue({
    this.uid,
    required this.name,
    required this.imageUrls,
    this.plannedTrips,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      uid: json['uid'],
      name: json['name'],
      imageUrls: List<String>.from(json['imageUrls']),
      plannedTrips: json['plannedTrips'] != null
          ? List<Trip>.from(
              json['plannedTrips'].map((trip) => Trip.fromJson(trip)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'imageUrls': imageUrls,
    };
  }
}
