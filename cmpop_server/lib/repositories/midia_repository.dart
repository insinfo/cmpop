import 'dart:convert';

import 'package:galileo_framework/galileo_framework.dart';
import 'package:collection/collection.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:cmpop_core/cmpop_core.dart';
import 'package:cmpop_server/app_config.dart';
import 'package:cmpop_server/db_connect.dart';
import 'package:cmpop_server/services/file_service.dart';

class MidiaRepository {
  MidiaRepository();

  static const collection = 'midias';

  Future<List<Map<String, dynamic>>> getAllAsMap(Map<String, dynamic> queryParameters) async {
    SelectorBuilder qb = SelectorBuilder();

    if (queryParameters.containsKey('filterByWhere') != null) {
      final f = queryParameters['filterByWhere'];
      if (f is String) {
        final filterByWhere = jsonDecode(f);

        if (filterByWhere is List) {
          filterByWhere.forEach((map) {
            if (map['op'] == 'eq') {
              qb = where.eq(map['key'].toString(), map['value']);
            } else if (map['op'] == 'ne') {
              qb = where.ne(map['key'].toString(), map['value']);
            }
          });
        }
      }
    }

    if (queryParameters.containsKey('filterByMap') != null) {
      final filterByMap = jsonDecode(queryParameters['filterByMap'].toString()) as Map<String, dynamic>;
      if (filterByMap != null) {
        filterByMap.forEach((key, value) {
          qb = where.eq(key, value);
        });
      }
    }

    if (queryParameters.containsKey('search')) {
      final search = queryParameters['search'].toString();

      if (queryParameters.containsKey('searchFields')) {
        final searchFields = jsonDecode(queryParameters['searchFields'].toString()) as List;
        final map = <String, dynamic>{};
        map['\$query'] = {
          '\$or': searchFields
              .map((field) => {
                    '$field': {'\$regex': '${search}', '\$options': 'i'}
                  })
              .toList()
        };
        qb.raw(map);
      }
    }

    if (queryParameters.containsKey('rawQuery')) {
      final rawQuery = jsonDecode(queryParameters['rawQuery'].toString()) as Map<String, dynamic>;
      qb.raw(rawQuery);
    }

    if (queryParameters.containsKey('limit')) {
      final limit = int.tryParse(queryParameters['limit'].toString());
      if (qb is SelectorBuilder) {
        qb.limit(limit);
      } else {
        qb = where.limit(limit);
      }
    }
    if (queryParameters.containsKey('offset')) {
      final offset = int.tryParse(queryParameters['offset'].toString());
      if (qb is SelectorBuilder) {
        qb.skip(offset);
      } else {
        qb = where.skip(offset);
      }
    }
    if (queryParameters.containsKey('sortBy')) {
      final sortBy = queryParameters['sortBy'].toString();
      final sortD = queryParameters.containsKey('sortDir');
      var sortDir = false;
      if (sortD) {
        sortDir = queryParameters['sortDir'] == 'true';
      }
      if (qb is SelectorBuilder) {
        qb.sortBy(sortBy, descending: sortDir);
      } else {
        qb = where.sortBy(sortBy, descending: sortDir);
      }
    }

    print(qb);
    final results = await db.collection(collection).find(qb).toList();
    if (results != null) {
      results.forEach((midia) {
        if (midia.containsKey('link')) {
          midia['link'] = "${AppConfig.webPathBase}${midia['link']}";
        }
      });
    }

    return results;
  }

  Future<Map<String, dynamic>> getByIdAsMap(String id) async {
    final filterByMap = {'id': id};
    return db.collection(collection).findOne(filterByMap);
  }

  Future<Midia> getById(String id) async {
    final map = await getByIdAsMap(id);

    if (map.containsKey('link')) {
      map['link'] = "${AppConfig.webPathBase}${map['link']}";
    }

    map['webPathBase'] = "${AppConfig.webPathBase}";
    return Midia.fromMap(map);
  }

  Future<Midia> createFromMapWithFiles(Map<String, dynamic> entityMap, UploadedFile file) async {
    final newMidia = Midia.fromMap(entityMap);
    newMidia.dataCadastro = DateTime.now();
    if (newMidia.link != null && newMidia.link.contains('http')) {
      newMidia.link = newMidia.link.substring(AppConfig.webPathBase.length, newMidia.link.length);
    }
    newMidia.validate();

    final fileService = FileService();
    var midiaFisicalFilename = '';

    try {
      //Cria arquivo
      midiaFisicalFilename = await fileService.create(
        file,
        '${AppConfig.storagePathMedia}',
        randFileName: true,
      );
      newMidia.fisicalFilename = midiaFisicalFilename;
      newMidia.originalFilename = file.filename;
      newMidia.link = '${AppConfig.storageWebPathMedia}/$midiaFisicalFilename';

      await db.collection(collection).insert(newMidia.asMapToInsert());
    } catch (e) {
      await fileService.deleteIfExist('${AppConfig.storagePathMedia}/$midiaFisicalFilename');
      rethrow;
    }
    return newMidia;
  }

  Future<Midia> updateFromMapWithFiles(Map<String, dynamic> entityMap, UploadedFile file) async {
    final newMidia = Midia.fromMap(entityMap);

    if (newMidia.link != null && newMidia.link.contains('http')) {
      newMidia.link = newMidia.link.substring(AppConfig.webPathBase.length, newMidia.link.length);
    }

    newMidia.validate();

    final fileService = FileService();
    var midiaFisicalFilename = '';

    try {
      final filterByMap = {'id': newMidia.id};

      final Map<String, dynamic> m = await db.collection(collection).findOne(filterByMap);
      final oldFileName = Midia.fromMap(m).fisicalFilename;

      if (file != null) {
        //deleta arquivo anterior
        await fileService.deleteIfExist('${AppConfig.storagePathMedia}/${oldFileName}');

        midiaFisicalFilename = await fileService.create(file, '${AppConfig.storagePathMedia}', randFileName: true);
        newMidia.fisicalFilename = midiaFisicalFilename;
        newMidia.originalFilename = file.filename;
        newMidia.link = '${AppConfig.storageWebPathMedia}/$midiaFisicalFilename';
      }

      final mesclado = CombinedMapView([newMidia.toMap(), m]);
      // ignore: deprecated_member_use
      await db.collection(collection).save(mesclado);
    } catch (e) {
      await fileService.deleteIfExist('${AppConfig.storagePathMedia}/$midiaFisicalFilename');
      rethrow;
    }
    return newMidia;
  }

  Future<void> deleteAllFromMaps(List<Map<String, dynamic>> entityMaps) async {
    if (entityMaps?.isNotEmpty == true) {
      for (var item in entityMaps) {
        await deleteFromMap(item);
      }
    }
  }

  Future<void> deleteFromMap(Map<String, dynamic> entityMap) async {
    final item = Midia.fromMap(entityMap);
    final fileService = FileService();
    await fileService.deleteIfExist('${AppConfig.storagePathMedia}/${item.fisicalFilename}');
    final filterByMap = {'id': item.id};
    await db.collection(collection).remove(filterByMap);
  }

  Future<void> deleteById(String id) async {
    final fileService = FileService();
    final filterByMap = {'id': id};
    final m = await db.collection(collection).findOne(filterByMap);
    final midia = Midia.fromMap(m);
    await fileService.deleteIfExist('${AppConfig.storagePathMedia}/${midia.fisicalFilename}');
    await db.collection(collection).remove(filterByMap);
  }
}
