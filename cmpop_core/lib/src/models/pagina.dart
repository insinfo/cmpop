import 'pagina_item.dart';

class Pagina {
  String id;
  String tipo; // Interna | Customizada
  String nome;
  String slug;
  String content = '';
  bool ativo;
  DateTime dataCadastro;
  List<PaginaItem> items = <PaginaItem>[];

  Pagina({
    this.id,
    this.tipo = 'Customizada', //'Interna',
    this.slug,
    this.nome,
    this.ativo = true,
  });

  ///renderiza o content(template HTML) com os dados dos items de acordo com o idioma
  String getRenderContent() {
    var result = content;

    items?.forEach((item) {
      var regex = RegExp('\{\{(?:\\s+)?(' + item.key + ')(?:\\s+)?\}\}');
      // print('getRenderContent() key: ${item.key} | title: ${item.currentInfo.title}');
      result = result.replaceAll(regex, item.title);
    });

    return result;
  }

  Pagina.fromMap(Map<String, dynamic> map) {
    try {
      id = map['id'];
      tipo = map['tipo'];
      nome = map['nome'];
      slug = map['slug'];
      content = map['content'];
      ativo = map['ativo'];
      if (map.containsKey('dataCadastro')) {
        dataCadastro = DateTime.tryParse(map['dataCadastro']);
      }
      if (map.containsKey('items')) {
        if (map['items'] is List) {
          items ??= <PaginaItem>[];
          map['items'].forEach((m) {
            items.add(PaginaItem.fromMap(m));
          });
        }
      }
    } catch (e) {
      print('Pagina.fromMap: $e');
    }
  }

  Map<String, dynamic> toMap() {
    var result = <String, dynamic>{
      'id': id,
      'tipo': tipo,
      'nome': nome,
      'slug': slug,
      'content': content,
      'ativo': ativo,
      'dataCadastro': dataCadastro?.toString(),
      'items': items?.map((e) => e.toMap())?.toList(),
    };

    return result;
  }
}
