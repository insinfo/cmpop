class LoginPayload {
  LoginPayload({this.username, this.password});

  LoginPayload.fromMap(Map<String, dynamic> map) {
    username = map['username'].toString();
    if (map.containsKey('password')) {
      password = map['password'].toString();
    }
  }

  String username;
  String password;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['username'] = username;
    map['password'] = password;
    return map;
  }
}
