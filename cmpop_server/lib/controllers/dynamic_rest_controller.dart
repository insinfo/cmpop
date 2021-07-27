import 'dart:convert';
import 'package:galileo_framework/galileo_framework.dart';
import 'package:collection/collection.dart';
import 'package:cmpop_core/cmpop_core.dart';
import 'package:cmpop_server/app_config.dart';
import 'package:cmpop_server/cmpop_server.dart';
import 'package:cmpop_server/exceptions/not_found_exception.dart';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:cmpop_server/exceptions/unauthorized_exception.dart';

class DynamicRestController {
  /*static SelectorBuilder _getWhere(map) {
    if (map['op'] == 'eq') {
      return where.eq(map['key'].toString(), map['value']);
    } else if (map['op'] == 'ne') {
      return where.ne(map['key'].toString(), map['value']);
    }
    return SelectorBuilder();
  }*/

  static void all(RequestContext req, ResponseContext res) async {
    try {
      //await req.parseBody();
      //final Map<String, dynamic> payload = req.bodyAsMap;
      final Map<String, dynamic> queryParameters = req.queryParameters;

      final collection = queryParameters['collection'].toString();
      List<Map<String, dynamic>> result;

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

      result = await db.collection(collection).find(qb).toList();
      final parents = [
        'midia',
        'midias',
        'imagem',
        'imagens',
        'backgroundImagem',
        'foregroundImagem',
      ];
      //faz o merge das midias
      if (result?.isNotEmpty == true) {
        final idsMidias = UtilsCore.getStringIdsRecursiveFromList(result, parents);
        //pega os ids de midias
        /* result.forEach((map) {
          idsMidias.addAll(UtilsCore.getStringIdsRecursiveFromMap(map, [
            'midia',
            'midias',
            'imagem',
            'imagens',
            'backgroundImagem',
            'foregroundImagem',
          ]));
        });*/

        //  print('idsMidias $idsMidias');

        if (idsMidias?.isNotEmpty == true) {
          //pegar as instancias de midias do banco
          final midias = await db.collection('midias').find({
            "id": {"\$in": idsMidias}
          }).toList();

          if (midias?.isNotEmpty == true) {
            //atualiza os resultados com as informações de midias (Faz um join)
            //UtilsCore.updateListMapRecursive(result,  ['midia', 'midias']);
            result.forEach((map) {
              midias.forEach((midia) {
                final newMidia = midia;
                newMidia['link'] = "${AppConfig.webPathBase}${midia['link']}";
                UtilsCore.updateMapRecursive(
                  map,
                  parents,
                  newMidia,
                  (map) => map['id'] == newMidia['id'],
                );
              });
            });
          }
        }
      }

      final json = jsonEncode(result);
      // res.contentType = MediaType('application', 'json');
      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      //res.headers['total-records'] = re.totalRecords.toString();
      res.write(json);
    } catch (e, s) {
      print(s);
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void findFirstBy(RequestContext req, ResponseContext res) async {
    //  try {
    //await req.parseBody();
    //final Map<String, dynamic> filterMap = req.bodyAsMap;
    //final Map<String, dynamic> params = req.params;
    final Map<String, dynamic> queryParameters = req.queryParameters;
    final collection = queryParameters['collection'].toString();

    Map<String, dynamic> result;
    if (queryParameters.containsKey('filterByMap')) {
      final filterByMap = jsonDecode(queryParameters['filterByMap'].toString());
      result = await db.collection(collection).findOne(filterByMap);
    } else if (queryParameters.containsKey('filterById')) {
      final filterById = queryParameters['filterById'].toString();
      result = await db.collection(collection).findOne(where.id(ObjectId.fromHexString(filterById)));
    } else if (queryParameters.containsKey('rawQuery')) {
      final json = jsonDecode(queryParameters['rawQuery'].toString());
      final rawMap = json as Map<String, dynamic>;
      final qb = SelectorBuilder();
      qb.raw(rawMap);
    } else if (queryParameters.containsKey('aggregateQuery')) {
      final json = jsonDecode(queryParameters['aggregateQuery'].toString());

      if (json is List) {
        final aggregateQuery = json.map((i) => i as Map<String, dynamic>).toList();
        // print('aggregateQuery $aggregateQuery');
        //result = await db.collection(collection).aggregateToStream(aggregateQuery)?.first;
        final cursor = db.collection(collection).modernAggregateCursor(aggregateQuery
            /*[
        {
          r'$replaceRoot': {
            'newRoot': {
              r'$arrayElemAt': [
                {
                  r'$filter': {
                    'input': r'$pontosGastronomicos',
                    'as': 'pontosGastronomicos',
                    'cond': {
                      /* resolve to a boolean value and determine if an element should be included in the output array. */
                      r'$eq': [r'$$pontosGastronomicos.id', '208a3f93-9fcb-4db7-ac44-bb11b86a2d31']
                    }
                  }
                },
                0 /* the element at the specified array index */
              ]
            }
          }
        }
      ]*/
            );
        result = await cursor.nextObject();
        await cursor.close();
      }
    }

    /*result = await db.collection(collection).modernFindOne(filter: {
      'pontosGastronomicos': {
        r'$elemMatch': {'id': '208a3f93-9fcb-4db7-ac44-bb11b86a2d31'}
      }
    }, projection: {
      '_id': 0,
      'pontosGastronomicos': {
        r'$elemMatch': {'id': '208a3f93-9fcb-4db7-ac44-bb11b86a2d31'}
      }
    });*/
    //print(result);

    //faz o merge das midias
    if (result != null) {
      final idsMidias = <String>[];

      //pega os ids de midias
      final parents = [
        'midia',
        'midias',
        'imagem',
        'imagens',
        'backgroundImagem',
        'foregroundImagem',
      ];
      idsMidias.addAll(UtilsCore.getStringIdsRecursiveFromMap(result, parents));

      if (idsMidias?.isNotEmpty == true) {
        //pegar as instancias de midias do banco
        final midias = await db.collection('midias').find({
          "id": {"\$in": idsMidias}
        }).toList();

        if (midias?.isNotEmpty == true) {
          //atualiza os resultados com as informações de midias (Faz um join)
          midias.forEach((midia) {
            final newMidia = midia;
            newMidia['link'] = "${AppConfig.webPathBase}${midia['link']}";
            UtilsCore.updateMapRecursive(
              result,
              ['midia', 'midias'],
              newMidia,
              (map) => map['id'] == newMidia['id'],
            );
          });
        }
      }
    }

    final json = jsonEncode(result);
    res.headers['Content-Type'] = 'application/json;charset=utf-8';
    res.write(json);
    /*} catch (e, s) {
      throw GalileoHttpException.badRequest(message: '$e $s');
    }*/
  }

  static void deleteBy(RequestContext req, ResponseContext res) async {
    try {
      final Map<String, dynamic> queryParameters = req.queryParameters;
      final collection = queryParameters['collection'].toString();
      if (collection.contains('user')) {
        throw UnauthorizedException();
      }
      final result = <String, dynamic>{};
      if (queryParameters.containsKey('filterByMap')) {
        final filterByMap = jsonDecode(queryParameters['filterByMap'].toString());
        result['filterByMap'] = filterByMap;
        result.addAll(await db.collection(collection).remove(filterByMap));
      } else if (queryParameters.containsKey('filterById')) {
        final filterById = queryParameters['filterById'].toString();
        final objectId = ObjectId.fromHexString(filterById);
        result['objectId'] = objectId;
        final itemToDelete = await db.collection(collection).findOne(where.id(objectId));
        result['filterById'] = filterById;
        result['itemToDelete '] = itemToDelete;
        if (itemToDelete != null) {
          await db.collection(collection).remove(itemToDelete);
        } else {
          throw NotFoundException();
        }
      }

      final json = jsonEncode(result);
      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.write(json);
    } on NotFoundException {
      throw GalileoHttpException.badRequest(message: 'Não encontrado');
    } catch (e, s) {
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void create(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final Map<String, dynamic> data = req.bodyAsMap;
      //final Map<String, dynamic> params = req.params;
      final Map<String, dynamic> queryParameters = req.queryParameters;
      final collection = queryParameters['collection'].toString();
      if (collection.contains('user')) {
        throw UnauthorizedException();
      }
      await db.collection(collection).insert(data);
      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.json({'message': 'StatusMessage.SUCCESS'});
    } catch (e, s) {
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void updateBy(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final Map<String, dynamic> data = req.bodyAsMap;
      //final Map<String, dynamic> params = req.params;
      final Map<String, dynamic> queryParameters = req.queryParameters;
      final collection = queryParameters['collection'].toString();
      if (collection.contains('user')) {
        throw UnauthorizedException();
      }
      if (queryParameters.containsKey('filterByMap')) {
        final filterByMap = jsonDecode(queryParameters['filterByMap'].toString());
        final Map<String, dynamic> item = await db.collection(collection).findOne(filterByMap);
        final mesclado = CombinedMapView([data, item]);
        // ignore: deprecated_member_use
        await db.collection(collection).save(mesclado);
      } else if (queryParameters.containsKey('filterById')) {
        final filterById = queryParameters['filterById'].toString();
        final Map<String, dynamic> item =
            await db.collection(collection).findOne(where.id(ObjectId.fromHexString(filterById)));
        final mesclado = CombinedMapView([data, item]);
        // ignore: deprecated_member_use
        await db.collection(collection).save(mesclado);
      }

      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.json({'message': 'StatusMessage.SUCCESS'});
    } catch (e, s) {
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }
}
