import 'dart:convert';

class Filtros {
  Filtros({
    this.limit = 40,
    this.offset = 0,
    this.sortBy,
    this.sortDir,
    this.search,
    this.searchFields,
    this.excludeFields,
    this.sortByMap,
  });

  static Filtros instance;
  static Filtros getInstance() {
    instance ??= Filtros();
    return instance;
  }

  List<Map<String, dynamic>> filterByWhere;
  Map<String, dynamic> rawQuery;
  Map<String, dynamic> filterByMap;
  Map<String, dynamic> projection;
  List<String> excludeFields;
  List<Map<String, dynamic>> aggregateQuery;
  int offset = 0;
  int limit = 40;

  ///  para ordenação simples, não utilize este em combinação com sortByMap
  String sortBy;
  bool sortDir;
  String search;
  List<String> searchFields;

  ///  para ordenação complexa, não utilize este em combinação com sortBy|sortDir
  Map<String, dynamic> sortByMap;

  Filtros.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('filterByWhere')) {
      final f = map['filterByWhere'];
      if (f is String) {
        filterByWhere = jsonDecode(f);
      }
    }

    if (map.containsKey('filterByMap')) {
      filterByMap = jsonDecode(map['filterByMap'].toString()) as Map<String, dynamic>;
    }

    if (map.containsKey('sortByMap')) {
      sortByMap = jsonDecode(map['sortByMap'].toString()) as Map<String, dynamic>;
    }

    if (map.containsKey('projection')) {
      projection = jsonDecode(map['projection'].toString()) as Map<String, dynamic>;
    }

    if (map.containsKey('aggregateQuery')) {
      var agg = jsonDecode(map['aggregateQuery'].toString());
      if (agg is List) {
        aggregateQuery = agg.map((e) => e as Map<String, dynamic>).toList();
      }
    }

    if (map.containsKey('excludeFields')) {
      var fields = jsonDecode(map['excludeFields'].toString());
      if (fields is List) {
        excludeFields = fields.map((e) => e as String).toList();
      }
    }

    if (map.containsKey('search')) {
      search = map['search'].toString();
    }
    if (map.containsKey('searchFields')) {
      var f = jsonDecode(map['searchFields'].toString());
      if (f is List) {
        searchFields = f.map((e) => e as String).toList();
      }
    }
    if (map.containsKey('rawQuery')) {
      rawQuery = jsonDecode(map['rawQuery'].toString()) as Map<String, dynamic>;
    }

    if (map.containsKey('limit')) {
      limit = int.tryParse(map['limit'].toString());
      limit ??= 40;
    }

    if (map.containsKey('offset')) {
      offset = int.tryParse(map['offset'].toString());
      offset ??= 0;
    }
    if (map.containsKey('sortBy')) {
      sortBy = map['sortBy'].toString();
      final sortD = map.containsKey('sortDir');
      sortDir = false;
      if (sortD) {
        sortDir = map['sortDir'] == 'true';
      }
    }
  }
  bool get isFilterByWhere => filterByWhere != null;
  bool get isRawQuery => rawQuery != null;
  bool get isFilterByMap => filterByMap != null;
  bool get isAggregateQuery => aggregateQuery != null;
  bool get isProjection => projection != null;
  bool get isExcludeFields => excludeFields?.isNotEmpty == true;

  bool get isLimit => limit != null;
  bool get isOffset => offset != null;
  bool get isSearch => search != null && searchFields?.isNotEmpty == true;

  bool get isSort => sortBy != null;
  bool get isSortByMap => sortByMap != null;

  String queryParamsString() {
    var queryParams = '';
    if (searchFields != null) {
      var searchFieldsJson = jsonEncode(searchFields);
      queryParams = '$queryParams&searchFields=$searchFieldsJson';
    }

    if (excludeFields != null) {
      var excludeFieldsJson = jsonEncode(excludeFields);
      queryParams = '$queryParams&excludeFields=$excludeFieldsJson';
    }
    if (rawQuery != null) {
      var rawJson = jsonEncode(rawQuery);
      queryParams = '$queryParams&rawQuery=$rawJson';
    }
    if (aggregateQuery != null) {
      var aggregateQueryJson = jsonEncode(aggregateQuery);
      queryParams = '$queryParams&aggregateQuery=$aggregateQueryJson';
    }
    if (filterByMap != null) {
      var fbm = jsonEncode(filterByMap);
      queryParams = '$queryParams&filterByMap=$fbm';
    }

    if (sortByMap != null) {
      var sByMap = jsonEncode(sortByMap);
      queryParams = '$queryParams&sortByMap=$sByMap';
    }

    if (projection != null) {
      var projectionJson = jsonEncode(projection);
      queryParams = '$queryParams&projection=$projectionJson';
    }
    if (search != null) {
      queryParams = '$queryParams&search=$search';
    }

    if (limit != null) {
      queryParams = '$queryParams&limit=$limit';
    }
    if (offset != null) {
      queryParams = '$queryParams&offset=$offset';
    }
    if (sortBy != null) {
      queryParams = '$queryParams&sortBy=$sortBy';
    }

    if (sortDir != null) {
      queryParams = '$queryParams&sortDir=$sortDir';
    }

    return queryParams;
  }
}
