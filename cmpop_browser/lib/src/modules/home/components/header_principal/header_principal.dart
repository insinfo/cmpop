import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:cmpop_browser/src/modules/admin/components/select_input_component/select_input_component.dart';
import 'package:cmpop_browser/src/modules/home/components/header_principal/menu_dropdown_directive.dart';
import 'package:cmpop_browser/src/shared/components/simple_dialog/simple_dialog.dart';

import 'package:cmpop_browser/src/shared/repositories/backend_repository.dart';
import 'dart:html' as html;

import 'package:cmpop_browser/src/shared/services/header_footer_service.dart';

import 'package:cmpop_core/cmpop_core.dart';

@Component(selector: 'header-principal', templateUrl: 'header_principal.html', styleUrls: [
  'header_principal.css'
], directives: [
  coreDirectives,
  formDirectives,
  routerDirectives,
  MenuHeaderDropdownDirective,
  CustomSelectInputComponent,
], exports: [])
class HeaderPrincipalComponent implements OnInit, OnActivate, OnDestroy, AfterViewInit {
  final BackendRepository backendRepository;
  final HeaderFooterService headerFooterService;

  List<Menu> menus = <Menu>[];

  var fakeList = List.generate(5, (int index) => index * index);
  bool isLoading = true;

  @ViewChild('container')
  html.HtmlElement container;

  @ViewChild('li')
  html.LIElement subMenu;

  @Input()
  bool showBackground = true;
  bool noContent = false;

  HeaderPrincipalComponent(this.backendRepository, this.headerFooterService);

  StreamSubscription ssWindowOnScroll;

  @override
  void ngOnInit() async {
    // await getAll();
  }

  @override
  Future<void> onActivate(RouterState previous, RouterState current) async {}

  void menuToggler() {
    //html.AnchorElement ancora
    // if (ancora.classes.contains('.menu-dropdown-trigger'))
    var menu = html.document.querySelector('.menu-horizontal-items');
    var logo = html.document.querySelector('.menu-logo');
    menu.classes.toggle('menu-horizontal-items-show');
    logo.classes.toggle('display-none');
  }

  Future<void> getAll() async {
    try {
      isLoading = true;
      var data = await backendRepository.getMenuHierarquia(filtrarAtivos: true, filtrarPorTipos: ['Header', 'All']);
      menus.clear();
      data.forEach((element) {
        var m = Menu.fromMap(element);
        menus.add(m);
      });
    } catch (e, s) {
      noContent = true;
      SimpleDialogComponent.showAlert('Erro ao buscar os dados', subMessage: '$e $s');
      print('HeaderPrincipalComponent@getAll $s');
    } finally {
      isLoading = false;
    }
  }

  @override
  void ngAfterViewInit() async {}

  @override
  void ngOnDestroy() {
    ssWindowOnScroll?.cancel();
  }
}
