import 'dart:convert';
import 'package:cmpop_server/exceptions/user_not_found_exception.dart';
import 'package:cmpop_server/repositories/usuario_repository.dart';
import 'package:galileo_framework/galileo_framework.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AuthenticationController {
  static const key = '7Fsxc2A865V67';

  static void authenticate(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final Map<String, dynamic> payload = req.bodyAsMap;
      if (!payload.containsKey('username')) {
        throw GalileoHttpException.badRequest(message: 'Faltando login.');
      }
      if (!payload.containsKey('password')) {
        throw GalileoHttpException.badRequest(message: 'Faltando senha.');
      }
      final username = payload['username'].toString();
      final password = payload['password'].toString();

      final repository = UsuarioRepository();
      final usuario = await repository.getByUsernameAndPass(username, password);

      //$expirationSec = 32400; //32400 segundo = 9 horas
      const int expirationSec = 32400; //7200 = 2 hora, 3600 = 1 hora //32400 segundo = 9 horas
      final expiry = DateTime.now().add(const Duration(seconds: expirationSec));

      final claimSet = JwtClaim(
        //subject: 'kleak',
        issuer: 'jubarte.riodasostras.rj.gov.br',
        issuedAt: DateTime.now(), //Emitido em timestamp de geracao do token
        notBefore: DateTime.now().subtract(const Duration(milliseconds: 1)), // token nao é valido Antes de
        // audience: <String>['jubarte.riodasostras.rj.gov.br'],
        otherClaims: <String, dynamic>{
          'idSistema': 1,
          'idPessoa': usuario.id,
          //'idOrganograma': usuarioJubarte.idOrganograma,
          'cpfPessoa': usuario.cpf,
          'userAgent': ''
        },
        expiry: expiry,
        maxAge: const Duration(hours: expirationSec),
      );

      final String token = issueJwtHS256(claimSet, key);
      usuario.username = username;
      usuario.accessToken = token;
      usuario.expiresIn = expirationSec;
      final userMap = usuario.toMap();
      userMap.remove('password');
      final json = jsonEncode(userMap);
      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.write(json);
    } on UserNotFoundException {
      res.statusCode = 401;
      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.write({'message': 'Usuário não encontrado'});
    } catch (e, s) {
      throw GalileoHttpException.notAuthenticated(message: '$e $s');
    }
  }

  static void checkToken(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final Map<String, dynamic> payload = req.bodyAsMap;
      if (!payload.containsKey('accessToken')) {
        throw GalileoHttpException.badRequest(message: 'Faltando token.');
      }

      final token = payload['accessToken'].toString();

      final JwtClaim decClaimSet = verifyJwtHS256Signature(token, key);
      // print(decClaimSet);

      decClaimSet.validate(issuer: 'jubarte.riodasostras.rj.gov.br');

      if (decClaimSet.jwtId != null) {
        print(decClaimSet.jwtId);
      }
      if (decClaimSet.containsKey('idPessoa')) {
        final v = decClaimSet['idPessoa'];
        print(v);
      }

      final json = jsonEncode({'login': true});
      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.write(json);
    } on JwtException catch (e) {
      throw GalileoHttpException.notAuthenticated(message: 'JwtException $e');
    } catch (e) {
      throw GalileoHttpException.notAuthenticated(message: '$e');
    }
  }

  //valida QrCode da carteira da guarda e cracha do servidor
  static void validateQrCode(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final Map<String, dynamic> payload = req.bodyAsMap;

      if (!payload.containsKey('qrcode')) {
        throw GalileoHttpException.badRequest(message: 'Faltando qrcode.');
      }
      final token = payload['qrcode'].toString();
      final JwtClaim decClaimSet = verifyJwtHS256Signature(token, key);
      // print(decClaimSet);
      decClaimSet.validate(issuer: 't', audience: 'j');
      if (decClaimSet.containsKey('cpfPessoa')) {
        //final cpf = decClaimSet['cpfPessoa'].toString();

        /*final servidorRepository = ServidorRepository();
        final usuarioJubarte = await servidorRepository.getByCpf(cpf);
        if (usuarioJubarte == null) {
          throw GalileoHttpException.badRequest(message: 'QrCode Inválido');
        }
        final json = CoreUtils.myJsonEncode(usuarioJubarte.toMap());
        res.headers['Content-Type'] = 'application/json;charset=utf-8';
        res.write(json);*/
      } else {
        throw GalileoHttpException.badRequest(message: 'QrCode Inválido');
      }
    } on JwtException {
      throw GalileoHttpException.badRequest(message: 'QrCode Inválido');
    } catch (e) {
      throw GalileoHttpException.badRequest(message: '$e');
    }
  }

  static void createUsuario(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final Map<String, dynamic> data = req.bodyAsMap;
      //final Map<String, dynamic> params = req.params;
      //final Map<String, dynamic> queryParameters = req.queryParameters;
      final repository = UsuarioRepository();

      await repository.createFromMap(data);
      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.json({'message': 'StatusMessage.SUCCESS'});
    } catch (e, s) {
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void updateUsuarioByUsername(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final Map<String, dynamic> payload = req.bodyAsMap;
      if (!payload.containsKey('username')) {
        throw GalileoHttpException.badRequest(message: 'Faltando login.');
      }

      final username = payload['username'].toString();

      final repository = UsuarioRepository();
      final user = await repository.getByUsername(username);
      await repository.updateFromMap(user.id, payload);

      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.json({'message': 'StatusMessage.SUCCESS'});
    } catch (e, s) {
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }

  static void updateUsuarioById(RequestContext req, ResponseContext res) async {
    try {
      await req.parseBody();
      final Map<String, dynamic> payload = req.bodyAsMap;
      if (!payload.containsKey('id')) {
        throw GalileoHttpException.badRequest(message: 'Faltando id.');
      }

      final id = payload['id'].toString();
      final repository = UsuarioRepository();
      final user = await repository.getById(id);
      await repository.updateFromMap(user.id, payload);

      res.headers['Content-Type'] = 'application/json;charset=utf-8';
      res.json({'message': 'StatusMessage.SUCCESS'});
    } catch (e, s) {
      throw GalileoHttpException.badRequest(message: '$e $s');
    }
  }
}
