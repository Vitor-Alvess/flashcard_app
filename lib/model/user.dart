class User {
  String _name;
  String _email;
  int _age;
  String _password;
  String? _profilePicturePath;

  User.empty()
    : _name = '',
      _email = '',
      _age = 0,
      _password = '',
      _profilePicturePath = null;

  User({
    required String name,
    required String email,
    required int age,
    required String password,
    String? profilePicturePath,
  }) : _name = name,
       _email = email,
       _age = age,
       _password = password,
       _profilePicturePath = profilePicturePath;

  String get name {
    return _name;
  }

  String get email {
    return _email;
  }

  int get age {
    return _age;
  }

  set name(String name) {
    _name = name;
  }

  set email(String email) {
    _email = email;
  }

  set age(int age) {
    _age = age;
  }

  set password(String password) {
    _password = password;
  }

  String? get profilePicturePath => _profilePicturePath;

  set profilePicturePath(String? path) {
    _profilePicturePath = path;
  }

  bool get isLoggedIn {
    return _name.isNotEmpty && _email.isNotEmpty;
  }
}
