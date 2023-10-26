import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/features/auth/data/models/register_model.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/params/params.dart';
import '../models/authentification_model.dart';

abstract class AuthentificationRemoteDataSource {
  Future<AuthentificationModel> getAuthentification({required AuthentificationParams authentificationParams});
  Future<RegisterModel> createUser({required RegisterParams registerParams});
}

class AuthentificationRemoteDataSourceImpl implements AuthentificationRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthentificationRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<AuthentificationModel> getAuthentification({required AuthentificationParams authentificationParams}) async {
    try {
      final response = await firebaseAuth.signInWithEmailAndPassword(
        email: authentificationParams.email,
        password: authentificationParams.password,
      );

      return AuthentificationModel.fromJson(user: response.user!);
    } on FirebaseException catch (e) {
      print(e);
      throw FireBaseException(errMessage: e.code);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  @override
  Future<RegisterModel> createUser({required RegisterParams registerParams}) async {
    try {
      if (registerParams.confirmPassword == registerParams.password) {
        UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: registerParams.email, password: registerParams.password);

        User? user = result.user;
        user?.updateDisplayName(registerParams.pseudo);
        //user?.updatePhoneNumber(phone);
        return RegisterModel.fromJson(user: user!);
      } else {
        throw Exception("l'utilisateur ne peut pas etre créé");
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      throw FireBaseException(errMessage: e.code);
    }
  }
  // if (response == 200) {
  //   return AuthentificationModel.fromJson(json: response.data);
  // } else {
  //   throw ServerException();
  // }
}
