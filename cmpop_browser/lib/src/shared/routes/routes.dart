import 'package:angular_router/angular_router.dart';
import 'package:cmpop_browser/src/shared/routes/route_paths.dart';
import 'package:cmpop_browser/src/modules/home/pages/home_page.template.dart' as home_template;

import 'package:cmpop_browser/src/modules/admin/pages/admin/admin_page.template.dart' as admin_template;

import 'package:cmpop_browser/src/modules/admin/pages/unauthorized/unauthorized_page.template.dart'
    as unauthorized_page_template;

import 'package:cmpop_browser/src/modules/admin/pages/login/login_page.template.dart' as login_template;

import 'package:cmpop_browser/src/modules/formulario_inscricao/formulario_inscricao.template.dart'
    as formulario_inscricao_template;

class Routes {
  static final unauthorized = RouteDefinition(
      routePath: RoutePaths.unauthorized, component: unauthorized_page_template.UnauthorizedPageComponentNgFactory);

  static final home = RouteDefinition(
    routePath: RoutePaths.home,
    component: home_template.HomePageNgFactory,
    //useAsDefault: true,
  );

  static final admin = RouteDefinition(
    routePath: RoutePaths.admin,
    component: admin_template.AdminPageNgFactory,
  );

  static final login = RouteDefinition(
    routePath: RoutePaths.login,
    component: login_template.LoginPageNgFactory,
  );

  static final formularioInscricao = RouteDefinition(
    routePath: RoutePaths.formularioInscricao,
    component: formulario_inscricao_template.FormularioIncricaoPageNgFactory,
    useAsDefault: true,
  );

  static final all = <RouteDefinition>[
    home,
    admin, formularioInscricao,
    unauthorized, login,
    // login,cultura,
    /*RouteDefinition.redirect(
      path: 'home',
      redirectTo: RoutePaths.home.toUrl(),
    ),*/
  ];
}
