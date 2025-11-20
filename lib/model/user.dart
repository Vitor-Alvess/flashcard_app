class User {
  String _name;
  String _email;
  int _age;
  String? _profilePicturePath;

  User.empty() : _name = '', _email = '', _age = 0;

  User({required String name, required String email, required int age})
    : _name = name,
      _email = email,
      _age = age;

  factory User.fromMap(Map map) {
    final user = User(name: map["name"], email: map["email"], age: map["age"]);
    if (map["profilePicturePath"] != null) {
      user.profilePicturePath = map["profilePicturePath"];
    }
    return user;
  }

  dynamic toMap() {
    return {
      "name": name,
      "email": email,
      "age": age,
      "profilePicturePath": profilePicturePath,
    };
  }

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

  String? get profilePicturePath => _profilePicturePath;

  set profilePicturePath(String? path) {
    _profilePicturePath = path;
  }

  bool get isLoggedIn {
    return _name.isNotEmpty && _email.isNotEmpty;
  }
}
