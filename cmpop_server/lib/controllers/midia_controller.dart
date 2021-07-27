import 'dart:convert';

import 'package:galileo_framework/galileo_framework.dart';
import 'package:cmpop_core/cmpop_core.dart';

import 'package:cmpop_server/repositories/midia_repository.dart';

class MidiaController {
  static void all(RequestContext req, ResponseContext res) async {
    try {
      final Map<String, dynamic> queryParameters = req.queryParameters;
      final repository = MidiaRepository();
      final re = await repository.getAllAsMap(queryParameters);
      final json = jsonEncode(re);

      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      // res.headers['total-records'] = re.totalRecords.toString();
      res.write(json);
    } catch (e, s) {
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void getById(RequestContext req, ResponseContext res) async {
    try {
      //await req.parseBody();
      //final Map<String, dynamic> payload = req.bodyAsMap;
      final Map<String, dynamic> payload = req.params;
      if (!payload.containsKey('id')) {
        throw GalileoHttpException.badRequest(message: "Id é obrigatorio. :)");
      }
      final repository = MidiaRepository();
      final re = await repository.getByIdAsMap(payload['id'].toString());
      final json = jsonEncode(re);
      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.write(json);
    } catch (e, s) {
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void create(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      Map<String, dynamic> payload = req.bodyAsMap;

      if (payload?.containsKey('data') == false) {
        throw GalileoHttpException.badRequest(message: "Os metadados são obrigatorios. :)");
      }
      if (req.uploadedFiles.isEmpty) {
        throw GalileoHttpException.badRequest(message: "Selecione o arquivo para upload. :)");
      }

      final data = jsonDecode(payload['data'].toString());
      payload = data as Map<String, dynamic>;

      //final Map<String, dynamic> params = req.params;
      //final Map<String, dynamic> queryParameters = req.queryParameters;

      final repository = MidiaRepository();
      await repository.createFromMapWithFiles(payload, req.uploadedFiles[0]);

      res.headers['Content-Type'] = 'application/json;charset=utf-8';

      res.json({'message': StatusMessage.SUCCESS});
    } catch (e, s) {
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void update(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      Map<String, dynamic> payload = req.bodyAsMap;
      if (payload?.containsKey('data') == false) {
        throw GalileoHttpException.badRequest(message: "Os metadados são obrigatorios. :)");
      }
      final json = jsonDecode(payload['data'].toString());

      payload = json as Map<String, dynamic>;
      UploadedFile file;

      if (req.uploadedFiles.isNotEmpty) {
        file = req.uploadedFiles[0];
      }

      final repository = MidiaRepository();
      await repository.updateFromMapWithFiles(payload, file);

      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.json({'message': StatusMessage.SUCCESS});
    } on FormatException {
      throw GalileoHttpException.badRequest(message: 'Formato dos metadados esta invalido (JSON Invalido)');
    } catch (e, s) {
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void deleteAll(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final payloads = req.bodyAsList;

      final List<Map<String, dynamic>> items = <Map<String, dynamic>>[];
      payloads.forEach((i) {
        items.add(i as Map<String, dynamic>);
      });

      final usuarioRepository = MidiaRepository();
      await usuarioRepository.deleteAllFromMaps(items);
      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.json({'message': StatusMessage.SUCCESS});
    } catch (e, s) {
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void delete(RequestContext req, ResponseContext res) async {
    try {
      final id = req.params['id'].toString();
      final usuarioRepository = MidiaRepository();
      await usuarioRepository.deleteById(id);
      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.json({'message': StatusMessage.SUCCESS});
    } catch (e, s) {
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }
}
