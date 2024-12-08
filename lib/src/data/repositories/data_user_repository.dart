import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:st/src/data/exceptions/invalid_email_exception.dart';
import 'package:st/src/data/exceptions/invalid_login_exception.dart';
import 'package:st/src/data/exceptions/unavailable_email_exception.dart';
import 'package:st/src/data/exceptions/weak_password_exception.dart';
import 'package:st/src/domain/entities/user.dart' as ent;
import 'dart:async';

import 'package:st/src/domain/repositories/user_repository.dart';

class DataUserRepository implements UserRepository {
  static final _instance = DataUserRepository._internal();
  DataUserRepository._internal();
  factory DataUserRepository() => _instance;

  static final _firestore = FirebaseFirestore.instance;
  static final _firebaseAuth = FirebaseAuth.instance;

  ent.User? user;

  bool? isEmailavailableForRegister;
  bool? userCredentialsAreFoundForLogin;
  bool? isPasswordCorrectForLogin;

  @override
  Future<ent.User> getUser() async {
    try {
      if (user != null) return user!;

      final snapshot = await _firestore.collection("users").doc(_firebaseAuth.currentUser!.uid).get();

      user = ent.User.fromJson(snapshot.data()!, _firebaseAuth.currentUser!.uid);

      return user!.copyWith();
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  @override
  Future<void> registerUser(ent.User user, String password) async {
    late final credential;
    try {
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );
      isEmailavailableForRegister = true;

      await _firestore.collection('users').doc(credential.user!.uid).set(user.toJson());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw UnavailableEmailException();
      } else if (e.code == 'weak-password') {
        throw WeakPasswordException();
      }
    }
  }

  @override
  Future<bool> checkIfUsernameIsAvaliable(String username) async {
    final x = await _firestore.collection('users').where("username", isEqualTo: username).get();

    if (x.size == 0) return true;
    return false;
  }

  Future<bool?> getIfEmailAvaliableForRegister() async {
    return isEmailavailableForRegister;
  }

  Future<bool?> getUserCredentialsAreFoundForLogin() async {
    return userCredentialsAreFoundForLogin;
  }

  Future<bool?> getIsPasswordCorrectForLogin() async {
    return isPasswordCorrectForLogin;
  }

  @override
  Future<void> logIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw InvalidLoginException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailException();
      } else {
        print(e);
      }
    }
  }

  @override
  Future<void> updateProfilePicture(String pictureUrl) async {
    try {
      await _firestore.collection('users').doc(user!.id).update({
        'profilePictureUrl': pictureUrl,
      });
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }
}
