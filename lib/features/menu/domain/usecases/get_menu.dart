import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

class GetMenu {
  final MenuRepository menuRepository;

  GetMenu({required this.menuRepository});

  Future<Either<Failure, MenuEntity>> call({
    required MenuParams menuParams,
  }) async {
    return await menuRepository.getMenu(menuParams: menuParams);
  }
}
