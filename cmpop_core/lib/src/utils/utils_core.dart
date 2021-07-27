import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'replacements.dart';

class UtilsCore {
  static String get randomColor1 {
    final rad = Random();
    var cor = 'red';
    cor = 'rgb(${rad.nextInt(256)},${rad.nextInt(256)},${rad.nextInt(256)})';
    return cor;
  }

  /// gera codigo de Cupom
  static String generateCouponCode({int length = 8}) {
    var text = '';
    //abcdefghijklmnopqrstuvwxyz
    var possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    var rand = Random();
    for (var i = 0; i < length; i++) {
      text += possible[(rand.nextDouble() * possible.length).floor()];
    }
    return text;
  }

  static String get randomColor2 {
    var colors = [
      '#1abc9c',
      '#2ecc71',
      '#3498db',
      '#9b59b6',
      '#34495e',
      '#16a085',
      '#27ae60',
      '#2980b9',
      '#8e44ad',
      '#2c3e50',
      '#e67e22',
      '#e74c3c',
      '#d35400',
      '#c0392b',
      '#f39c12',
    ];
    var random = Random();
    return colors[random.nextInt(15)];
  }

  // obtem uma lista de IDs de uma arvore
  static List<String> getStringIdsRecursiveFromList(
    List<dynamic> mapTreeList,
    List<String> parents, {
    String keyOfParent = 'id',
  }) {
    var result = <String>[];
    mapTreeList.forEach((mapa) {
      if (mapa is Map) {
        mapa.forEach((key, value) {
          if (parents.contains(key)) {
            if (value is Map) {
              result.add(value[keyOfParent]);
            } else if (value is List) {
              value.forEach((item) {
                // if (item is Map) {
                result.add(item[keyOfParent]);
                //}
              });
            }
          } else if (value is List) {
            result.addAll(getStringIdsRecursiveFromList(value, parents, keyOfParent: keyOfParent));
          }
        });
      }
      if (mapa is List) {
        result.addAll(getStringIdsRecursiveFromList(mapa, parents, keyOfParent: keyOfParent));
      }
    });
    return result;
  }

  static void updateListMapRecursive(List<dynamic> mapTreeList, List<String> parents,
      Map<String, dynamic> keysAndNewValsToUpdate, bool Function(Map) compareFunc) {
    mapTreeList.forEach((mapTree) {
      mapTree.forEach((k, value) {
        if (parents.contains(k)) {
          if (value is Map) {
            if (compareFunc(value)) {
              keysAndNewValsToUpdate.forEach((chave, valor) {
                value[chave] = valor;
              });
            }
          } else if (value is List) {
            value.forEach((item) {
              if (item is Map) {
                if (compareFunc(item)) {
                  keysAndNewValsToUpdate.forEach((chave, valor) {
                    item[chave] = valor;
                  });
                }
              }
            });
          }
        } else if (value is List) {
          updateListMapRecursive(value, parents, keysAndNewValsToUpdate, compareFunc);
        }
      });
    });
  }

  /// Converts [text] to a slug [String] separated by the [delimiter].
  static String slugify(String text, {String delimiter = '-', bool lowercase = true}) {
    final _dupeSpaceRegExp = RegExp(r'\s{2,}');
    final _punctuationRegExp = RegExp(r'[^\w\s-]');
    // Trim leading and trailing whitespace.
    var slug = text.trim();

    // Make the text lowercase (optional).
    if (lowercase) {
      slug = slug.toLowerCase();
    }

    // Substitute characters for their latin equivalent.
    replacements.forEach((k, v) => slug = slug.replaceAll(k, v));

    slug = slug
        // Condense whitespaces to 1 space.
        .replaceAll(_dupeSpaceRegExp, ' ')
        // Remove punctuation.
        .replaceAll(_punctuationRegExp, '')
        // Replace space with the delimiter.
        .replaceAll(' ', delimiter);

    return slug;
  }

  /// get one list of String Ids from Map tree
  static List<String> getStringIdsRecursiveFromMap(
    Map<String, dynamic> mapTree,
    List<String> parents, {
    String keyOfParent = 'id',
  }) {
    var result = <String>[];

    mapTree.forEach((k, value) {
      if (parents.contains(k)) {
        if (value is Map) {
          result.add(value[keyOfParent]);
        } else if (value is List) {
          value.forEach((item) {
            if (item is Map) {
              result.add(item[keyOfParent]);
            }
          });
        }
      } else if (value is Map) {
        result.addAll(getStringIdsRecursiveFromMap(value, parents));
      } else if (value is List) {
        value?.forEach((a) {
          if (a is Map) {
            result.addAll(getStringIdsRecursiveFromMap(a, parents));
          } else if (a is List) {
            a?.forEach((b) {
              if (b is Map) {
                result.addAll(getStringIdsRecursiveFromMap(b, parents));
              }
            });
          }
        });
      }
    });

    return result;
  }

  /// Atualiza um Map que o parent seja um dos [parents] fornecidos
  /// com a chave e valor fornecido no parametro [keysAndNewValsToUpdate] e com a função de condição [compare]
  /// Exemplo:
  /// UtilsCore.updateMapRecursive(
  ///                map,
  ///                ['midia', 'midias'],
  ///                newMidia,
  ///                (map) => map['id'] == newMidia['id'],
  ///              );
  ///
  static void updateMapRecursive(Map<String, dynamic> mapTree, List<String> parents,
      Map<String, dynamic> keysAndNewValsToUpdate, bool Function(Map) compare) {
    mapTree.forEach((k, value) {
      if (parents.contains(k)) {
        if (value is Map) {
          if (compare(value)) {
            keysAndNewValsToUpdate.forEach((chave, valor) {
              value[chave] = valor;
            });
          }
        } else if (value is List) {
          value.forEach((item) {
            if (item is Map) {
              if (compare(item)) {
                keysAndNewValsToUpdate.forEach((chave, valor) {
                  item[chave] = valor;
                });
              }
            }
          });
        }
      } else if (value is Map) {
        updateMapRecursive(value, parents, keysAndNewValsToUpdate, compare);
      } else if (value is List) {
        value?.forEach((a) {
          if (a is Map) {
            updateMapRecursive(a, parents, keysAndNewValsToUpdate, compare);
          } else if (a is List) {
            a?.forEach((b) {
              if (b is Map) {
                updateMapRecursive(b, parents, keysAndNewValsToUpdate, compare);
              }
            });
          }
        });
      }
    });
  }

  static String toDateString(DateTime date) {
    /* return (date.year.toString() + '-' 
       + '0${date.month + 1}').substring(-2) + '-' 
       + '0'+ date.getDate())).slice(-2))
       + 'T' + date.toTimeString().slice(0,5);*/
    return '';
  }

  static DateTime parseDateString(String date) {
    date = date.replaceFirst('T', '-');
    var parts = date.split('-');
    var timeParts = parts[3].split(':');

    // new Date(year, month [, day [, hours[, minutes[, seconds[, ms]]]]])
    return DateTime(
      int.tryParse(parts[0]),
      int.tryParse(parts[1]) - 1,
      int.tryParse(parts[2]),
      int.tryParse(timeParts[0]),
      int.tryParse(timeParts[1]),
    ); // Note: months are 0-based
  }

  static String removerAcentos(String s) {
    if (s == null) {
      return s;
    }
    var map = <String, String>{
      'â': 'a',
      'Â': 'A',
      'à': 'a',
      'À': 'A',
      'á': 'a',
      'Á': 'A',
      'ã': 'a',
      'Ã': 'A',
      'ê': 'e',
      'Ê': 'E',
      'è': 'e',
      'È': 'E',
      'é': 'e',
      'É': 'E',
      'î': 'i',
      'Î': 'I',
      'ì': 'i',
      'Ì': 'I',
      'í': 'i',
      'Í': 'I',
      'õ': 'o',
      'Õ': 'O',
      'ô': 'o',
      'Ô': 'O',
      'ò': 'o',
      'Ò': 'O',
      'ó': 'o',
      'Ó': 'O',
      'ü': 'u',
      'Ü': 'U',
      'û': 'u',
      'Û': 'U',
      'ú': 'u',
      'Ú': 'U',
      'ù': 'u',
      'Ù': 'U',
      'ç': 'c',
      'Ç': 'C'
    };
    var result = s;
    map.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  ///String queryString = Uri(queryParameters: {'x': '1', 'y': '2'}).query;
  ///print(queryString); // x=1&y=2
  /// Deep encode the [Map<String, dynamic>] to percent-encoding.
  /// It is mostly used with  the "application/x-www-form-urlencoded" content-type.
  static String urlEncodeMap(Map map) {
    return encodeMap(map, (key, value) {
      if (value == null) return key;
      return '$key=${Uri.encodeQueryComponent(value.toString())}';
    });
  }

  static DateTime subtrairDias(DateTime data, int dias) {
    //millisecondsSinceEpoch
    //The number of milliseconds since the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
    //Um número representando os milissegundos passados entre 1 de Janeiro de 1970 00:00:00
    var time = data.millisecondsSinceEpoch;
    var cal = (dias * 24 * 60 * 60 * 1000);
    var result = DateTime.fromMillisecondsSinceEpoch(time - cal);
    return result;
  }

  static void searchCarnaval(int ano) {
    var X = 24;
    var Y = 5;
    var a = ano % 19;
    var b = ano % 4;
    var c = ano % 7;
    var d = (19 * a + X) % 30;
    var e = (2 * b + 4 * c + 6 * d + Y) % 7;
    var soma = d + e;
    var dia, mes;
    if (soma > 9) {
      dia = (d + e - 9);
      mes = 03;
    } else {
      dia = (d + e + 22);
      mes = 02;
    }
    mes = mes + 1; //fix
    var pascoa = DateTime(ano, mes, dia);
    print('Carnaval: ' + subtrairDias(DateTime(ano, mes, dia), 47).toString());
    print('Domingo de Pascoa: $pascoa');
    print('Quarta-Feira de cinzas: ' + subtrairDias(DateTime(ano, mes, dia), 46).toString());
  }

  /// A regular expression that matches strings that are composed entirely of
  /// ASCII-compatible characters.
  static final RegExp _asciiOnly = RegExp(r'^[\x00-\x7F]+$');

  /// Returns whether [string] is composed entirely of ASCII-compatible
  /// characters.
  static bool isPlainAscii(String string) => _asciiOnly.hasMatch(string);

  /// Pipes all data and errors from [stream] into [sink]. Completes [Future] once
  /// [stream] is done. Unlike [store], [sink] remains open after [stream] is
  /// done.
  static Future writeStreamToSink(Stream stream, EventSink sink) {
    var completer = Completer();
    stream.listen(sink.add, onError: sink.addError, onDone: () => completer.complete());
    return completer.future;
  }

  /// Returns the [Encoding] that corresponds to [charset]. Returns [fallback] if
  /// [charset] is null or if no [Encoding] was found that corresponds to
  /// [charset].
  static Encoding encodingForCharset(String charset, [Encoding fallback = latin1]) {
    if (charset == null) return fallback;
    var encoding = Encoding.getByName(charset);
    return encoding ?? fallback;
  }

  static String encodeMap(data, Function(String key, Object value) handler, {bool encode = true}) {
    var urlData = StringBuffer('');
    var first = true;
    var leftBracket = encode ? '%5B' : '[';
    var rightBracket = encode ? '%5D' : ']';
    var encodeComponent = encode ? Uri.encodeQueryComponent : (e) => e;
    void urlEncode(dynamic sub, String path) {
      if (sub is List) {
        for (var i = 0; i < sub.length; i++) {
          urlEncode(sub[i], '$path$leftBracket${(sub[i] is Map || sub[i] is List) ? i : ''}$rightBracket');
        }
      } else if (sub is Map) {
        sub.forEach((k, v) {
          if (path == '') {
            urlEncode(v, '${encodeComponent(k)}');
          } else {
            urlEncode(v, '$path$leftBracket${encodeComponent(k)}$rightBracket');
          }
        });
      } else {
        var str = handler(path, sub);
        var isNotEmpty = str != null && str.trim().isNotEmpty;
        if (!first && isNotEmpty) {
          urlData.write('&');
        }
        first = false;
        if (isNotEmpty) {
          urlData.write(str);
        }
      }
    }

    urlEncode(data, '');
    return urlData.toString();
  }

  static String getQueryString(Map params, {String prefix = '&', bool inRecursion = false}) {
    var query = '';

    params.forEach((key, value) {
      if (inRecursion) {
        key = '[$key]';
      }

      if (value is String || value is int || value is double || value is bool) {
        query += '$prefix$key=$value';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query += getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });

    return query;
  }

  /// Parses the given query string into a Map.
  static Map queryStringParse(String query) {
    var search = RegExp('([^&=]+)=?([^&]*)');
    var result = {};

    // Get rid off the beginning ? in query strings.
    if (query.startsWith('?')) query = query.substring(1);

    // A custom decoder.
    String decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

    // Go through all the matches and build the result map.
    for (Match match in search.allMatches(query)) {
      result[decode(match.group(1))] = decode(match.group(2));
    }

    return result;
  }
}
