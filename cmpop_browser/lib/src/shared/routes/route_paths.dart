import 'package:angular_router/angular_router.dart';

class RoutePaths {
  static final home = RoutePath(path: 'home');

  static final unauthorized = RoutePath(path: 'unauthorized');
  static final admin = RoutePath(path: 'admin');
  static final pageDynamic = RoutePath(path: 'page/:id');

  static final login = RoutePath(path: 'login');
  static final formularioInscricao = RoutePath(path: 'formulario-inscricao');
}

String getId(Map<String, String> parameters) {
  final id = parameters['id'];
  return id;
}

String getParam(Map<String, String> parameters, String paramName) {
  return parameters[paramName];
}
