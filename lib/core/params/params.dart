class NoParams {}

class TemplateParams {}

class PokemonParams {
  final String id;
  const PokemonParams({
    required this.id,
  });
}

class AuthentificationParams {
  final String email;
  final String? pseudo;
  final String? password;
  final String? confirmPassword;
  final String? numero;
  AuthentificationParams({required this.email, this.password, this.confirmPassword, this.numero, this.pseudo });
  
}

class ParametreParams{
  
}

class MenuParams{
  
}
