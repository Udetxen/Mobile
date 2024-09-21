class User {
  String? uid;
  String? displayName;
  String? bio;
  String? photoURL;
  String? email;
  String role;

  bool get isAdmin => role == 'ADMIN';
  bool get isUser => role == 'USER';

  User({
    this.uid,
    this.displayName,
    this.bio,
    this.photoURL,
    this.email,
    this.role = 'USER',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      displayName: json['displayName'],
      bio: json['bio'],
      photoURL: json['photoURL'],
      email: json['email'],
      role: json['role'] ?? 'USER',
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
    };
  }
}
