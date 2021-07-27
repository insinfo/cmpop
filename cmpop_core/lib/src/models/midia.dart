class Midia {
  Midia({
    this.id,
    this.title,
    this.dataCadastro,
    this.description,
    this.fisicalFilename,
    this.originalFilename,
    this.link,
    this.tipo,
    this.mimeType,
  });

  Midia.fromMap(Map<String, dynamic> map) {
    if (map != null) {
      id = map['id'];
      title = map['title'];
      description = map['description'];
      dataCadastroAsString = map['dataCadastro'];
      fisicalFilename = map['fisicalFilename'] as String;
      originalFilename = map['originalFilename'] as String;
      link = map['link'] as String;
      mimeType = map['mimeType'] as String;
      if (map.containsKey('tipo')) {
        tipo = map['tipo'];
      }
    }
  }

  String id;
  String title;
  String description;
  DateTime dataCadastro;
  dynamic file;
  String fisicalFilename;
  String originalFilename;
  String link;
  String mimeType;
  String tipo;

  bool isSelected = false;
  bool isHover = false;

  String get dataCadastroAsString {
    final dt = dataCadastro != null ? dataCadastro.toIso8601String().substring(0, 10) : '';
    return dt;
  }

  set dataCadastroAsString(dynamic value) {
    if (value is DateTime) {
      dataCadastro = value;
    } else if (value is String) {
      dataCadastro = DateTime.tryParse(value);
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['description'] = description;
    map['dataCadastro'] = dataCadastro.toString();
    map['fisicalFilename'] = fisicalFilename;
    map['originalFilename'] = originalFilename;
    map['link'] = link;
    map['mimeType'] = mimeType;
    map['tipo'] = tipo;

    return map;
  }

  Map<String, dynamic> asMapToInsert() {
    var map = toMap();
    // map.remove('perfil');
    return map;
  }

  Map<String, dynamic> toMapOnlyId() {
    return <String, dynamic>{'id': id};
  }

  void validate() {
    if (title == null) {
      throw Exception('Título não pode ser vazio!');
    }
  }

  String getClassName() {
    return 'Midia';
  }
}
