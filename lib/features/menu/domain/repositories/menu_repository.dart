import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../entities/menu_entity.dart';


abstract class MenuRepository {
  Future<Either<Failure, MenuEntity>> getMenu({
    required MenuParams menuParams,
  });
}
