import 'package:cmpop_core/src/models/info.dart';
import 'package:cmpop_core/cmpop_core.dart';

class Menu {
  String id;
  String idPai;
  String tipo = 'Header'; // Header | Footer
  String target = 'internal'; // customPage | _blank | internal
  String link;
  List<Info> infos = <Info>[];
  bool ativo;
  DateTime dataCadastro;
  int order;

  dynamic treeViewNodeLIElement;
  List<Menu> filhos = <Menu>[];
  int level;
  bool treeViewNodeFilter;
  Menu parent;
  bool treeViewNodeIsCollapse = true;
  bool treeViewNodeIsSelected = false;

  static List<String> tipos = <String>['Header', 'Footer', 'All'];

  bool hasChilds(Menu item) {
    return item.filhos?.isNotEmpty == true;
  }

  bool finded(String _search_query, Menu item) {
    var item_title = UtilsCore.removerAcentos(item.linkLabelPt).toLowerCase();
    return item_title.contains(_search_query);
  }

  Menu({
    this.dataCadastro,
    this.id,
    this.idPai,
    this.ativo = true,
    this.order = 0,
    this.infos,
  });

  Info currentInfo; //corrent idioma
  //muda o idioma
  void setInfoByLang(String lang, {bool recursive = true}) {
    currentInfo = infos.where((i) => i.lang == lang).first;
    if (recursive) {
      _getInfoByLangRecursive(lang, filhos);
    }
  }

  void _getInfoByLangRecursive(String lang, [List<Menu> filhos]) {
    filhos?.forEach((m) {
      m.currentInfo = m.infos.where((i) => i.lang == lang).first;
      if (m.filhos?.isNotEmpty == true) {
        _getInfoByLangRecursive(lang, m.filhos);
      }
    });
  }

  String get linkLabelPt {
    var result = '';
    if (infos?.isNotEmpty == true) {
      var list = infos.where((e) => e.lang == 'pt').toList();
      if (list?.isNotEmpty == true) {
        result = list.first.linkLabel;
      }
    }
    return result;
  }

  Menu.fromMap(Map<String, dynamic> map) {
    try {
      id = map['id'];
      idPai = map['idPai'];
      if (map.containsKey('tipo')) {
        tipo = map['tipo'];
      }

      link = map['link'];
      ativo = map['ativo'];
      order = map['order'];

      if (map.containsKey('target')) {
        target = map['target'];
      }

      if (map.containsKey('infos')) {
        if (map['infos'] is List) {
          infos ??= <Info>[];
          map['infos'].forEach((m) {
            infos.add(Info.fromMap(m));
          });
        }
      }

      if (map.containsKey('dataCadastro')) {
        dataCadastro = DateTime.tryParse(map['dataCadastro']);
      }

      if (map.containsKey('filhos')) {
        if (map['filhos'] is List) {
          filhos ??= <Menu>[];
          map['filhos'].forEach((m) {
            filhos.add(Menu.fromMap(m));
          });
        }
      }

      if (map.containsKey('level')) {
        level = map['level'];
      }
    } catch (e) {
      print('Menu.fromMap: $e');
    }
  }

  Map<String, dynamic> toMap() {
    var result = <String, dynamic>{
      'id': id,
      'idPai': idPai,
      'tipo': tipo,
      'link': link,
      'ativo': ativo,
      'dataCadastro': dataCadastro?.toString(),
      'order': order,
      'target': target,
      'infos': infos?.map((e) => e.toMap())?.toList(),
    };

    return result;
  }
}
