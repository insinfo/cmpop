import 'package:mongo_dart/mongo_dart.dart';
import 'package:cmpop_core/cmpop_core.dart';
import 'package:cmpop_server/exceptions/not_found_exception.dart';

import '../app_config.dart';
import '../db_connect.dart';

class RepositoryBase {
  RepositoryBase(this._collection);

  final String _collection;

  String get collection => _collection;

  //set collection(String c) => _collection = c;

  final _parents = [
    'midia',
    'midias',
    'imagem',
    'imagens',
    'backgroundImagem',
    'foregroundImagem',
  ];

  Future<RepositoryResult> all(Filtros filtros) async {
    final pipeline = AggregationPipelineBuilder();

    //Filtra os documentos para passar apenas os documentos que correspondem às condições especificadas para o próximo estágio do pipeline
    if (filtros.isFilterByMap) {
      pipeline.addStage(Match(filtros.filterByMap));
    }

    if (filtros.isSearch) {
      final map = {
        '\$or': filtros.searchFields
            .map((field) => {
                  '$field': {'\$regex': '${filtros.search}', '\$options': 'i'}
                })
            .toList()
      };
      pipeline.addStage(Match(map));
    }

    //ordenação simples
    if (filtros.isSort == true && filtros.isSortByMap == false) {
      pipeline.addStage(Sort({"${filtros.sortBy}": filtros.sortDir ? 1 : -1}));
    }
    //ordenação complexa
    if (filtros.isSort == false && filtros.isSortByMap == true) {
      pipeline.addStage(Sort(filtros.sortByMap));
    }
    //projection
    //pipeline.addStage(Project({'_id': 0}));
    //replaceRoot para eliminar os campos do pai
    //pipeline.addStage(ReplaceRoot('\$$subCollectionName'));

    //paginação
    if (filtros.isLimit) {
      pipeline.addStage(Facet({
        'results': [Skip(filtros.offset), Limit(filtros.limit)],
        'totalRecords': [Count('count')]
      }));
    }

    final query = pipeline.build();
    //print('RepositoryBase@all ${query}');
    final cursor = db.collection(_collection).modernAggregate(query);
    final map = await cursor?.first;
    return RepositoryResult.fromMap(map);
  }

  Future<RepositoryResult> allOld(Filtros filtros) async {
    List<Map<String, dynamic>> result;

    SelectorBuilder qb = SelectorBuilder();

    if (filtros.isFilterByWhere) {
      filtros.filterByWhere.forEach((map) {
        if (map['op'] == 'eq') {
          qb = where.eq(map['key'].toString(), map['value']);
        } else if (map['op'] == 'ne') {
          qb = where.ne(map['key'].toString(), map['value']);
        }
      });
    }

    if (filtros.isFilterByMap) {
      filtros.filterByMap.forEach((key, value) {
        qb = where.eq(key, value);
      });
    }

    if (filtros.isSearch) {
      final map = <String, dynamic>{};
      map['\$query'] = {
        '\$or': filtros.searchFields
            .map((field) => {
                  '$field': {'\$regex': '${filtros.search}', '\$options': 'i'}
                })
            .toList()
      };
      qb.raw(map);
    }

    if (filtros.isRawQuery) {
      qb.raw(filtros.rawQuery);
    }

    if (filtros.isLimit) {
      if (qb is SelectorBuilder) {
        qb.limit(filtros.limit);
      } else {
        qb = where.limit(filtros.limit);
      }
    }
    if (filtros.isOffset) {
      if (qb is SelectorBuilder) {
        qb.skip(filtros.offset);
      } else {
        qb = where.skip(filtros.offset);
      }
    }
    if (filtros.isSort) {
      if (qb is SelectorBuilder) {
        qb.sortBy(filtros.sortBy, descending: filtros.sortDir);
      } else {
        qb = where.sortBy(filtros.sortBy, descending: filtros.sortDir);
      }
    }
    Map<String, dynamic> projection;
    //exemplo de projeção que elimina o campo pontosGastronomicos: {"pontosGastronomicos":0}
    if (filtros.isProjection) {
      projection = filtros.projection;
    }
    if (filtros.isExcludeFields) {
      qb.excludeFields(filtros.excludeFields);
      //projection = {for (var v in filtros.excludeFields) v: 0};
    }

    // print('RepositoryBase@collectionAll ${qb.toString()}');
    result = await db.collection(_collection).modernFind(selector: qb, projection: projection).toList();

    //faz o merge das midias
    if (result?.isNotEmpty == true) {
      final idsMidias = UtilsCore.getStringIdsRecursiveFromList(result, _parents);
      //pega os ids de midias
      /* result.forEach((map) {
          idsMidias.addAll(UtilsCore.getStringIdsRecursiveFromMap(map, parents));
        });*/

      // print('idsMidias $idsMidias');

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
                _parents,
                newMidia,
                (map) => map['id'] == newMidia['id'],
              );
            });
          });
        }
      }
    }

    return RepositoryResult(results: result);
  }

  Future<RepositoryResult> allSubCollectionItemsAsMap(Filtros filtros, String subCollectionName) async {
    final pipeline = AggregationPipelineBuilder();
    //Desconstrói um campo de array dos documentos de entrada para gerar um documento para cada elemento
    pipeline.addStage(Unwind(Field(subCollectionName)));
    //Filtra os documentos para passar apenas os documentos que correspondem às condições especificadas para o próximo estágio do pipeline
    if (filtros.isSearch) {
      final map = {
        '\$or': filtros.searchFields
            .map((field) => {
                  '$subCollectionName.$field': {'\$regex': '${filtros.search}', '\$options': 'i'}
                })
            .toList()
      };
      pipeline.addStage(Match(map));
    }
    //ordena
    if (filtros.isSort) {
      pipeline.addStage(Sort({"$subCollectionName.${filtros.sortBy}": filtros.sortDir ? 1 : -1}));
    }
    //projection
    //pipeline.addStage(Project({'_id': 0}));
    //replaceRoot para eliminar os campos do pai
    pipeline.addStage(ReplaceRoot('\$$subCollectionName'));

    //paginação
    if (filtros.isLimit) {
      pipeline.addStage(Facet({
        'results': [Skip(filtros.offset), Limit(filtros.limit)],
        'totalRecords': [Count('count')]
      }));
    }
    //print('pipeline: ${pipeline.build()}');
    final cursor = db.collection(_collection).modernAggregate(pipeline.build());
    final map = await cursor?.first;
    return RepositoryResult.fromMap(map);
  }

  Future<Map<String, dynamic>> findFirstByAsMap({
    Map<String, dynamic> filterByMap,
    String filterByObjectId,
    Map<String, dynamic> rawQuery,
    List<Map<String, dynamic>> aggregateQuery,
  }) async {
    Map<String, dynamic> result;
    if (filterByMap != null) {
      result = await db.collection(_collection).findOne(filterByMap);
      //print('findFirstByAsMap filterByMap $filterByMap');
    } else if (filterByObjectId != null) {
      result = await db.collection(_collection).findOne(where.id(ObjectId.fromHexString(filterByObjectId)));
    } else if (rawQuery != null) {
      final qb = SelectorBuilder();
      qb.raw(rawQuery);
    } else if (aggregateQuery != null) {
      final cursor = db.collection(_collection).modernAggregateCursor(aggregateQuery);
      result = await cursor.nextObject();
      await cursor.close();
    }

    //faz o merge das midias
    if (result != null) {
      final idsMidias = <String>[];

      //pega os ids de midias

      idsMidias.addAll(UtilsCore.getStringIdsRecursiveFromMap(result, _parents));

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

    return result;
  }

  Future<RepositoryResult> findById(String objectId) async {
    return RepositoryResult(result: await findFirstByAsMap(filterByMap: {'id': objectId}));
  }

  Future<RepositoryResult> findByKeyValue(String byKey, String byValue) async {
    return findByMap({byKey: byValue});
  }

  Future<Map<String, dynamic>> findByObjectIdAsMap(String objectId) async {
    return await findFirstByAsMap(filterByObjectId: objectId);
  }

  Future<RepositoryResult> findSubCollectionItemByIdAsMap(String id, String subCollectionName) async {
    return RepositoryResult(
      result: await findFirstByAsMap(aggregateQuery: [
        {
          r'$replaceRoot': {
            'newRoot': {
              r'$arrayElemAt': [
                {
                  r'$filter': {
                    'input': '\$$subCollectionName',
                    'as': '$subCollectionName',
                    'cond': {
                      /* resolve to a boolean value and determine if an element should be included in the output array. */
                      r'$eq': ['\$\$$subCollectionName.id', id]
                    }
                  }
                },
                0 /* the element at the specified array index */
              ]
            }
          }
        }
      ]),
      totalRecords: 1,
    );
  }

  Future<RepositoryResult> findSubCollectionItemByAsMap(String byKey, String byValue, String subCollectionName) async {
    return RepositoryResult(
      result: await findFirstByAsMap(aggregateQuery: [
        {
          r'$replaceRoot': {
            'newRoot': {
              r'$arrayElemAt': [
                {
                  r'$filter': {
                    'input': '\$$subCollectionName',
                    'as': '$subCollectionName',
                    'cond': {
                      /* resolve to a boolean value and determine if an element should be included in the output array. */
                      r'$eq': ['\$\$$subCollectionName.$byKey', byValue]
                    }
                  }
                },
                0 /* the element at the specified array index */
              ]
            }
          }
        }
      ]),
      totalRecords: 1,
    );
  }

  /// [slug] exemplo => slug = bistro-pizzaria-[0-9]
  Future<RepositoryResult> countSubCollectionSlugsAsMap(String slug, String subCollectionName,
      {String idForIgnore}) async {
    final result = await findFirstByAsMap(aggregateQuery: [
      {'\$unwind': '\$$subCollectionName'},
      {
        "\$match": {
          "\$and": [
            {
              "\$or": [
                {
                  "$subCollectionName.slug": {"\$regex": "$slug-[0-9]", "\$options": "i"}
                },
                {
                  "$subCollectionName.slug": {"\$regex": "$slug", "\$options": "i"}
                },
              ]
            },
            if (idForIgnore != null)
              {
                "$subCollectionName.id": {
                  "\$not": {'\$regex': "$idForIgnore"}
                }
              }
          ]
        }
      },
      {
        '\$group': {
          '_id': '\$id',
          'count': {'\$sum': 1}
        }
      },
      {
        '\$project': {'_id': 0}
      }
    ]);

    if (result?.isNotEmpty == true) {
      return RepositoryResult(result: result, totalRecords: 1);
    }

    return RepositoryResult(result: {"count": 0}, totalRecords: 1);
  }

  Future<RepositoryResult> findBySlug(String slug) async {
    final re = await findFirstByAsMap(filterByMap: {'slug': slug});
    return RepositoryResult(
      result: re,
      totalRecords: 1,
    );
  }

  /// [slug] exemplo => slug = bistro-pizzaria-[0-9]
  Future<RepositoryResult> countSlugsAsMap(String slug, {String idForIgnore}) async {
    final aggregateQuery = [
      {
        "\$match": {
          "\$and": [
            {
              "\$or": [
                {
                  "slug": {"\$regex": "$slug-[0-9]", "\$options": "i"}
                },
                {"slug": "$slug"},
              ]
            },
            if (idForIgnore != null)
              {
                "id": {
                  "\$not": {'\$regex': "$idForIgnore"}
                }
              }
          ]
        }
      },
      {
        '\$group': {
          '_id': '\$id',
          'count': {'\$sum': 1}
        }
      },
      {
        '\$project': {'_id': 0}
      }
    ];
    final result = await findFirstByAsMap(aggregateQuery: aggregateQuery);
    //print('RepositoryBase@countSlugsAsMap aggregateQuery ${aggregateQuery}');
    if (result?.isNotEmpty == true) {
      return RepositoryResult(result: result, totalRecords: 1);
    }

    return RepositoryResult(result: {"count": 0}, totalRecords: 1);
  }

  Future<RepositoryResult> findByMap(Map<String, dynamic> map) async {
    final re = await findFirstByAsMap(filterByMap: map);
    return RepositoryResult(
      result: re,
      totalRecords: 1,
    );
  }

  Future<RepositoryResult> findSubCollectionItemByMapAsMap(Map<String, dynamic> map, String subCollectionName) async {
    final aggregateQuery = [
      {
        r"$project": {
          '_id': 0,
          "$subCollectionName": {
            r"$filter": {
              "input": "\$$subCollectionName",
              "as": "$subCollectionName",
              "cond": {
                r'$and': map.entries
                    .map((entry) => {
                          '\$eq': ['\$\$$subCollectionName.${entry.key}', entry.value]
                        })
                    .toList()
                /* {
                    r'$eq': ["\$\$$subCollectionName.id", "c1a75f09-2a75-4449-b038-22b28ba5aff9"]
                  },
                  {
                    r'$eq': [r"$$pontosGastronomicos.slug", "bistro-pizzaria"]
                  }*/
              }
            }
          }
        }
      }
    ];
    final query = await findFirstByAsMap(aggregateQuery: aggregateQuery);

    var totalRecords = 0;
    var re = <String, dynamic>{};
    if (query.containsKey(subCollectionName) && query[subCollectionName] is List) {
      if (query[subCollectionName].isNotEmpty == true) {
        re = query[subCollectionName][0] as Map<String, dynamic>;
        totalRecords = 1;
      }
    }
    return RepositoryResult(
      result: re,
      totalRecords: totalRecords,
    );
  }

  Future<void> deleteBy({
    Map<String, dynamic> filterByMap,
    String filterById,
  }) async {
    final result = <String, dynamic>{};
    if (filterByMap != null) {
      result.addAll(await db.collection(_collection).remove(filterByMap));
    } else if (filterById != null) {
      final objectId = ObjectId.fromHexString(filterById);
      result['objectId'] = objectId;
      final itemToDelete = await db.collection(_collection).findOne(where.id(objectId));
      result['filterById'] = filterById;
      result['itemToDelete '] = itemToDelete;
      if (itemToDelete != null) {
        await db.collection(_collection).remove(itemToDelete);
      } else {
        throw NotFoundException();
      }
    }
  }

  Future<RepositoryResult> deleteById(String filterId) async {
    await deleteBy(filterByMap: {'id': filterId});
    return RepositoryResult();
  }

  Future<RepositoryResult> create(Map<String, dynamic> data) async {
    await db.collection(_collection).insertOne(data);
    //print('create _collection $_collection');
    return RepositoryResult();
  }

  Future<RepositoryResult> updateBy(Map<String, dynamic> inputData, Map<String, dynamic> filterByMap,
      {String filterById, List<String> ignoreFields}) async {
    final Map<String, dynamic> data = {...inputData};

    if (ignoreFields != null) {
      ignoreFields.forEach(data.remove);
    }
    if (filterByMap != null) {
      //final Map<String, dynamic> item = await db.collection(_collection).findOne(filterByMap);
      //final mesclado = CombinedMapView([data, item]);
      // await db.collection(_collection).replaceOne(filterByMap, mesclado);
      //print('updateBy quantidade ${data["quantidade"]}');
      // print('updateBy _id ${data["_id"]}');
      await db.collection(_collection).replaceOne(filterByMap, data);
      /* print('updateBy document ${r.document}');
      print('updateBy isSuccess ${r.isSuccess}');
      print('updateBy hasWriteErrors ${r.hasWriteErrors}');
      print('updateBy writeError.errmsg ${r.writeError?.errmsg}');
      print('updateBy writeError.code} ${r.writeError?.code}');*/
    } else if (filterById != null) {
      /*final Map<String, dynamic> item =
          await db.collection(_collection).findOne(where.id(ObjectId.fromHexString(filterById)));
      final mesclado = CombinedMapView([data, item]);
      await db.collection(_collection).replaceOne(ObjectId.fromHexString(filterById), mesclado);*/

      await db.collection(_collection).replaceOne(where.id(ObjectId.fromHexString(filterById)), data);
    }
    return RepositoryResult();
  }

  Future<RepositoryResult> updateById(Map<String, dynamic> data, String filterId, {List<String> ignoreFields}) async {
    await updateBy(data, {'id': filterId}, ignoreFields: ignoreFields);
    return RepositoryResult();
  }

  Future<RepositoryResult> updateSubCollectionItemByIdFromMap(
      Map<String, dynamic> data, String filterId, String subCollectionName) async {
    /* para atualiza um parametro
    db.pontosGastronomicos.update(
    {       
      "pontosGastronomicos.id": "9d19fc7a-c72d-4d50-b5fa-366d1d9ad42e"
    },
    {
      $set: {"pontosGastronomicos.$.ativo":  false}
    }
    );
    */
    //remove item
    await db.collection(_collection).update(<String, dynamic>{}, {
      r'$pull': {
        "$subCollectionName": {"id": filterId}
      }
    });
    //add item
    await db.collection(_collection).update(<String, dynamic>{}, {
      r'$push': {"$subCollectionName": data}
    });

    return RepositoryResult();
  }

  Future<RepositoryResult> createSubCollectionItemFromMap(Map<String, dynamic> data, String subCollectionName) async {
    //add item
    await db.collection(_collection).update(<String, dynamic>{}, {
      r'$push': {"$subCollectionName": data}
    });

    return RepositoryResult();
  }

  Future<RepositoryResult> deleSubCollectionItemById(String filterId, String subCollectionName) async {
    //remove item
    await db.collection(_collection).update(<String, dynamic>{}, {
      r'$pull': {
        "$subCollectionName": {"id": filterId}
      }
    });

    return RepositoryResult();
  }
}
