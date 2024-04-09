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
  final String password;

  AuthentificationParams({required this.email, required this.password});
  
}

class RegisterParams {
  final String email;
  final String pseudo;
  final String password;
  final String confirmPassword;
  final String numero;

  const RegisterParams({required this.password, required this.confirmPassword, required this.numero, required this.email, required this.pseudo});
}
