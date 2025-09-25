class User {
  String _name;
  String _email;
  int _age;
  String _password;

  User.empty() : _name = '', _email = '', _age = 0, _password = '';

  User({
    required String name,
    required String email,
    required int age,
    required String password,
  }) : _name = name,
       _email = email,
       _age = age,
       _password = password;

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
}
