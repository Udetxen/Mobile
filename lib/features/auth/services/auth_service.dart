import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udetxen/shared/types/failure.dart';
import 'package:udetxen/shared/types/response.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  final _userController = StreamController<UserModel?>.broadcast();

  AuthService(this._auth, this._firestore, this._googleSignIn) {
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        _userController.add(null);
      } else {
        final userModel = await getUserData(user);
        _userController.add(userModel);
      }
    });
  }

  Future<UserModel?> get currentUser async =>
      await getUserData(_auth.currentUser);

  Stream<UserModel?> get userStream => _userController.stream;

  Future<void> updateUserInStream() async {
    final user = _auth.currentUser;
    if (user != null) {
      final updatedUser = await getUserData(user);
      _userController.add(updatedUser);
    }
  }

  Future<UserModel> getUserData(User? user) async {
    final userDoc = await _firestore.collection('users').doc(user!.uid).get();

    final userModel = UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      bio: userDoc.data()?['bio'],
      role: userDoc.data()?['role'],
    );

    return userModel;
  }

  Future<Response<UserModel>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Response(
            failure: Failure(
          message: 'Google sign-in aborted',
          userFriendlyMessage:
              'Google sign-in was cancelled. Please try again.',
        ));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final userModel = await getUserData(userCredential.user);

      return Response(data: userModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage:
                'An account already exists with a different credential. Please use one of the sign-in methods associated with this email.',
          ),
        );
      } else if (e.code == 'invalid-credential') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage:
                'The credential is invalid or has expired. Please try again.',
          ),
        );
      } else if (e.code == 'operation-not-allowed') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage:
                'This type of account is not enabled. Please enable it in the Firebase Console.',
          ),
        );
      } else if (e.code == 'user-disabled') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage:
                'The user corresponding to the given credential has been disabled.',
          ),
        );
      } else if (e.code == 'user-not-found') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage: 'No user found with the given email.',
          ),
        );
      } else if (e.code == 'wrong-password') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage: 'The password is invalid for the given email.',
          ),
        );
      } else if (e.code == 'invalid-verification-code') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage: 'The verification code is invalid.',
          ),
        );
      } else if (e.code == 'invalid-verification-id') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage: 'The verification ID is invalid.',
          ),
        );
      } else {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage: 'Please provide all the fields',
          ),
        );
      }
    } catch (e) {
      return Response(
          failure: Failure(
        message: e.toString(),
        userFriendlyMessage:
            'An error occurred during Google sign-in. Please try again.',
      ));
    }
  }

  Future<Response<UserModel>> signInWithEmail(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final userModel = await getUserData(userCredential.user);

      return Response(data: userModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage: 'The email address is not valid.',
          ),
        );
      } else if (e.code == 'user-disabled') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage:
                'The user corresponding to the given email has been disabled.',
          ),
        );
      } else if (e.code == 'user-not-found') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage: 'No user found with the given email.',
          ),
        );
      } else if (e.code == 'wrong-password' ||
          e.code == 'INVALID_LOGIN_CREDENTIALS' ||
          e.code == 'invalid-credential') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage: 'The password is invalid for the given email.',
          ),
        );
      } else if (e.code == 'too-many-requests') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage:
                'Too many requests. Please wait and try again later.',
          ),
        );
      } else if (e.code == 'user-token-expired') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage:
                'Your session has expired. Please sign in again.',
          ),
        );
      } else if (e.code == 'network-request-failed') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage:
                'Network error. Please check your internet connection and try again.',
          ),
        );
      } else if (e.code == 'operation-not-allowed') {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage:
                'Email/password accounts are not enabled. Please enable them in the Firebase Console.',
          ),
        );
      } else {
        return Response(
          failure: Failure(
            message: e.toString(),
            userFriendlyMessage: 'Please provide all the fields',
          ),
        );
      }
    } catch (e) {
      return Response(
          failure: Failure(
        message: e.toString(),
        userFriendlyMessage:
            'An error occurred during email sign-in. Please check your credentials and try again.',
      ));
    }
  }

  Future<Response<UserModel>> registerWithEmail(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email,
        displayName: userCredential.user!.displayName,
      );

      await _firestore
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toJson());

      return Response(data: userModel);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage:
                  'An account already exists with the given email address.',
            ),
          );
        case 'invalid-email':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage: 'The email address is not valid.',
            ),
          );
        case 'operation-not-allowed':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage:
                  'Email/password accounts are not enabled. Please enable them in the Firebase Console.',
            ),
          );
        case 'weak-password':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage: 'The password is not strong enough.',
            ),
          );
        case 'too-many-requests':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage:
                  'Too many requests. Please wait and try again later.',
            ),
          );
        case 'user-token-expired':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage:
                  'Your session has expired. Please sign in again.',
            ),
          );
        case 'network-request-failed':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage:
                  'Network error. Please check your internet connection and try again.',
            ),
          );
        default:
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage: 'Please provide all the fields',
            ),
          );
      }
    } catch (e) {
      return Response(
        failure: Failure(
          message: e.toString(),
          userFriendlyMessage:
              'An error occurred during registration. Please try again.',
        ),
      );
    }
  }

  Future<Response<void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      return Response(data: null);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'auth/invalid-email':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage: 'The email address is not valid.',
            ),
          );
        case 'auth/missing-android-pkg-name':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage:
                  'An Android package name must be provided if the Android app is required to be installed.',
            ),
          );
        case 'auth/missing-continue-uri':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage:
                  'A continue URL must be provided in the request.',
            ),
          );
        case 'auth/missing-ios-bundle-id':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage:
                  'An iOS Bundle ID must be provided if an App Store ID is provided.',
            ),
          );
        case 'auth/invalid-continue-uri':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage:
                  'The continue URL provided in the request is invalid.',
            ),
          );
        case 'auth/unauthorized-continue-uri':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage:
                  'The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.',
            ),
          );
        case 'auth/user-not-found':
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage:
                  'No user found with the given email address.',
            ),
          );
        default:
          return Response(
            failure: Failure(
              message: e.toString(),
              userFriendlyMessage: 'Please provide all the fields',
            ),
          );
      }
    } catch (e) {
      return Response(
        failure: Failure(
          message: e.toString(),
          userFriendlyMessage:
              'An error occurred while sending the password reset email. Please try again.',
        ),
      );
    }
  }

  Future<Response<void>> signOut() async {
    try {
      await _auth.signOut();
      return Response(data: null);
    } catch (e) {
      return Response(
          failure: Failure(
        message: e.toString(),
        userFriendlyMessage:
            'An error occurred during sign-out. Please try again.',
      ));
    }
  }
}
