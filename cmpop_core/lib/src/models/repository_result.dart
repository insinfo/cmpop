import 'dart:convert';

class RepositoryResult {
  RepositoryResult({
    this.totalRecords,
    this.results,
    this.result,
  });
  RepositoryResult.fromJson(String jsonString) {
    var items = jsonDecode(jsonString);
    fillFromMap(items);
  }
  RepositoryResult.fromMap(Map<String, dynamic> map) {
    fillFromMap(map);
  }

  void fillFromMap(Map<String, dynamic> map) {
    if (map != null) {
      if (map.containsKey('results')) {
        if (map['results'] is List) {
          final r = map['results'] as List;
          results = r.map((e) => e as Map<String, dynamic>).toList();
        }
      }
      if (map.containsKey('result')) {
        result = map['result'] as Map<String, dynamic>;
      }
      if (map.containsKey('totalRecords')) {
        if (map['totalRecords'] is List) {
          if (map['totalRecords'].isNotEmpty == true) {
            totalRecords = int.tryParse(map['totalRecords'][0]['count'].toString());
          }
        } else if (map['totalRecords'] is int) {
          totalRecords = map['totalRecords'];
        }
      }
    }
  }

  List<Map<String, dynamic>> results;
  Map<String, dynamic> result;
  int totalRecords = 0;

  Map<String, String> get typeAndTotalHeaders {
    final headers = <String, String>{};
    headers['Content-Type'] = 'application/json;charset=utf-8';
    headers['total-records'] = totalRecords.toString();
    return headers;
  }

  ///final List<Map<Type, Function>> factories; // = <Type, Function>{};
  ///ex: DiskCache<Agenda>(factories: {Agenda: (x) => Agenda.fromJson(x)});
  List<T> asTypedResults<T>(T Function(Map<String, dynamic>) manufactory) {
    var re = <T>[];
    results?.forEach((map) {
      re.add(manufactory(map));
    });
    return re;
  }

  T asTypedResult<T>(T Function(Map<String, dynamic>) manufactory) {
    return manufactory(result);
  }

  String asJson() {
    return jsonEncode({
      'result': result,
      'results': results,
      'totalRecords': totalRecords,
    });
  }
}
