import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/errors/firebase_exceptions.dart';
import 'package:flutter_application_1/core/params/params.dart';

abstract class ParametreRemoteDataSource {
  Future<void> deconnexion({required ParametreParams parametreParams});
}

class ParametreRemoteDataSourceImpl implements ParametreRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  ParametreRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<void> deconnexion({required ParametreParams parametreParams}) async {
    try {
      firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw FireBaseException(errMessage: e.code);
    }
  }
}
