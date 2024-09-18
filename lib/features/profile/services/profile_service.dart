import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udetxen/shared/types/models/user.dart' as user_model;
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/shared/types/failure.dart';
import 'package:udetxen/shared/types/response.dart';

class ProfileService {
  final AuthService _authService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileService(this._auth, this._firestore, this._authService);

  Future<Response<user_model.User>> updateUserProfile(
      user_model.User user) async {
    try {
      await _auth.currentUser?.updateDisplayName(user.displayName);

      await _firestore.collection('users').doc(user.uid).update(user.toJson());

      final newUser = await _authService.getUserData(_auth.currentUser);

      if (newUser.toJson().toString() != user.toJson().toString()) {
        return Response(
          failure: Failure(
            message: 'User data mismatch',
            userFriendlyMessage:
                'Failed to update user profile. Please try again.',
          ),
        );
      }

      return Response(data: newUser);
    } catch (e) {
      return Response(
        failure: Failure(
          message: e.toString(),
          userFriendlyMessage: 'Failed to update user profile.',
        ),
      );
    }
  }
}
