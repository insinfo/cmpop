import 'dart:html' as html;

import 'package:cmpop_core/cmpop_core.dart';

class AppConfig extends RestConfigBase {
  ///desenv.pmro@gmail.com
  static final mapboxAccessToken =
      'pk.eyJ1IjoicG1ybyIsImEiOiJjanBiZmFsaXIwZTJhM2tudW41dDQwbmF3In0.4F5dsSSKPpQ0RamUb47CKw';

  String subdomain = 'cmpop.';
  String domain = 'riodasostras.rj.gov.br:'; //riodasostras.rj.gov.br
  String url_base = '';
  String protocol = html.window.location.protocol; //'https:';
  String basePath = '/cmpop_server/api/v1';
  String port = (html.window.location.protocol.startsWith('https:') ? 443 : 80).toString();
  String get _currentToken => html.window.sessionStorage.containsKey('YWNjZXNzX3Rva2Vu')
      ? html.window.sessionStorage['YWNjZXNzX3Rva2Vu'].toString()
      : 'YWNjZXNzX3Rva2Vu';

  // Collections
  static String MENUS = 'menus';
  static String PAGINAS = 'paginas';
  static String USUARIO = 'user';
  static String CATEGORIAS = 'categorias';
  static String MIDIAS = 'midias';

  AppConfig() {
    if (html.window.location.host.contains('localhost') ||
        html.window.location.host.contains('local.riodasostras.rj.gov.br') ||
        html.window.location.host.contains('127.0.')) {
      protocol = 'http:';
      subdomain = '';
      port = '4003';
      domain = 'localhost:';
      basePath = '/api/v1';
    }
    if (html.window.location.host.contains('10.0.0.72')) {
      protocol = 'http:';
      subdomain = '';
      port = '86';
      domain = '10.0.0.72:';
      basePath = '/cmpop_server/api/v1';
    }
  }

  @override
  Map<String, String> get defaultHeaders => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_currentToken',
      };

  @override
  String get serverURL => protocol + '//' + subdomain + domain + port + basePath;
}
