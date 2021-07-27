import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:quiver/collection.dart';

import 'package:cmpop_browser/src/modules/admin/routes/admin_routes.dart';
import 'package:cmpop_browser/src/modules/admin/routes/admin_routes_paths.dart';

import 'package:cmpop_browser/src/shared/repositories/backend_repository.dart';
import 'package:cmpop_browser/src/shared/routes/route_paths.dart';
import 'package:cmpop_browser/src/shared/services/auth_service.dart';
import 'package:cmpop_browser/src/shared/services/header_footer_service.dart';
import 'package:cmpop_core/cmpop_core.dart';

@Component(
    selector: 'admin-page',
    styleUrls: [
      'package:angular_components/app_layout/layout.scss.css',
      'admin_page.css',
    ],
    templateUrl: 'admin_page.html',
    directives: [
      routerDirectives,
      formDirectives,
      coreDirectives,
      MaterialDialogComponent,
      FixedMaterialTabStripComponent,
      MaterialExpansionPanel,
      //material
      AutoFocusDirective,
      DeferredContentDirective,
      FocusItemDirective,
      FocusListDirective,
      HighlightedValueComponent,
      MaterialButtonComponent,
      MaterialCheckboxComponent,
      MaterialIconComponent,
      MaterialListComponent,
      MaterialListItemComponent,
      MaterialPersistentDrawerDirective,
      MaterialSelectSearchboxComponent,
    ],
    exports: [LoginStatus, AdminRoutesPaths, AdminRoutes])
class AdminPage extends Object with CanReuse implements OnInit, AfterContentInit, OnActivate, OnDeactivate, OnDestroy {
  final BackendRepository backendRepository;
  final AuthService authService;
  final HeaderFooterService headerFooterService;
  final Router router;
  String tituloPagina = 'Backoffice';
  String breadcrumb = '=> Gerencia Portal'; //Migalhas de pão

  //String get breadcrumb => _breadcrumb;
  bool get hasBreadcrumb => breadcrumb?.isNotEmpty ?? false;

  StringSelectionOptions<AdmMenuItem> menuOptions;

  List<AdmMenuItem> menuItems = <AdmMenuItem>[
    AdmMenuItem(AdminRoutesPaths.galeria.toUrl(), 'Galeria de Mídia'),

    // AdmMenuItem(AdminRoutesPaths.cadastroMenu.toUrl(), 'Menus'),
    // AdmMenuItem(AdminRoutesPaths.cadastroPagina.toUrl(), 'Paginas'),
    AdmMenuItem(AdminRoutesPaths.cadastroUsuario.toUrl(), 'Usuários'),

    AdmMenuItem(AdminRoutesPaths.gerenciaInscricao.toUrl(), 'Gerencia inscrição', group: 'Formulários'),

    AdmMenuItem(RoutePaths.home.toUrl(), 'Home'),
  ];

  AdminPage(this.backendRepository, this.authService, this.headerFooterService, this.router) {
    final groups = Multimap<String, AdmMenuItem>.fromIterable(menuItems, key: (e) => e.group);
    menuOptions = StringSelectionOptions<AdmMenuItem>.withOptionGroups(
        (groups.keys.toList()..sort()).map((g) => OptionGroup.withLabel(groups[g].toList(), g)).toList(),
        toFilterableString: _toFilterableString);

    router.onRouteActivated.listen((newRoute) {
      var example = newRoute.path;
      //if (example.startsWith('/')) example = example.substring(1);
      //_breadcrumb = breadcrumbs[example];
      //querySelector('material-content').scrollTop = 0;
      var m = menuItems.where((m) {
        return m.link == '$example';
      });
      if (m?.isNotEmpty == true) {
        querySelector('#breadcrumb')?.innerHtml = ' => ${m.first.displayName}';
      }
    });
  }

  String _toFilterableString(AdmMenuItem example) => <String>[
        example.displayName,
        example.group,
      ].join('\n');

  /*void changeRouteHandle(AdmMenuItem mi) {
    _breadcrumb = mi.displayName;
  }*/

  @override
  void ngAfterContentInit() {}

  @override
  void onDeactivate(RouterState current, RouterState next) {
    headerFooterService.visibility = true;
  }

  @override
  void ngOnDestroy() {}

  @override
  void ngOnInit() async {
    //container
    //print('AdminPage@ngOnInit checkPermissionServer');
    print('AdminPage@ngOnInit');
  }

  @override
  void onActivate(RouterState previous, RouterState current) async {
    headerFooterService.visibility = false;
    await authService.checkPermissionServer();
  }

  @override
  Future<bool> canReuse(RouterState current, RouterState next) async {
    // Always re-use this instance.
    return true;
  }
}
