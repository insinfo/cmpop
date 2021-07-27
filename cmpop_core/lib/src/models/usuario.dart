class Usuario {
  Usuario({this.nome, this.username, this.accessToken, this.expiresIn});

  String id;
  String nome;
  String username;
  String password;
  String accessToken;
  int expiresIn;
  DateTime dataCadastro;
  String cpf;
  bool ativo = true;

  Usuario.fromMap(Map<String, dynamic> map) {
    username = map['username'].toString();
    accessToken = map['accessToken'].toString();

    if (map.containsKey('id')) {
      id = map['id'];
    }

    if (map.containsKey('ativo')) {
      ativo = map['ativo'];
    }

    if (map.containsKey('nome')) {
      nome = map['nome'].toString();
    }

    if (map.containsKey('password')) {
      password = map['password'].toString();
    }
    if (map.containsKey('expiresIn')) {
      expiresIn = int.tryParse(map['expiresIn'].toString());
    }

    if (map.containsKey('dataCadastro')) {
      dataCadastro = DateTime.tryParse(map['dataCadastro'].toString());
    }

    if (map.containsKey('cpf')) {
      cpf = map['cpf'].toString();
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['nome'] = nome;
    map['username'] = username;
    map['password'] = password;
    map['accessToken'] = accessToken;
    map['expiresIn'] = expiresIn;
    map['dataCadastro'] = dataCadastro.toString();
    map['cpf'] = cpf;
    map['ativo'] = ativo;
    return map;
  }

  Map<String, dynamic> getMapForSave() {
    var map = toMap();
    map.remove('expiresIn');
    map.remove('accessToken');
    return map;
  }
}
