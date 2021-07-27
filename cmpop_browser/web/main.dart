import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:pedantic/pedantic.dart';
import 'package:cmpop_browser/src/modules/admin/pages/login/login_page.dart';
import 'package:cmpop_browser/src/modules/admin/routes/admin_routes.dart';
import 'package:cmpop_browser/src/modules/app/app_component.template.dart' as ng;
import 'package:cmpop_browser/src/shared/app_config.dart';
import 'package:cmpop_browser/src/shared/repositories/backend_repository.dart';
import 'package:cmpop_browser/src/shared/repositories/midia_repository.dart';
import 'package:cmpop_browser/src/shared/routes/route_paths.dart';
import 'package:cmpop_browser/src/shared/services/auth_service.dart';
import 'package:cmpop_browser/src/shared/services/header_footer_service.dart';
import 'package:cmpop_core/cmpop_core.dart';
import 'main.template.dart' as self;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:html' as html;

class RouterGuard extends RouterHook {
  final AuthService _authService;
  final Injector _injector;
  StreamSubscription streamSubscriptionOnLogin;

  RouterGuard(this._authService, this._injector) {
    streamSubscriptionOnLogin = _authService.onLogin.listen((status) {
      //print('onLogin');
      goto(status);
    });
  }

  bool isPrivateRoute() {
    var currentRoute = html.window.location.hash;
    if (currentRoute.startsWith('#/${RoutePaths.admin.path}')) {
      return true;
    }
    AdminRoutes.all.forEach((r) {
      var rota = '#/${RoutePaths.admin.path}/${r.path}';
      if (currentRoute == rota) {
        return true;
      }
    });
    return false;
  }

  void goto(LoginStatus status) {
    if (isPrivateRoute()) {
      if (status == LoginStatus.notLogged) {
        router.navigate(RoutePaths.login.toUrl());
      }
    } else if (html.window.location.hash == '#/${RoutePaths.login.path}') {
      if (status == LoginStatus.logged) {
        router.navigate(RoutePaths.admin.toUrl());
      }
    }
  }

  // Lazily inject `Router` to avoid cyclic dependency.
  Router _router;
  Router get router => _router ??= _injector.provideType(Router);

  @override
  Future<bool> canActivate(Object component, RouterState oldState, RouterState newState) async {
    //var isLoggedIn = await _authService.isLoggedIn();
    //print('canActivate oldState routePath: ${oldState?.routePath?.toUrl()}');
    //print('canActivate newState routePath: ${newState?.routePath?.toUrl()}');

    if (isPrivateRoute()) {
      // print('esta atualmente em rota privada');
      //
      if (_authService.loginStatus == LoginStatus.notLogged && component is! LoginPage) {
        //print('RouterGuard@canActivate redirect component $component');
        unawaited(router.navigate(RoutePaths.login.toUrl()));
        return true;
      }
    }
    //print('no redirect');
    return true;
  }
}

/*PontoGastronomicoApi pontoGastronomicoApiFactory(AppConfig config) =>
    PontoGastronomicoApi(config.serverURL, config.defaultHeaders);*/
//FactoryProvider(PontoGastronomicoApi, pontoGastronomicoApiFactory),
@GenerateInjector([
  routerProvidersHash, // You can use routerProviders in production
  ClassProvider(BackendRepository),
  ClassProvider(RestConfigBase, useClass: AppConfig),
  ClassProvider(CategoriaApi),
  ClassProvider(FormularioInscricaoApi),
  ClassProvider(AuthService),
  ClassProvider(HeaderFooterService),
  ClassProvider(MidiaRepository),
  //ClassProvider(ImageProcessService),
  ClassProvider(RouterHook, useClass: RouterGuard),
])
final InjectorFactory injector = self.injector$Injector;

void main() {
  initDateFormat();
  runApp(ng.AppComponentNgFactory, createInjector: injector);
}

void initDateFormat() {
  initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';
}
