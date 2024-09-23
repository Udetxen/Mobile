import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udetxen/shared/types/models/user.dart' as user_model;
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/shared/types/failure.dart';
import 'package:udetxen/shared/types/response.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileService {
  final AuthService _authService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ProfileService(this._auth, this._firestore, this._authService, this._storage);

  Future<Response<user_model.User>> updateUserProfile(
      user_model.User user, File? imageFile) async {
    try {
      if (imageFile != null) {
        if (user.photoURL != null && user.photoURL!.isNotEmpty) {
          final oldImageRef = _storage.refFromURL(user.photoURL!);
          await oldImageRef.delete();
        }

        final storageRef = _storage.ref().child('user_photos/${user.uid}');
        final uploadTask = await storageRef.putFile(imageFile);
        final photoUrl = await uploadTask.ref.getDownloadURL();
        user.photoURL = photoUrl;
      }

      await _auth.currentUser?.updateDisplayName(user.displayName);
      await _auth.currentUser?.updatePhotoURL(user.photoURL);

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
