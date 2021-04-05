import 'dart:convert';

class Authorization {
  final _username;
  final _password;

  Authorization(this._username, this._password);

  Map<String, dynamic> basic() {
    var bytes = utf8.encode('$_username:$_password');
    var token = base64.encode(bytes);

    return {'Authorization': 'Basic $token'};
  }
}