import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:cmpop_browser/src/shared/app_config.dart';

import 'package:cmpop_browser/src/shared/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:angular/core.dart';
import 'package:cmpop_core/cmpop_core.dart';

enum LoginStatus { logged, notLogged, none }

@Injectable()
class AuthService {
  final String _accessTokenKey = 'YWNjZXNzX3Rva2Vu';
  final String _expiresInKey = 'ZXhwaXJlc19pbg==';
  final String _userFullNameKeyKey = 'ZnVsbF9uYW1l';
  final String _cpfPessoaKey = 'cpfPessoa';
  final String _inicioSessionKey = 'fgdsfgdfs';
  final String _loginNameKey = 'loginName';
  final String _idPessoaKey = 'idPessoa';

  bool isProduction = true;
  String tokenData = '';

  Usuario usuario;

  LoginStatus loginStatus = LoginStatus.none;
  StreamController<LoginStatus> _onLoginController = StreamController<LoginStatus>.broadcast();
  Stream get onLogin => _onLoginController.stream;

  void flush() {
    _onLoginController.close();
    _onLoginController = StreamController<LoginStatus>.broadcast();
  }

  String sessionTimeOut = '00:00:00';
  DateTime timeInicioSession;
  DateTime timeLastBrowserTabOut;
  Timer _timer;

  String get currentToken => usuario?.accessToken;

  AuthService() {
    _getAuthPayloadFromSessionStorage();
    //isso é para corrigir problema introduzido pelo Google Chrome que para a execução do javascript
    //quando sai da tab
    html.document.addEventListener('visibilitychange', (event) {
      if (loginStatus == LoginStatus.logged) {
        if (html.document.hidden) {
          setLastBrowserTabOut();
        } else {
          isNessesarioFazerLogout();
        }
      }
    });
  }

  void _fillSessionStorage() {
    html.window.sessionStorage[_accessTokenKey] = usuario.accessToken;
    html.window.sessionStorage[_userFullNameKeyKey] = usuario.nome;
    html.window.sessionStorage[_cpfPessoaKey] = usuario.cpf;
    html.window.sessionStorage[_expiresInKey] = usuario.expiresIn.toString();
    html.window.sessionStorage[_loginNameKey] = usuario.username;
    html.window.sessionStorage[_idPessoaKey] = usuario.id.toString();
  }

  void _clearSessionStorage() {
    html.window.sessionStorage.remove(_accessTokenKey);
    html.window.sessionStorage.remove(_userFullNameKeyKey);
    html.window.sessionStorage.remove(_cpfPessoaKey);
    html.window.sessionStorage.remove(_expiresInKey);
    html.window.sessionStorage.remove(_loginNameKey);
    html.window.sessionStorage.remove(_idPessoaKey);
    html.window.sessionStorage.remove(_inicioSessionKey);
  }

  void _getAuthPayloadFromSessionStorage() {
    if (html.window.sessionStorage.containsKey(_accessTokenKey)) {
      usuario = Usuario();
      usuario.accessToken = html.window.sessionStorage[_accessTokenKey];
      usuario.nome = html.window.sessionStorage[_userFullNameKeyKey];
      usuario.cpf = html.window.sessionStorage[_cpfPessoaKey];
      usuario.expiresIn = int.tryParse(html.window.sessionStorage[_expiresInKey]);
      usuario.username = html.window.sessionStorage[_loginNameKey];
      if (html.window.sessionStorage.containsKey(_idPessoaKey)) {
        usuario.id = html.window.sessionStorage[_idPessoaKey];
      }

      //pega a hora que inicio a ceção (hora do login)
      if (html.window.sessionStorage.containsKey(_inicioSessionKey)) {
        timeInicioSession = DateTime.tryParse(html.window.sessionStorage[_inicioSessionKey].toString());
      }
    }
  }

  String getUsernameLogged() {
    return html.window.sessionStorage['loginName'];
  }

  void setLastBrowserTabOut() {
    timeLastBrowserTabOut = DateTime.now();
  }

  void isNessesarioFazerLogout() {
    if (DateTime.now().difference(timeInicioSession).inHours > 9) {
      doLogout();
      var a = html.AreaElement();
      html.document.body.append(a);
      a.click();
      a.remove();
    }
  }

  //faz logout
  void doLogout() {
    usuario = null;
    loginStatus = LoginStatus.notLogged;
    _onLoginController.add(LoginStatus.notLogged);
    _timer?.cancel();
    _timer = null;
    _clearSessionStorage();
    print('doLogout _timer $_timer');
  }

  void initPostAuth() {
    //exibe e inicializa o timeout da Sessão
    if (html.window.sessionStorage[_expiresInKey] != null) {
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        var expiresIn = html.window.sessionStorage[_expiresInKey];

        // print('initPostAuth Timer.periodic expiresIn $expiresIn');
        //32400 segundo = 9 horas
        var timeCount = expiresIn != null ? int.tryParse(expiresIn) : 0;
        var d = Duration(seconds: timeCount);
        sessionTimeOut =
            '${Utils.addZero(d.inHours)}:${Utils.addZero(d.inMinutes.remainder(60))}:${Utils.addZero(d.inSeconds.remainder(60))}';
        //html.document.querySelector('#authServiceSessionTimeOut').text = sessionTimeOut;
        timeCount = timeCount - 2;
        html.window.sessionStorage[_expiresInKey] = timeCount.toString();
        if (timeCount <= 0) {
          timer?.cancel();
          doLogout();
        }
      });
    }
  }

  Future<void> checkPermissionServer() async {
    var client = http.Client();
    var url = '${AppConfig().serverURL}/auth/check';

    try {
      var tokenData = html.window.sessionStorage[_accessTokenKey];
      if (tokenData == null || tokenData.isEmpty) {
        loginStatus = LoginStatus.notLogged;
        _onLoginController.add(LoginStatus.notLogged);
        return;
      }
      var resp = await client.post(url,
          body: jsonEncode(
            {
              'accessToken': tokenData,
              /*'idSistema': 1, //id sistema jubarte
                'rota': '#/jubarteIntranet', //rota cadastrada no menu da jubarte
                'isGetSistemasOfUser': true,
                'checkRoutePermission': false*/
            },
          ),
          headers: AppConfig().defaultHeaders);
      if (resp.statusCode != 200) {
        throw Exception('401 (Unauthorized)');
      }
      //  jsonDecode(resp.body);

      _fillSessionStorage();
      initPostAuth();
      loginStatus = LoginStatus.logged;
      _onLoginController.add(LoginStatus.logged);
    } catch (e, s) {
      print('AuthService@checkToken $e $s');
      loginStatus = LoginStatus.notLogged;
      _onLoginController.add(LoginStatus.notLogged);
      usuario = null;
    }
  }

  //faz o login
  Future<void> doLogin(LoginPayload loginPayload) async {
    var client = http.Client();
    loginStatus = LoginStatus.notLogged;
    _onLoginController.add(LoginStatus.notLogged);
    var response = await client.post(
      '${AppConfig().serverURL}/auth/login',
      headers: AppConfig().defaultHeaders,
      body: jsonEncode(loginPayload.toMap()),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      usuario = Usuario.fromMap(data);
      _fillSessionStorage();

      timeInicioSession = DateTime.now();
      html.window.sessionStorage[_inicioSessionKey] = timeInicioSession.toString();
      initPostAuth();
      loginStatus = LoginStatus.logged;
      _onLoginController.add(LoginStatus.logged);
      //
    } else {
      throw Exception('${jsonDecode(response.body)['message']}');
    }
  }
}
