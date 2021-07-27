import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:cmpop_browser/src/modules/home/components/footer_principal/menu_footer_dropdown_directive.dart';
import 'package:cmpop_browser/src/shared/components/simple_dialog/simple_dialog.dart';

import 'package:cmpop_browser/src/shared/repositories/backend_repository.dart';
import 'dart:html' as html;

import 'package:cmpop_browser/src/shared/services/header_footer_service.dart';

import 'package:cmpop_core/cmpop_core.dart';

@Component(
  selector: 'footer-principal',
  templateUrl: 'footer_principal.html',
  styleUrls: ['footer_principal.css'],
  directives: [
    coreDirectives,
    formDirectives,
    routerDirectives,
    MenuFooterDropdownDirective,
  ],
)
class FooterPrincipalComponent implements OnActivate, AfterViewInit, OnInit, OnDestroy {
  final BackendRepository backendRepository;
  final HeaderFooterService headerFooterService;

  List<Menu> menus = <Menu>[];

  var fakeList = List.generate(4, (int index) => index * index);
  bool isLoading = true;

  @ViewChild('container')
  html.HtmlElement container;

  @ViewChild('menuUl')
  html.UListElement menuUl;

  @Input()
  bool showBackground = true;
  bool noContent = false;

  FooterPrincipalComponent(this.backendRepository, this.headerFooterService);

  StreamSubscription ssWindowOnScroll;

  @override
  void ngOnInit() async {
    /*ssWindowOnScroll = html.window.onScroll.listen((event) {
      if (!showBackground) {
        if (headerFooterService.visibility) {
          if (html.document.body.scrollTop > 20 || html.document.documentElement.scrollTop > 20) {
            html.document.querySelector('.menu-horizontal').classes.add('color-dark');
          } else {
            html.document.querySelector('.menu-horizontal').classes.remove('color-dark');
          }
        }
      }
    });*/
  }

  @override
  Future<void> onActivate(RouterState previous, RouterState current) async {}

  void menuToggler(menu, logo) {
    menu.classes.toggle('menu-horizontal-items-show');
    logo.classes.toggle('display-none');
  }

  Future<void> getAll() async {
    try {
      isLoading = true;
      var data = await backendRepository.getMenuHierarquia(filtrarAtivos: true, filtrarPorTipos: ['Footer', 'All']);
      menus.clear();
      data.forEach((element) {
        var m = Menu.fromMap(element);

        menus.add(m);
      });
    } catch (e, s) {
      noContent = true;
      SimpleDialogComponent.showAlert('Erro ao buscar os dados', subMessage: '$e');
      print('FooterPrincipalComponent@getAll $s');
    } finally {
      isLoading = false;
    }
  }

  @override
  void ngAfterViewInit() async {
    //.menu-dropdown-container
    await Future.delayed(Duration(milliseconds: 200));

    /*menuUl?.querySelectorAll('.menu-dropdown a')?.forEach((a) {
      a.onClick.listen((event) {
        html.window.console.log(a.closest('.menu-dropdown'));
        a.closest('.menu-dropdown-container').classes.remove('menu-dropdown-container-show');
      });
    });*/
  }

  void openSubMenu(html.HtmlElement li) {
    // li.querySelector('ul.menu-dropdown-container').classes.toggle('menu-dropdown-container-show');
  }

  @override
  void ngOnDestroy() {
    ssWindowOnScroll?.cancel();
  }
}
