import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/features/authentification/domain/entities/identifiant_entity.dart';
import 'package:flutter_application_1/features/authentification/domain/entities/nouveau_identifiant_entity.dart';

class AuthDataRemote {
  final FirebaseAuth _firebaseAuth;

  AuthDataRemote({required FirebaseAuth firebaseAuth}) : _firebaseAuth = firebaseAuth;

  Stream<User?> get authStateChange => _firebaseAuth.authStateChanges();

  Future signIn({required IdentifiantEntity identifiant}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: identifiant.email,
        password: identifiant.password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future signup({required NouveauIdentifiantEntity nouveauIdentifiant}) async {
    // TODO avoir le numéro de la personne dans FirebaseAuth.instance

    //String phone = _cellPhone.text.trim();

    try {
      if (nouveauIdentifiant.confirmPassword == nouveauIdentifiant.password) {
        UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: nouveauIdentifiant.email, password: nouveauIdentifiant.password);

        User? user = result.user;
        user?.updateDisplayName(nouveauIdentifiant.pseudo);
        //user?.updatePhoneNumber(phone);
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }
}
