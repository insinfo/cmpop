import 'package:angular_router/angular_router.dart';

import 'package:cmpop_browser/src/shared/routes/route_paths.dart';

class AdminRoutesPaths {
  static final galeria = RoutePath(path: 'galeria', parent: RoutePaths.admin);
  static final cadastroMenu = RoutePath(path: 'menus', parent: RoutePaths.admin);
  static final cadastroPagina = RoutePath(path: 'paginas', parent: RoutePaths.admin);
  static final cadastroUsuario = RoutePath(path: 'usuarios', parent: RoutePaths.admin);
  //formularios
  static final gerenciaInscricao = RoutePath(path: 'gerencia-inscricao', parent: RoutePaths.admin);
}
