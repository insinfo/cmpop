import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:galileo_framework/galileo_framework.dart';
import 'package:cmpop_core/cmpop_core.dart';
import 'package:cmpop_server/services/prepara_template.dart';
import '../repositories/formulario_inscricao_repository.dart';
import '../services/envia_email.dart';

//FormularioInscricaoApi
class FormularioInscricaoController {
  FormularioInscricaoController();

  static void enviaFormularioToEmail(RequestContext req, ResponseContext res) async {
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

      final formModel = FormularioInscricaoModel.fromMap(payload);
      final formData = formModel.toMap();

      formData['dataNascimento'] = DateFormat('dd/MM/yyyy').format(formModel.dataNascimento);
      //formData['funcionarioBilingue'] = formModel.funcionarioBilingue == true ? 'sim' : 'não';
      /* formData['estruturas'] = formModel.estruturas
          .where((e) => e.checked)
          .map((e) => {'checked': e.checked, 'titlePt': e.titlePt})
          .toList();*/

      // Prepara template HTML
      final template = await PreparaTemplate().prepara(formData, 'formulario_inscricao.html');

      // Envia email
      final enviaEmail = EnviaEmail()
        ..assunto = 'CMPOP :: Formulário de inscrição'
        ..html = template
        ..deNome = 'CMPOP'
        ..deEmail = 'desenv.pmro@gmail.com'
        ..paraEmail = 'desenv.pmro@gmail.com'
        ..addDestinoEmail('desenv.pmro@gmail.com');

      req.uploadedFiles.forEach((file) {
        enviaEmail.addFileData(file.data, file.contentType.mimeType, fileName: file.filename);
      });
      await enviaEmail.envia();

      /* ////////////////////// armazena no banco ////////////////////// */
      await FormularioInscricaoRepository().create(formModel.toMap());

      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.json({'message': 'StatusMessage.SUCCESS'});
    } catch (e, s) {
      print('FormularioInscricaoController@enviaFormularioToEmail $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void all(RequestContext req, ResponseContext res) async {
    try {
      final result = await FormularioInscricaoRepository().all(Filtros.fromMap(req.queryParameters));
      res.headers.addAll(result.typeAndTotalHeaders);
      res.write(result.asJson());
    } catch (e, s) {
      print('FormularioInscricaoController@all $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void findById(RequestContext req, ResponseContext res) async {
    try {
      final result = await FormularioInscricaoRepository().findById(req.params['id'] as String);
      res.headers.addAll(result.typeAndTotalHeaders);
      res.write(result.asJson());
    } catch (e, s) {
      print('FormularioInscricaoController@findById $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void deleteById(RequestContext req, ResponseContext res) async {
    try {
      final id = req.params['id'] as String;
      final result = await FormularioInscricaoRepository().deleteById(id);
      res.headers.addAll(result.typeAndTotalHeaders);
      res.json({'message': 'StatusMessage.SUCCESS'});
    } catch (e, s) {
      print('FormularioInscricaoController@deleteById $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void create(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final result = await FormularioInscricaoRepository().create(req.bodyAsMap);
      res.headers.addAll(result.typeAndTotalHeaders);
      res.json({'message': 'StatusMessage.SUCCESS'});
    } catch (e, s) {
      print('FormularioInscricaoController@create $s');
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

      final result =
          await FormularioInscricaoRepository().updateById(data, id, ignoreFields: ignoreFields as List<String>);
      res.headers.addAll(result.typeAndTotalHeaders);
      res.json({'message': 'StatusMessage.SUCCESS'});
    } catch (e, s) {
      print('FormularioInscricaoController@updateById $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void findByMap(RequestContext req, ResponseContext res) async {
    try {
      final result = await FormularioInscricaoRepository()
          .findByMap(jsonDecode(req.queryParameters['map'] as String) as Map<String, dynamic>);
      res.headers.addAll(result.typeAndTotalHeaders);
      res.write(result.asJson());
    } catch (e, s) {
      print('FormularioInscricaoController@findByMap $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void findByKeyValue(RequestContext req, ResponseContext res) async {
    try {
      //String byKey, String byValue
      final result = await FormularioInscricaoRepository().findByKeyValue(
        req.params['byKey'] as String,
        req.params['byValue'] as String,
      );
      res.headers.addAll(result.typeAndTotalHeaders);
      res.write(result.asJson());
    } catch (e, s) {
      print('FormularioInscricaoController@findPontoGastronomicoByAsMap $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void countSlug(RequestContext req, ResponseContext res) async {
    try {
      final idForIgnore =
          req.queryParameters.containsKey('idForIgnore') ? req.queryParameters['idForIgnore'] as String : null;
      final result = await FormularioInscricaoRepository()
          .countSlugsAsMap(req.queryParameters['slug'] as String, idForIgnore: idForIgnore);
      // print('ComercioController@countSlug ${req.queryParameters['slug']}');
      res.headers.addAll(result.typeAndTotalHeaders);
      res.write(result.asJson());
    } catch (e, s) {
      print('FormularioInscricaoController@countSlug $s');
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }
}
