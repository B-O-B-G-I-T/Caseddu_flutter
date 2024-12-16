import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/firebase_exceptions.dart';
import '../../../../core/params/params.dart';
import '../../domain/entities/parameter_entity.dart';

abstract class ParametreRemoteDataSource {
  Future<void> deconnexion();
  Future<ParameterEntity> update({required ParameterParams parametreParams});
}

class ParametreRemoteDataSourceImpl implements ParametreRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  ParametreRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<void> deconnexion() async {
    try {
      firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw FireBaseException(errMessage: e.code);
    }
  }

  @override
  Future<ParameterEntity> update({required ParameterParams parametreParams}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        if (parametreParams.displayName != "" && parametreParams.displayName != user.displayName) {
          await user.updateDisplayName(parametreParams.displayName);
        }
        if (parametreParams.email.isNotEmpty && parametreParams.email != user.email) {
          await user.verifyBeforeUpdateEmail(parametreParams.email);
        }
        if (parametreParams.password != "") {
          await user.updatePassword(parametreParams.password!);
        }

        ParameterEntity parameter = ParameterEntity.fromUser(user);
        parameter.description = parametreParams.description;

        parameter.pathImageProfile = parametreParams.pathImageProfile;
        return parameter;
      } else {
        throw FireBaseException(errMessage: "Utilisateur non trouvé");
      }
    } catch (error) {
      throw FireBaseException(errMessage: error.toString());
    }
  }
}
