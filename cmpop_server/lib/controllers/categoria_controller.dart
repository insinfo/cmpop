import 'dart:convert';

import 'package:galileo_framework/galileo_framework.dart';
import 'package:cmpop_core/cmpop_core.dart';
import 'package:cmpop_server/repositories/categoria_repository.dart';

class CategoriaController {
  CategoriaController();
  static void all(RequestContext req, ResponseContext res) async {
    try {
      final result = await CategoriaRepository().all(Filtros.fromMap(req.queryParameters));
      res.headers.addAll(result.typeAndTotalHeaders);
      res.write(result.asJson());
    } catch (e, s) {
      print('CategoriaController@all $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void findById(RequestContext req, ResponseContext res) async {
    try {
      final result = await CategoriaRepository().findById(req.params['id'] as String);
      res.headers.addAll(result.typeAndTotalHeaders);
      res.write(result.asJson());
    } catch (e, s) {
      print('CategoriaController@findById $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void deleteById(RequestContext req, ResponseContext res) async {
    try {
      final id = req.params['id'] as String;
      final result = await CategoriaRepository().deleteById(id);
      res.headers.addAll(result.typeAndTotalHeaders);
      res.json({'message': 'StatusMessage.SUCCESS'});
    } catch (e, s) {
      print('CategoriaController@deleteById $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void create(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final result = await CategoriaRepository().create(req.bodyAsMap);
      res.headers.addAll(result.typeAndTotalHeaders);
      res.json({'message': 'StatusMessage.SUCCESS'});
    } catch (e, s) {
      print('CategoriaController@create $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void updateById(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final data = req.bodyAsMap;
      final id = req.params['id'] as String;
      final queryParams = req.queryParameters;

      final ignoreFields =
          queryParams.containsKey('ignoreFields') ? jsonDecode(queryParams['ignoreFields'].toString()) : null;

      final result = await CategoriaRepository().updateById(data, id, ignoreFields: ignoreFields as List<String>);
      res.headers.addAll(result.typeAndTotalHeaders);
      res.json({'message': 'StatusMessage.SUCCESS'});
    } catch (e, s) {
      print('CategoriaController@updateById $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void findByMap(RequestContext req, ResponseContext res) async {
    try {
      final result = await CategoriaRepository()
          .findByMap(jsonDecode(req.queryParameters['map'] as String) as Map<String, dynamic>);
      res.headers.addAll(result.typeAndTotalHeaders);
      res.write(result.asJson());
    } catch (e, s) {
      print('CategoriaController@findByMap $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void findByKeyValue(RequestContext req, ResponseContext res) async {
    try {
      //String byKey, String byValue
      final result = await CategoriaRepository().findByKeyValue(
        req.params['byKey'] as String,
        req.params['byValue'] as String,
      );
      res.headers.addAll(result.typeAndTotalHeaders);
      res.write(result.asJson());
    } catch (e, s) {
      print('CategoriaController@findPontoGastronomicoByAsMap $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void countSlug(RequestContext req, ResponseContext res) async {
    try {
      final idForIgnore =
          req.queryParameters.containsKey('idForIgnore') ? req.queryParameters['idForIgnore'] as String : null;
      final result =
          await CategoriaRepository().countSlugsAsMap(req.queryParameters['slug'] as String, idForIgnore: idForIgnore);
      // print('ComercioController@countSlug ${req.queryParameters['slug']}');
      res.headers.addAll(result.typeAndTotalHeaders);
      res.write(result.asJson());
    } catch (e, s) {
      print('CategoriaController@countSlug $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }
}
