/// [AuthArgs] is the object that encapsulate the user credential, for both, login and signup
/// 
/// *[email] represent the email of the new user
/// 
/// *[password] represent the password of the new user
class AuthArgs {
  final String email;
  final String password;

  AuthArgs({required this.email, required this.password});
}
