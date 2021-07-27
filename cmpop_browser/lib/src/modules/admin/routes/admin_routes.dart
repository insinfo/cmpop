import 'package:angular_router/angular_router.dart';
import 'package:cmpop_browser/src/modules/admin/routes/admin_routes_paths.dart';

//paginas

import 'package:cmpop_browser/src/modules/admin/components/cadastro_usuario/cadastro_usuario.template.dart'
    as cadastro_usuario_template;

import 'package:cmpop_browser/src/modules/admin/components/galeria/galeria.template.dart' as galeria_template;

import 'package:cmpop_browser/src/modules/admin/components/gerencia_inscricao/gerencia_inscricao.template.dart'
    as gerencia_inscricao_template;

class AdminRoutes {
  //Gerencia Usuario
  static final cadastroUsuario = RouteDefinition(
    routePath: AdminRoutesPaths.cadastroUsuario,
    component: cadastro_usuario_template.CadastroUsuarioComponentNgFactory,
  );
  //Gerencia Midias galeria
  static final galeria = RouteDefinition(
    routePath: AdminRoutesPaths.galeria,
    component: galeria_template.GaleriaComponentNgFactory,
  );

  static final gerenciaInscricao = RouteDefinition(
    routePath: AdminRoutesPaths.gerenciaInscricao,
    component: gerencia_inscricao_template.GerenciaInscricaoComponentNgFactory,
  );

  static final all = <RouteDefinition>[
    cadastroUsuario,
    galeria,
    gerenciaInscricao,

    /*RouteDefinition.redirect(
      path: '',
      redirectTo: AdminRoutesPaths.gerenciaPortal.toUrl(),
    ),*/
  ];
}
