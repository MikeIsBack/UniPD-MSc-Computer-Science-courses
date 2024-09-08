/// [UserData] is the object that encapsulate the following data:
///
/// *[uid] the ID of the user account
///
/// *[name] the name of the user
/// 
/// *[email] the email of the user
///
/// *[photoUrl] the profile photo of the user
///
/// *[isHost] represent the user's role {true if 'host', false if 'student'}
/// 
/// *[savedAds] represent the user's list of saved ads
class UserData {
  final String? uid;
  final String? name;
  final String? email;
  final String? photoUrl;
  final bool isHost;
  final List<String>? savedAds;

  UserData(
      {this.uid = '',
      this.name = '',
      this.email = '',
      this.photoUrl = '',
      required this.isHost,
      this.savedAds});
}
