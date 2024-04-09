import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../../core/params/params.dart';
import '../models/authentification_model.dart';

abstract class AuthentificationRemoteDataSource {
  Future<AuthentificationModel> getAuthentification({required AuthentificationParams authentificationParams});
  Future<AuthentificationModel> createUser({required AuthentificationParams authentificationParams});
  Future<void> changeMotDePasse({required AuthentificationParams authentificationParams});
}

class AuthentificationRemoteDataSourceImpl implements AuthentificationRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  AuthentificationRemoteDataSourceImpl({required this.firebaseAuth});

  Stream<User?> get authStateChange => firebaseAuth.authStateChanges();

  @override
  Future<AuthentificationModel> getAuthentification({required AuthentificationParams authentificationParams}) async {
    try {
      final response = await firebaseAuth.signInWithEmailAndPassword(
        email: authentificationParams.email,
        password: authentificationParams.password!,
      );

      return AuthentificationModel.fromJson(user: response.user!);
    } on FirebaseAuthException catch (e) {
      throw FireBaseException(errMessage: e.code);
    }
  }

  @override
  Future<AuthentificationModel> createUser({required AuthentificationParams authentificationParams}) async {
    try {
      if (authentificationParams.confirmPassword == authentificationParams.password) {
        UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: authentificationParams.email, password: authentificationParams.password!);

        User? user = result.user;
        user?.updateDisplayName(authentificationParams.pseudo);
        //user?.updatePhoneNumber(phone);
        return AuthentificationModel.fromJson(user: user!);
      } else {
        throw Exception("L'utilisateur ne peut pas etre créé");
      }
    } on FirebaseAuthException catch (e) {
      // print(e.code);
      throw FireBaseException(errMessage: e.code);
    }
  }
  
  @override
  Future<void> changeMotDePasse({required AuthentificationParams authentificationParams}) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: authentificationParams.email);
          
    } on FirebaseAuthException catch (e) {
      // print(e);
      throw FireBaseException(errMessage: e.code);
    }
  
  }

}
