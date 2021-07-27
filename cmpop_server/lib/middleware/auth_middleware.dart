import 'dart:async';
import 'package:galileo_framework/galileo_framework.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:cmpop_server/controllers/authentication_controller.dart';
//import 'package:riodasostrasapp_core/riodasostrasapp_core.dart';

class AuthMiddleware {
  Future<bool> handleRequest(RequestContext req, ResponseContext res) async {
    try {
      //res.json({'message': StatusMessage.ACESSO_NAO_AUTORIZADO});
      //Authorization: Bearer
      if (req.headers['Authorization'] == null || req.headers['Authorization'].toString() == '') {
        throw GalileoHttpException.notAuthenticated(message: 'ACESSO_NAO_AUTORIZADO');
      }
      final token = req.headers['Authorization'][0].toString().replaceAll('Bearer ', '');
      final JwtClaim decClaimSet = verifyJwtHS256Signature(token, AuthenticationController.key);
      decClaimSet.validate(issuer: 'jubarte.riodasostras.rj.gov.br');

      return true;
    } catch (e) {
      throw GalileoHttpException.notAuthenticated(message: '$e');
    }
  }
}
