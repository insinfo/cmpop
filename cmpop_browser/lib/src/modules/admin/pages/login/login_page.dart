import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:cmpop_browser/src/shared/services/auth_service.dart';
import 'dart:html' as html;

import 'package:cmpop_browser/src/shared/services/header_footer_service.dart';
import 'package:cmpop_core/cmpop_core.dart';

@Component(
  selector: 'login-page',
  styleUrls: ['login_page.css'],
  templateUrl: 'login_page.html',
  directives: [
    routerDirectives,
    formDirectives,
    coreDirectives,
  ],
)
class LoginPage implements OnInit, AfterContentInit, OnActivate {
  final AuthService authService;
  final HeaderFooterService headerFooterService;
  LoginPayload loginPayload = LoginPayload();

  LoginPage(this.authService, this.headerFooterService);

  @override
  Future<Null> ngOnInit() async {}

  @override
  void onActivate(RouterState previous, RouterState current) {
    headerFooterService.visibility = false;
  }

  @override
  void ngAfterContentInit() async {
    await Future.delayed(Duration(seconds: 2));
  }

  void doLogin() async {
    try {
      await authService.doLogin(loginPayload);
    } catch (e, s) {
      print('LoginPage@doLogin $e $s');
      html.window.alert('Falha ao fazer o login');
    }
  }
}
