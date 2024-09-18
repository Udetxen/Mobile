import 'trip.dart';

class User {
  String uid;
  String? displayName;
  String? bio;
  String? photoURL;
  String? email;
  String role;
  List<Trip>? trips;

  bool get isAdmin => role == 'ADMIN';
  bool get isUser => role == 'USER';

  User({
    required this.uid,
    this.displayName,
    this.bio,
    this.photoURL,
    this.email,
    this.role = 'USER',
    this.trips,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      displayName: json['displayName'],
      bio: json['bio'],
      photoURL: json['photoURL'],
      email: json['email'],
      role: json['role'] ?? 'USER',
      trips: json['trips'] != null
          ? (json['trips'] as List).map((i) => Trip.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'bio': bio,
      'photoURL': photoURL,
      'email': email,
      'role': role,
      'trips': trips?.map((trip) => trip.toJson()).toList(),
    };
  }
}
