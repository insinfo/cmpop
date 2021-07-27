import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:cmpop_browser/src/shared/utils/utils.dart';
import 'package:cmpop_core/cmpop_core.dart';

class MidiaRepository {
  RestConfigBase restConfig;
  http.Client client = http.Client();

  MidiaRepository(this.restConfig);

  Future<dynamic> create(
    Midia midia, {
    bool resizeImage = false,
    bool compressImage = false,
    int maxImageSize = 1024,
  }) async {
    var url = '${restConfig.serverURL}/midias';
    return uploadFiles(url, [midia.file],
        dataToSender: midia.toMap(),
        maxImageSize: maxImageSize,
        compressImage: compressImage,
        resizeImage: resizeImage);
  }

  Future<dynamic> update(
    Midia midia, {
    bool resizeImage = false,
    bool compressImage = false,
    int maxImageSize = 1024,
  }) async {
    var url = '${restConfig.serverURL}/midias';
    url = '$url/${midia.id}';
    return uploadFiles(url, [midia.file],
        dataToSender: midia.toMap(),
        maxImageSize: maxImageSize,
        compressImage: compressImage,
        resizeImage: resizeImage);
  }

  Future<dynamic> uploadFiles(
    String url,
    List<html.File> files, {
    Map<String, String> headers,
    dynamic dataToSender,
    String bodyEncoding = 'utf8',
    Map<String, String> queryParams,
    bool resizeImage = false,
    bool compressImage = false,
    int maxImageSize = 1024,
  }) async {
    var headersDefault = {'Authorization': 'Bearer ' + html.window.sessionStorage['YWNjZXNzX3Rva2Vu'].toString()};

    var requestUrl = Uri.parse(url);
    if (queryParams != null) {
      var queryString = Uri(queryParameters: queryParams).query;
      requestUrl = Uri.parse(url + '?' + queryString);
    }

    var request = http.MultipartRequest('POST', requestUrl);

    if (headers != null) {
      request.headers.addAll(headers);
    } else {
      request.headers.addAll(headersDefault);
    }

    if (dataToSender != null) {
      if (dataToSender is Map<String, dynamic>) {
        if (bodyEncoding == null) {
          request.fields['data'] = jsonEncode(dataToSender);
        } else if (bodyEncoding == 'utf8') {
          request.fields['data'] = jsonEncode(dataToSender);
          //ISO-8859-1
        } else if (bodyEncoding == 'latin1') {
          var latin1Bytes = latin1.encode(jsonEncode(dataToSender));
          request.fields['data'] = latin1Bytes.toString();
        }
      } else {
        request.fields['data'] = dataToSender;
      }
    }

    if (files?.isNotEmpty == true) {
      for (var file in files) {
        if (file != null) {
          var fileBytes;

          fileBytes = await Utils.fileToArrayBuffer(file);

          request.files.add(http.MultipartFile.fromBytes('file[]', fileBytes,
              contentType: MediaType('application', 'octet-stream'), filename: file.name));
        }
      }
    }

    var streamedResponse = await request.send();
    var resp = await http.Response.fromStream(streamedResponse);

    return resp;
  }

  Future<List<Map<String, dynamic>>> all({Filtro filtro}) async {
    var list = <Map<String, dynamic>>[];
    var url = '${restConfig.serverURL}/midias';
    if (filtro != null) {
      url = '$url?${filtro.queryString}';
    }
    var resp = await client.get(url, headers: restConfig.defaultHeaders);
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

  Future<void> deleteMidiaById(String id) async {
    var client = http.Client();
    var resp = await client.delete('${restConfig.serverURL}/midias/$id', headers: restConfig.defaultHeaders);
    if (resp.statusCode != 200) {
      throw Exception('Falha ao criar ao deletar');
    }
  }
}
