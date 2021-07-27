import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:cmpop_browser/src/shared/routes/route_paths.dart';
import 'package:cmpop_browser/src/shared/services/header_footer_service.dart';

@Component(
    selector: 'unauthorized-page',
    styleUrls: ['unauthorized_page.css'],
    templateUrl: 'unauthorized_page.html',
    directives: [
      routerDirectives,
      formDirectives,
      coreDirectives,
    ],
    exports: [])
class UnauthorizedPageComponent implements OnInit, OnActivate, OnDeactivate, OnDestroy {
  final HeaderFooterService headerFooterService;
  final Router router;
  UnauthorizedPageComponent(this.headerFooterService, this.router);

  void irParaLogin() {
    router.navigate(RoutePaths.admin.toUrl());
  }

  @override
  void ngOnDestroy() {}

  @override
  void ngOnInit() {}

  @override
  void onActivate(RouterState previous, RouterState current) {
    headerFooterService.visibility = false;
  }

  @override
  void onDeactivate(RouterState current, RouterState next) {
    headerFooterService.visibility = true;
  }
}
