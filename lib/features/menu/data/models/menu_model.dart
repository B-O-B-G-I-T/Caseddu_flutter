import '../../../../../core/constants/constants.dart';
import '../../domain/entities/menu_entity.dart';

class MenuModel extends MenuEntity {
  const MenuModel({
    required String menu,
  }) : super(
          menu: menu,
        );

  factory MenuModel.fromJson({required Map<String, dynamic> json}) {
    return MenuModel(
      menu: json[kMenu],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kMenu: menu,
    };
  }
}
