import 'package:dartz/dartz.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../entities/parameter_entity.dart';


abstract class ParametreRepository {
  Future<Either<Failure, void>> deconnexion();
  Future<Either<Failure, String>>  selectedImageProfile(AssetEntity image);
  Future<Either<Failure, String?>>  getSavedProfileImage();
  Future<Either<Failure, String?>>  getDetailUser();
  Future<Either<Failure, void>>  insertDetailUser(String? insertUserDetail);
  Future<Either<Failure, ParameterEntity>> update({
    required ParameterParams parametreParams,
  });
}
