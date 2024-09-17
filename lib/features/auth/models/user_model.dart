class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String role;
  final String? bio;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.bio,
    this.role = 'USER',
  });

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      bio: data['bio'],
      role: data['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'bio': bio,
      'role': role,
    };
  }

  bool get isAdmin => role == 'ADMIN';
  bool get isUser => role == 'USER';
}
