import 'dart:convert';

import 'package:cmpop_core/src/utils/utils_core.dart';

class Filtro {
  Filtro({
    this.limit,
    this.offset,
    this.searchText,
  });

  int limit = 20;
  int offset = 0;
  String searchText;
  List searchFields = ['title', 'description'];

  String sortBy = 'dataCadastro';
  bool sortDir = true;
  Map<String, dynamic> rawQuery;

  Map<String, dynamic> filterByMap;
  List<Map<String, dynamic>> filterByWhere;

  final _params = <String, dynamic>{};

  bool get isLimit => limit != null;
  bool get isOffset => offset != null;
  bool get isSearchText => searchText != null && searchFields?.isNotEmpty == true;

  void addParam(String field, String value) {
    _params['$field'] = value;
  }

  String get queryString {
    // Transformer.urlEncodeMap(Map<String, dynamic>);

    if (sortBy != null) {
      _params['sortBy'] = sortBy;
    }

    if (sortDir != null) {
      _params['sortDir'] = sortDir;
    }

    if (isLimit) {
      _params['limit'] = '$limit';
    }
    if (isOffset) {
      _params['offset'] = '$offset';
    }
    if (isSearchText) {
      _params['search'] = searchText;
      _params['searchFields'] = jsonEncode(searchFields);
    }

    if (filterByMap != null) {
      _params['filterByMap'] = '${jsonEncode(filterByMap)}';
    }
    if (filterByWhere != null) {
      _params['filterByWhere'] = '${jsonEncode(filterByWhere)}';
    }

    var queryString = UtilsCore.urlEncodeMap(_params);

    return queryString;
  }
}
