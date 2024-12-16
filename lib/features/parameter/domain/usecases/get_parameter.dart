import 'package:dartz/dartz.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../entities/parameter_entity.dart';
import '../repositories/parameter_repository.dart';

class GetParametre {
  final ParametreRepository parametreRepository;

  GetParametre({required this.parametreRepository});

  Future<Either<Failure, void>> call() async {
    return await parametreRepository.deconnexion();
  }
  Future<Either<Failure, String>> selectedImageProfile(AssetEntity image) async {
    return await parametreRepository.selectedImageProfile(image);
  }
  Future<Either<Failure, String?>> getSavedProfileImage() async {
    return await parametreRepository.getSavedProfileImage();
  }
  
  Future<Either<Failure, String?>> getDetailUser() async {
    return await parametreRepository.getDetailUser();
  }

  Future<Either<Failure, void>> insertDetailUser(String? insertUserDetail) async {
    return await parametreRepository.insertDetailUser(insertUserDetail);
  }
  Future<Either<Failure, ParameterEntity>> update({
    required ParameterParams parametreParams,
  }) async {
    return await parametreRepository.update(parametreParams: parametreParams);
  }
}
