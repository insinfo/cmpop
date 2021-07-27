import 'package:cmpop_core/cmpop_core.dart';

class Categoria {
  Categoria({
    this.midia,
    this.icon,
    this.ativo = true,
    this.visivel = true,
    this.dataCadastro,
    this.order = 0,
    this.tipoOrdenacao = 'randomizada',
  });
  String id;
  String link;
  String icon;
  bool ativo = true;

  ///se é visível para cadastro de comercio
  bool visivel = true;
  DateTime dataCadastro;
  int order = 0;
  Midia midia;
  String slug;
  // HOSPEDAGEM | ALIMENTAÇÃO
  String segmento;

  /// tipo de ordenação dos comercios "randomizada" | "alfabetica"
  String tipoOrdenacao = 'randomizada';

  @override
  bool operator ==(o) => o is Categoria && id == o.id;

  @override
  int get hashCode => id.hashCode;

  Categoria.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    link = map['link'];
    icon = map['icon'];
    ativo = map['ativo'];
    order = map['order'];
    slug = map['slug'];
    visivel = map['visivel'];
    tipoOrdenacao = map['tipoOrdenacao'];

    if (map.containsKey('dataCadastro')) {
      dataCadastro = DateTime.tryParse(map['dataCadastro']);
    }
    if (map.containsKey('segmento')) {
      segmento = map['segmento'];
    }

    if (map.containsKey('midia')) {
      if (map['midia'] != null) {
        midia = Midia.fromMap(map['midia']);
      }
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    map['dataCadastro'] = dataCadastro?.toString();
    map['segmento'] = segmento;
    map['link'] = link;
    map['icon'] = icon;
    map['ativo'] = ativo;
    map['visivel'] = visivel;
    map['order'] = order;
    map['slug'] = slug;
    map['tipoOrdenacao'] = tipoOrdenacao;
    map['midia'] = midia?.toMap();

    return map;
  }
}
