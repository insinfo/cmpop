import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cmpop_core/cmpop_core.dart';

class RestApiBase {
  final http.Client client = http.Client();
  final String _collectionPath;
  String subCollectionPath;
  RestConfigBase restConfig;
  RestApiBase(this.restConfig, this._collectionPath, {this.subCollectionPath});

  Future<RepositoryResult> all(Filtros filtros) async {
    var resp = await client.get(Uri.parse('${restConfig.serverURL}$_collectionPath?${filtros.queryParamsString()}'),
        headers: restConfig.defaultHeaders);
    if (resp.statusCode == 200) {
      return RepositoryResult.fromJson(resp.body);
    } else {
      throw Exception('Falha ao obter os dados');
    }
  }

  Future<RepositoryResult> findById(String id) async {
    var resp =
        await client.get(Uri.parse('${restConfig.serverURL}$_collectionPath/$id'), headers: restConfig.defaultHeaders);
    if (resp.statusCode == 200) {
      return RepositoryResult.fromJson(resp.body);
    } else {
      throw Exception('Falha ao obter os dados');
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    var resp = await client.post(Uri.parse('${restConfig.serverURL}$_collectionPath'),
        body: jsonEncode(data), headers: restConfig.defaultHeaders);
    if (resp.statusCode != 200) {
      throw Exception('Falha ao gravar os dados');
    }
  }

  Future<void> updateById(Map<String, dynamic> data, String id, {List<String> ignoreFields}) async {
    var ignoreF = ignoreFields != null ? '?ignoreFields=${jsonEncode(ignoreFields)}' : '';
    var resp = await client.put(Uri.parse('${restConfig.serverURL}$_collectionPath/$id$ignoreF'),
        body: jsonEncode(data), headers: restConfig.defaultHeaders);
    if (resp.statusCode != 200) {
      throw Exception('Falha ao atualizar os dados');
    }
  }

  Future<void> deleteById(String id) async {
    var resp = await client.delete(Uri.parse('${restConfig.serverURL}$_collectionPath/$id'),
        headers: restConfig.defaultHeaders);
    if (resp.statusCode != 200) {
      throw Exception('Falha ao deletar os dados');
    }
  }

  /* allSubCollection */

  Future<RepositoryResult> allSubCollectionItems(
    Filtros filtros,
  ) async {
    var resp = await client.get(Uri.parse('${restConfig.serverURL}$subCollectionPath?${filtros.queryParamsString()}'),
        headers: restConfig.defaultHeaders);
    if (resp.statusCode == 200) {
      return RepositoryResult.fromJson(resp.body);
    } else {
      throw Exception('Falha ao obter os dados');
    }
  }

  Future<RepositoryResult> findSubCollectionItemById(String id) async {
    var resp = await client.get(Uri.parse('${restConfig.serverURL}$subCollectionPath/$id'),
        headers: restConfig.defaultHeaders);
    if (resp.statusCode == 200) {
      return RepositoryResult.fromJson(resp.body);
    } else {
      throw Exception('Falha ao obter os dados');
    }
  }

  Future<RepositoryResult> findSubCollectionItemBy(String byKey, String byValue) async {
    var resp = await client.get(Uri.parse('${restConfig.serverURL}$subCollectionPath/by/$byKey/$byValue'),
        headers: restConfig.defaultHeaders);
    if (resp.statusCode == 200) {
      return RepositoryResult.fromJson(resp.body);
    } else {
      throw Exception('Falha ao obter os dados');
    }
  }

  Future<RepositoryResult> findByMap(Map<String, dynamic> map) async {
    var json = jsonEncode(map);
    var resp = await client.get(Uri.parse('${restConfig.serverURL}$_collectionPath/by/map/?map=$json'),
        headers: restConfig.defaultHeaders);
    if (resp.statusCode == 200) {
      return RepositoryResult.fromJson(resp.body);
    } else {
      throw Exception('Falha ao obter os dados');
    }
  }

  Future<RepositoryResult> findBySlug(String slug) async {
    return findByMap({'slug': slug});
  }

  Future<RepositoryResult> findSubCollectionItemByMap(Map<String, dynamic> map) async {
    var json = jsonEncode(map);
    var resp = await client.get(Uri.parse('${restConfig.serverURL}$subCollectionPath/by/map/?map=$json'),
        headers: restConfig.defaultHeaders);
    if (resp.statusCode == 200) {
      return RepositoryResult.fromJson(resp.body);
    } else {
      throw Exception('Falha ao obter os dados');
    }
  }

  Future<RepositoryResult> countSubCollectionSlugsAsMap(String slug, {String idForIgnore}) async {
    var id = idForIgnore != null ? '&idForIgnore=$idForIgnore' : '';
    var resp = await client.get(Uri.parse('${restConfig.serverURL}$subCollectionPath/count/slug/?slug=$slug$id'),
        headers: restConfig.defaultHeaders);
    if (resp.statusCode == 200) {
      return RepositoryResult.fromJson(resp.body);
    } else {
      throw Exception('Falha ao obter os dados');
    }
  }

  Future<int> countSlug(String slug, {String idForIgnore}) async {
    var id = idForIgnore != null ? '&idForIgnore=$idForIgnore' : '';
    var resp = await client.get(Uri.parse('${restConfig.serverURL}$_collectionPath/count/slug/?slug=$slug$id'),
        headers: restConfig.defaultHeaders);
    if (resp.statusCode == 200) {
      var r = RepositoryResult.fromJson(resp.body);
      return r.result['count'];
    } else {
      throw Exception('Falha ao obter os dados');
    }
  }

  Future<void> createSubCollectionItem(Map<String, dynamic> data) async {
    var resp = await client.post(Uri.parse('${restConfig.serverURL}$subCollectionPath'),
        body: jsonEncode(data), headers: restConfig.defaultHeaders);
    if (resp.statusCode != 200) {
      throw Exception('Falha ao gravar os dados');
    }
  }

  Future<void> updateSubCollectionItemById(Map<String, dynamic> data, String id) async {
    var resp = await client.put(Uri.parse('${restConfig.serverURL}$subCollectionPath/$id'),
        body: jsonEncode(data), headers: restConfig.defaultHeaders);
    if (resp.statusCode != 200) {
      throw Exception('Falha ao atualizar os dados');
    }
  }

  Future<void> deleteSubCollectionItemById(String id) async {
    var resp = await client.delete(Uri.parse('${restConfig.serverURL}$subCollectionPath/$id'),
        headers: restConfig.defaultHeaders);
    if (resp.statusCode != 200) {
      throw Exception('Falha ao deletar os dados');
    }
  }
}
