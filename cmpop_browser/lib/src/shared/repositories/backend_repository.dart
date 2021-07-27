import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cmpop_browser/src/shared/exceptions/no_content_exception.dart';
import 'package:cmpop_core/cmpop_core.dart';

import '../app_config.dart';

class BackendRepository {
  BackendRepository();

  Future<List<Map<String, dynamic>>> getAllAsMap(String collection, {Filtro filtro}) async {
    var client = http.Client();
    var list = <Map<String, dynamic>>[];

    var url = '${AppConfig().serverURL}/rest?collection=$collection';

    if (filtro != null) {
      filtro.addParam('collection', collection);
      url = '${AppConfig().serverURL}/rest?${filtro.queryString}';
    }

    var resp = await client.get(url, headers: AppConfig().defaultHeaders);

    if (resp.statusCode == 200) {
      var json = jsonDecode(resp.body);
      json.forEach((v) {
        list.add(v);
      });
    } else {
      throw Exception('Falha ao obter os dados de $collection');
    }
    return list;
  }

  Future<List<Map<String, dynamic>>> getMenuHierarquia(
      {bool filtrarAtivos = true, List<String> filtrarPorTipos}) async {
    var maps = await getAllAsMap(AppConfig.MENUS);

    var result = <Map<String, dynamic>>[];
    if (maps?.isNotEmpty == true) {
      var roots = _getMenuRoots(maps);
      //ordena
      roots.sort((m1, m2) {
        var r = m1['order'].compareTo(m2['order']);
        return r;
        /*if (r != 0) return r;
        return m1["firstName"].compareTo(m2["firstName"]);*/
      });
      //filtra
      if (filtrarAtivos) {
        roots = roots.where((m) => m['ativo'] == true).toList();
      }
      if (filtrarPorTipos?.isNotEmpty == true) {
        roots = roots.where((m) => filtrarPorTipos.contains(m['tipo'])).toList();
      }

      roots.forEach((pai) {
        var item = <String, dynamic>{};
        item.addAll(pai);
        item['level'] = 0;
        var filhos = _getMenuChildren(maps, item['id'], 0, filtrarPorTipos);
        //ordena
        filhos.sort((m1, m2) => m1['order'].compareTo(m2['order']));
        //filtra
        if (filtrarAtivos) {
          filhos = filhos.where((m) => m['ativo'] == true).toList();
        }
        item['filhos'] = filhos;
        result.add(item);
      });
    }

    return result;
  }

  //int count = 0;
  List<Map<String, dynamic>> _getMenuChildren(
      List<Map<String, dynamic>> maps, String idPai, int level, List<String> filtrarPorTipos) {
    var items = maps.where((org) {
      if (filtrarPorTipos?.isNotEmpty == true) {
        return org['idPai'] == idPai && filtrarPorTipos.contains(org['tipo']);
      } else {
        return org['idPai'] == idPai;
      }
    }).toList();

    items.forEach((pai) {
      var lvl = level + 1;
      var children = _getMenuChildren(maps, pai['id'], lvl, filtrarPorTipos);
      pai['level'] = lvl;
      pai['filhos'] = children;
    });
    return items;
  }

  //obtem os elementos pai
  List<Map<String, dynamic>> _getMenuRoots(List<Map<String, dynamic>> maps) {
    return maps
        .where((org) => org['idPai'] == null || org['idPai'] == 'null' || org['idPai'] == '-1' || org['idPai'] == '')
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAllMidiasAsMap({Filtro filtro}) async {
    var client = http.Client();
    var list = <Map<String, dynamic>>[];

    var url = '${AppConfig().serverURL}/midias';

    if (filtro != null) {
      url = '$url?${filtro.queryString}';
    }

    var resp = await client.get(url, headers: AppConfig().defaultHeaders);

    if (resp.statusCode == 200) {
      var json = jsonDecode(resp.body);
      json.forEach((v) {
        list.add(v);
      });
    } else {
      throw Exception('Falha ao obter os dados ');
    }
    return list;
  }

  Future<Map<String, dynamic>> getByIdAsMap(String id, String collection) async {
    var client = http.Client();
    var filterByMap = jsonEncode({'id': id});
    var item;
    var resp = await client.get(
      '${AppConfig().serverURL}/rest/findFirstBy?collection=$collection&filterByMap=$filterByMap',
      headers: AppConfig().defaultHeaders,
    );
    if (resp.statusCode == 200) {
      item = jsonDecode(resp.body);
    } else {
      throw Exception('Falha ao obter os dados de $collection');
    }
    return item;
  }

  Future<Map<String, dynamic>> findFirstByAsMap(String collection,
      {Map<String, dynamic> queryMap,
      Map<String, dynamic> projectionMap,
      Map<String, dynamic> rawQuery,
      List<Map<String, dynamic>> aggregateQuery}) async {
    var client = http.Client();

    var url = '${AppConfig().serverURL}/rest/findFirstBy?collection=$collection';
    if (queryMap != null) {
      var queryJson = jsonEncode(queryMap);
      url = '$url&filterByMap=$queryJson';
    }
    if (rawQuery != null) {
      var raw = jsonEncode(rawQuery);
      url = '$url&rawQuery=$raw';
    }
    if (aggregateQuery != null) {
      var json = jsonEncode(aggregateQuery);
      url = '$url&aggregateQuery=$json';
    }
    if (projectionMap != null) {
      var projectionJson = jsonEncode(projectionMap);
      url = '$url&projectionMap=$projectionJson';
    }

    var item;
    var resp = await client.get(
      url,
      headers: AppConfig().defaultHeaders,
    );
    if (resp.statusCode == 200) {
      item = jsonDecode(resp.body);
    } else {
      throw Exception('Falha ao obter os dados de $collection');
    }
    return item;
  }

  Future<void> createAsMap(Map<String, dynamic> map, String collection) async {
    var client = http.Client();
    var resp = await client.post('${AppConfig().serverURL}/rest?collection=$collection',
        headers: AppConfig().defaultHeaders, body: jsonEncode(map));

    if (resp.statusCode != 200) {
      throw Exception('Falha ao criar o $collection.');
    }
  }

  Future<void> criaUsuario(Usuario usuario) async {
    var client = http.Client();
    var resp = await client.post('${AppConfig().serverURL}/auth/usuario',
        headers: AppConfig().defaultHeaders, body: jsonEncode(usuario.getMapForSave()));

    if (resp.statusCode != 200) {
      throw Exception('Falha ao criar o usuario.');
    }
  }

  Future<void> updateUsuarioByUsername(Usuario usuario) async {
    var client = http.Client();
    var resp = await client.put('${AppConfig().serverURL}/auth/usuario/by/username',
        headers: AppConfig().defaultHeaders, body: jsonEncode(usuario.getMapForSave()));

    if (resp.statusCode != 200) {
      throw Exception('Falha ao criar o usuario.');
    }
  }

  Future<void> updateUsuarioById(Usuario usuario) async {
    var client = http.Client();
    var resp = await client.put('${AppConfig().serverURL}/auth/usuario/by/ide',
        headers: AppConfig().defaultHeaders, body: jsonEncode(usuario.getMapForSave()));

    if (resp.statusCode != 200) {
      throw Exception('Falha ao criar o usuario.');
    }
  }

  Future<void> deleteMidiaById(String id) async {
    var client = http.Client();
    var resp = await client.delete('${AppConfig().serverURL}/midias/$id', headers: AppConfig().defaultHeaders);

    if (resp.statusCode != 200) {
      throw Exception('Falha ao criar ao deletar');
    }
  }

  Future<void> deleteAsMap(Map<String, dynamic> map, String collection) async {
    var client = http.Client();
    var filterByMap = jsonEncode({'id': map['id']});
    var resp = await client.delete('${AppConfig().serverURL}/rest?collection=$collection&filterByMap=$filterByMap',
        headers: AppConfig().defaultHeaders);

    if (resp.statusCode != 200) {
      throw Exception('Falha ao deletar o $collection');
    }
  }

  Future<void> updateAsMap(Map<String, dynamic> map, String collection) async {
    var client = http.Client();
    var filterByMap = jsonEncode({'id': map['id']});
    var resp = await client.put('${AppConfig().serverURL}/rest?collection=$collection&filterByMap=$filterByMap',
        headers: AppConfig().defaultHeaders, body: jsonEncode(map));

    if (resp.statusCode != 200) {
      throw Exception('Falha ao atualizar o $collection.');
    }
  }

  Future<void> updateByMap(Map<String, dynamic> byMap, Map<String, dynamic> data, String collection) async {
    var client = http.Client();
    var filterByMap = jsonEncode(byMap);
    var resp = await client.put('${AppConfig().serverURL}/rest?collection=$collection&filterByMap=$filterByMap',
        headers: AppConfig().defaultHeaders, body: jsonEncode(data));

    if (resp.statusCode != 200) {
      throw Exception('Falha ao atualizar o $collection.');
    }
  }

  Future<Map<String, dynamic>> getLastAsMap(String collection) async {
    var client = http.Client();
    var item;
    var itens;
    var resp = await client.get(
      '${AppConfig().serverURL}/rest?collection=$collection&limit=1&sortBy=dataCadastro&sortDir=true',
      headers: AppConfig().defaultHeaders,
    );
    if (resp.statusCode == 200) {
      itens = jsonDecode(resp.body);
      if (itens?.isNotEmpty == true) {
        item = itens[0];
      } else {
        throw NoContentException();
      }
    } else {
      throw Exception('Falha ao obter os dados');
    }
    return item;
  }
}
