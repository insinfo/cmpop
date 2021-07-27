import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:js' as js;

class Utils {
  static final String SAFE_URL_PATTERN = r'^(?:(?:https?|mailto|ftp|tel|file|sms):|[^&:/?#]*(?:[/?#]|$))'; // /gi;

  /// A pattern that matches safe data URLs. It only matches image, video, and audio types. */
  static final String DATA_URL_PATTERN =
      r'^data:(?:image\/(?:bmp|gif|jpeg|jpg|png|tiff|webp)|video\/(?:mpeg|mp4|ogg|webm)|audio\/(?:mp3|oga|ogg|opus));base64,[a-z0-9+\/]+=*$'; // /i

  static String sanitizeUrl(String url) {
    if (url == 'null' || url.isEmpty || url == 'about:blank') return 'about:blank';
    if (RegExp(SAFE_URL_PATTERN).firstMatch(url) == null || RegExp(DATA_URL_PATTERN).firstMatch(url) == null) {
      return url;
    }

    return 'unsafe:$url';
  }

  static bool isInViewport(html.HtmlElement element) {
    var rect = element.getBoundingClientRect();
    return (rect.top >= 0 &&
        rect.left >= 0 &&
        rect.bottom <= html.window.innerHeight &&
        rect.right <= html.window.innerWidth);
  }

  //verifica se um elemento é visivel pelo usuario do navegador
  //If you're interested in visible by the user:
  static bool isVisible(html.HtmlElement elem) {
    //if (!(elem is html.HtmlElement)) throw Exception('DomUtil: elem is not an element.');
    var style = elem.getComputedStyle();
    if (style.display == 'none') return false;
    if (style.visibility != 'visible') return false;
    if (double.tryParse(style.opacity) < 0.1) return false;
    if (elem.offsetWidth +
            elem.offsetHeight +
            elem.getBoundingClientRect().height +
            elem.getBoundingClientRect().width ==
        0) {
      return false;
    }
    var elemCenter = <String, int>{
      'x': elem.getBoundingClientRect().left + elem.offsetWidth / 2,
      'y': elem.getBoundingClientRect().top + elem.offsetHeight / 2
    };
    if (elemCenter['x'] < 0) return false;
    if (elemCenter['x'] > (html.window.innerWidth)) return false;
    if (elemCenter['y'] < 0) return false;
    if (elemCenter['y'] > (html.window.innerHeight)) return false;
    var pointContainer = html.document.elementFromPoint(elemCenter['x'], elemCenter['y']);
    do {
      if (pointContainer == elem) return true;
    } while ((pointContainer = pointContainer.parentNode) != null);
    return false;
  }

  /// Including this file adds the `addDynamicListener` to the ELement prototype.
  ///
  /// The dynamic listener gets an extra `selector` parameter that only calls the callback
  /// if the target element matches the selector.
  ///
  /// The listener has to be added to the container/root element and the selector should match
  /// the elements that should trigger the event.
  ///
  /// Browser support: IE9+
  // Polyfil Element.matches
  // https://developer.mozilla.org/en/docs/Web/API/Element/matches#Polyfill
  static bool matchesSelector(String selector, html.HtmlElement element) {
    var matches = html.document.querySelectorAll(selector);
    var i = matches.length;
    while (--i >= 0 && matches[i] != element) {}
    return i > -1;
  }

  /// Returns a modified callback function that calls the
  /// initial callback function only if the target element matches the given selector
  ///
  /// @param {string} selector
  /// @param {function} callback
  static void getConditionalCallback(
      String selector, Function(html.Event, html.HtmlElement delegatedTarget) callback, html.Event event) {
    html.HtmlElement delegatedTarget;
    if (event.target != null && matchesSelector(selector, event.target)) {
      delegatedTarget = event.target;
      callback?.call(event, delegatedTarget);
      return;
    }
    // Not clicked directly, check bubble path  || (event.composedPath && event.composedPath())
    var path = event.path;
    if (path == null) return;
    for (var i = 0; i < path.length; ++i) {
      var el = path[i];
      if (matchesSelector(selector, el)) {
        // Call callback for all elements on the path that match the selector
        delegatedTarget = el;
        callback?.call(event, delegatedTarget);
      }
      // We reached parent node, stop
      if (el == event.currentTarget) {
        return;
      }
    }
  }

  ///
  ///
  /// @param {Element} rootElement The root element to add the linster too.
  /// @param {string} eventType The event type to listen for.
  /// @param {string} selector The selector that should match the dynamic elements.
  /// @param {function} callback The function to call when an event occurs on the given selector.
  /// @param {boolean|object} options Passed as the regular `options` parameter to the addEventListener function
  ///                                 Set to `true` to use capture.
  ///                                 Usually used as an object to add the listener as `passive`
  static void addDynamicEventListener(html.HtmlElement rootElement, String eventType, String selector,
      Function(html.Event, html.HtmlElement delegatedTarget) callback,
      [bool useCapture]) {
    //html.document.body
    rootElement.addEventListener(eventType, (html.Event event) {
      getConditionalCallback(selector, callback, event);
    }, useCapture);
  }

  static void irParaAncora(String selector) {
    var el = html.document.querySelector(selector);
    var position = el.getBoundingClientRect().topLeft;
    var divContainerToScrollTo = html.window;
    var positionFinal = (position.y).floor(); //- 80
    //var count = divContainerDetail.scrollTop;
    Function(num) loop;
    var x = positionFinal as double; //final position
    var t = 0.0; //0-1, this is what you change in animation loop
    var tx = 0.0; //actual position of element for x
    loop = (h) {
      tx = (t * (2 - t)) * x;
      divContainerToScrollTo.scrollTo(0, tx);
      if (t < 1) {
        t += 0.06; //determines speed
        html.window.requestAnimationFrame(loop);
      }
    };
    loop(0);
  }

  static Future<dynamic> fileToDataUrl(html.File file) async {
    final completer = Completer();
    final reader = html.FileReader();
    reader.onLoad.listen((progressEvent) {
      final loadedFile = progressEvent.currentTarget as html.FileReader;
      completer.complete(loadedFile.result);
    });
    reader.readAsDataUrl(file);
    return completer.future;
  }

  static Future<dynamic> fileToArrayBuffer(html.File file) async {
    final completer = Completer();
    final reader = html.FileReader();
    reader.onLoad.listen((progressEvent) {
      final loadedFile = progressEvent.currentTarget as html.FileReader;
      completer.complete(loadedFile.result);
    });
    reader.readAsArrayBuffer(file);
    return completer.future;
  }

  static Future<dynamic> blobToArrayBuffer(html.Blob blob) async {
    final completer = Completer();
    final reader = html.FileReader();
    reader.onLoad.listen((progressEvent) {
      final loadedFile = progressEvent.currentTarget as html.FileReader;
      completer.complete(loadedFile.result);
    });
    reader.readAsArrayBuffer(blob);
    return completer.future;
  }

  static Future<dynamic> uploadFiles(
    String url,
    List<html.File> files, {
    Map<String, String> headers,
    dynamic dataToSender,
    String bodyEncoding = 'utf8',
    Map<String, String> queryParams,
    bool resizeImage = false,
    bool compressImage = false,
    int maxImageWidth = 1024,
    int maxImageHeight = 768,
  }) async {
    var headersDefault = {'Authorization': 'Bearer ' + html.window.sessionStorage['YWNjZXNzX3Rva2Vu'].toString()};

    var requestUrl = Uri.parse(url);
    if (queryParams != null) {
      var queryString = Uri(queryParameters: queryParams).query;
      requestUrl = Uri.parse(url + '?' + queryString);
    }

    var request = http.MultipartRequest('POST', requestUrl);

    if (headers != null) {
      request.headers.addAll(headers);
    } else {
      request.headers.addAll(headersDefault);
    }

    if (dataToSender != null) {
      if (dataToSender is Map<String, dynamic>) {
        if (bodyEncoding == null) {
          request.fields['data'] = jsonEncode(dataToSender);
        } else if (bodyEncoding == 'utf8') {
          request.fields['data'] = jsonEncode(dataToSender);
          //ISO-8859-1
        } else if (bodyEncoding == 'latin1') {
          var latin1Bytes = latin1.encode(jsonEncode(dataToSender));
          request.fields['data'] = latin1Bytes.toString();
        }
      } else {
        request.fields['data'] = dataToSender;
      }
    }

    if (files?.isNotEmpty == true) {
      for (var file in files) {
        if (file != null) {
          var fileBytes = await fileToArrayBuffer(file);

          request.files.add(http.MultipartFile.fromBytes('file[]', fileBytes,
              contentType: MediaType('application', 'octet-stream'), filename: file.name));
        }
      }
    }

    //fields.forEach((k, v) => request.fields[k] = v);
    var streamedResponse = await request.send();
    var resp = await http.Response.fromStream(streamedResponse);
    //var respJson = jsonDecode(resp.body);

    return resp;
  }

  static bool isMobile() {
    var check = false;
    var reg =
        r'Mobile|iP(hone|od|ad)|Android|BlackBerry|IEMobile|Kindle|NetFront|Silk-Accelerated|(hpw|web)OS|Fennec|Minimo|Opera M(obi|ini)|Blazer|Dolfin|Dolphin|Skyfire|Zune';
    if (RegExp(reg, caseSensitive: true).hasMatch(html.window.navigator.userAgent)) {
      check = true;
    }
    return check;
  }

  static String toBrasilDate(DateTime date) {
    if (date == null) {
      return '';
    }
    var formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  static String secondsToHoursMinSec(int secs) {
    if (secs == null) {
      return '';
    }
    var minutes = (secs / 60).floor as int;
    secs = secs % 60;
    var hours = (minutes / 60).floor as int;
    minutes = minutes % 60;
    return addZero(hours) + ':' + addZero(minutes) + ':' + addZero(secs);
  }

  static String addZero(int value) {
    return value < 10 ? '0$value' : '$value';
  }

  static String incrementaVersaoPorTipo(String versao, String tipo) {
    var values = versao.split('.');
    var numeros = <int>[];
    values.forEach((v) {
      numeros.add(int.tryParse(v));
    });
    switch (tipo) {
      case 'NEW':
        numeros[0]++;
        numeros[1] = 0;
        numeros[2] = 0;
        break;
      case 'FEATURE':
        numeros[1]++;
        numeros[2] = 0;
        break;
      case 'BUG':
        numeros[2]++;
        break;
    }
    versao = '${numeros[0]}.${numeros[1]}.${numeros[2]}';
    return versao;
  }

  static String retornarIniciais(pNome, splitBy) {
    if (pNome) {
      var iniciais;
      splitBy = splitBy ? splitBy : ' ';
      var nomes = pNome.split(splitBy);
      if (nomes.length > 1) {
        iniciais = nomes[0].charAt(0).toUpperCase() + nomes[nomes.length - 1].charAt(0).toUpperCase();
      } else {
        iniciais = nomes[0].substr(0, 2).toUpperCase();
      }
      return iniciais;
    }
    return ' ';
  }

  static String removeAllHtmlTags(String htmlText) {
    var exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlText.replaceAll(exp, '');
  }

  //obtem a primeira URL image from HTML String
  static String getFirstImgSrcFromHtml(String htmlText) {
    var regex = '<img.*?src="(.*?)"';
    var exp = RegExp(regex, multiLine: true, caseSensitive: false);
    return exp.allMatches(htmlText).first.group(1);
  }

  static String truncate(String value, int truncateAt) {
    if (value == null) {
      return value;
    }
    //int truncateAt = value.length-1;
    var elepsis = '...'; //define your variable truncation elipsis here
    var truncated = '';

    if (value.length > truncateAt) {
      truncated = value.substring(0, truncateAt - elepsis.length) + elepsis;
    } else {
      truncated = value;
    }
    return truncated;
  }

  static List<int> randomizer(int size) {
    var random = <int>[];
    for (var i = 0; i < size; i++) {
      random.add(Random().nextInt(9));
    }
    return random;
  }

  static String gerarCPF({bool formatted = false}) {
    var n = randomizer(9);
    n..add(gerarDigitoVerificador(n))..add(gerarDigitoVerificador(n));
    return formatted ? formatCPF(n) : n.join();
  }

  static int gerarDigitoVerificador(List<int> digits) {
    var baseNumber = 0;
    for (var i = 0; i < digits.length; i++) {
      baseNumber += digits[i] * ((digits.length + 1) - i);
    }
    var verificationDigit = baseNumber * 10 % 11;
    return verificationDigit >= 10 ? 0 : verificationDigit;
  }

  static String sanitizedCPF(cpf) {
    return cpf.replaceAll(RegExp(r'\.|-'), '');
  }

  static String obfuscateEmail(String email) {
    var em = email.split('@');
    var name = em[0];
    var len = (name.length / 2).floor();
    return name.substring(0, len) + List.filled(len, '*').join() + '@' + em[1];
  }

  static bool emailIsValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
        .hasMatch(email);
  }

  static String removerAcentos(String s) {
    if (s == null) {
      return s;
    }
    var map = <String, String>{
      'â': 'a',
      'Â': 'A',
      'à': 'a',
      'À': 'A',
      'á': 'a',
      'Á': 'A',
      'ã': 'a',
      'Ã': 'A',
      'ê': 'e',
      'Ê': 'E',
      'è': 'e',
      'È': 'E',
      'é': 'e',
      'É': 'E',
      'î': 'i',
      'Î': 'I',
      'ì': 'i',
      'Ì': 'I',
      'í': 'i',
      'Í': 'I',
      'õ': 'o',
      'Õ': 'O',
      'ô': 'o',
      'Ô': 'O',
      'ò': 'o',
      'Ò': 'O',
      'ó': 'o',
      'Ó': 'O',
      'ü': 'u',
      'Ü': 'U',
      'û': 'u',
      'Û': 'U',
      'ú': 'u',
      'Ú': 'U',
      'ù': 'u',
      'Ù': 'U',
      'ç': 'c',
      'Ç': 'C'
    };
    var result = s;
    map.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    return result;
  }

  static bool validarCPF(String cpf) {
    if (cpf == null) {
      return false;
    } else if (cpf == '') {
      return false;
    } else if (cpf.length < 11) {
      return false;
    }

    var sanitizedCPF = cpf.replaceAll(RegExp(r'\.|-'), '').split('').map((String digit) => int.parse(digit)).toList();

    if (sanitizedCPF.length < 11) {
      return false;
    }

    if (blacklistedCPF(sanitizedCPF.join())) {
      return false;
    }

    var result = sanitizedCPF[9] == gerarDigitoVerificador(sanitizedCPF.getRange(0, 9).toList()) &&
        sanitizedCPF[10] == gerarDigitoVerificador(sanitizedCPF.getRange(0, 10).toList());

    return result;
  }

  /// Formatar número de CNPJ
  static String formatCnpj(String cnpj) {
    if (cnpj == null) return null;

    // Obter somente os números do CNPJ
    var numeros = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

    // Testar se o CNPJ possui 14 dígitos
    if (numeros.length != 14) return cnpj;

    // Retornar CPF formatado
    return '${numeros.substring(0, 2)}.${numeros.substring(2, 5)}.${numeros.substring(5, 8)}/${numeros.substring(8, 12)}-${numeros.substring(12)}';
  }

  /// Validar número de CNPJ
  static bool validarCnpj(String cnpj) {
    if (cnpj == null) return false;

    // Obter somente os números do CNPJ
    var numeros = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

    // Testar se o CNPJ possui 14 dígitos
    if (numeros.length != 14) return false;

    // Testar se todos os dígitos do CNPJ são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(numeros)) return false;

    // Dividir dígitos
    var digitos = numeros.split('').map((String d) => int.parse(d)).toList();

    // Calcular o primeiro dígito verificador
    var calc_dv1 = 0;
    var j = 0;
    for (var i in Iterable<int>.generate(12, (i) => i < 4 ? 5 - i : 13 - i)) {
      calc_dv1 += digitos[j++] * i;
    }
    calc_dv1 %= 11;
    var dv1 = calc_dv1 < 2 ? 0 : 11 - calc_dv1;

    // Testar o primeiro dígito verificado
    if (digitos[12] != dv1) return false;

    // Calcular o segundo dígito verificador
    var calc_dv2 = 0;
    j = 0;
    for (var i in Iterable<int>.generate(13, (i) => i < 5 ? 6 - i : 14 - i)) {
      calc_dv2 += digitos[j++] * i;
    }
    calc_dv2 %= 11;
    var dv2 = calc_dv2 < 2 ? 0 : 11 - calc_dv2;

    // Testar o segundo dígito verificador
    if (digitos[13] != dv2) return false;

    return true;
  }

  static bool blacklistedCPF(String cpf) {
    return cpf == '11111111111' ||
        cpf == '22222222222' ||
        cpf == '33333333333' ||
        cpf == '44444444444' ||
        cpf == '55555555555' ||
        cpf == '66666666666' ||
        cpf == '77777777777' ||
        cpf == '88888888888' ||
        cpf == '99999999999';
  }

  static String formatCPF(List<int> n) =>
      '${n[0]}${n[1]}${n[2]}.${n[3]}${n[4]}${n[5]}.${n[6]}${n[7]}${n[8]}-${n[9]}${n[10]}';

  static String sanitizeCPF(String val) {
    return val?.replaceAll(RegExp('[^0-9]'), '');
  }

  static bool isDate(String str) {
    try {
      //"dd/mm/yyyy"
      //DateFormat format = new DateFormat("dd/MM/yyyy");
      //var result = format.parse(str);
      //print(result);
      //DateTime.parse(str);
      var regexPattern =
          r'^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[1,3-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$';

      var regExp = RegExp(
        regexPattern,
        caseSensitive: false,
        multiLine: false,
      );

      if (regExp.hasMatch(str)) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool isNotNullOrEmpty(value) {
    return value != null && value != 'null' && value != '';
  }

  static bool isNotNullOrEmptyAndContain(Map<String, dynamic> json, key) {
    return json.containsKey(key) && isNotNullOrEmpty(json[key]);
  }

  /// Include a [ScriptElement] inside the <head>
  ///
  /// Future<ScriptElement> is completed when the script is loaded
  static Future<html.ScriptElement> loadScript(
    String src, {
    String id,
    bool isAsync = true,
    bool isDefer = false,
    String type = 'text/javascript',
    String integrity,
    String crossOrigin,
    Map<String, String> attr,
  }) {
    var element = id != null
        ? html.document.getElementById(id) as html.ScriptElement
        : html.document.querySelector("script[src='$src']") as html.ScriptElement;

    if (element == null) {
      element = html.ScriptElement()
        ..type = type
        ..async = isAsync
        ..defer = isDefer
        ..src = src;
      if (id != null) {
        element.id = id;
      }
      if (integrity != null) {
        element.integrity = integrity;
      }
      if (crossOrigin != null) {
        element.crossOrigin = crossOrigin;
      }
      if (attr != null) {
        element.attributes.addAll(attr);
      }
      html.document.head.append(element);
    }

    return waitLoad(element);
  }

  /// Include inline [ScriptElement] inside the <head>
  ///
  /// Future<ScriptElement> is completed when the script is loaded
  ///
  /// ex: loadInlineScript('console.log("Hello")');
  static Future<html.ScriptElement> loadInlineScript(
    String src,
    String id, {
    String type = 'text/javascript',
  }) {
    var element = html.document.getElementById(id) as html.ScriptElement;

    if (element == null) {
      element = html.ScriptElement()
        ..type = type
        ..id = id
        ..innerHtml = src;
      html.document.head.append(element);
    }
    return waitLoad(element);
  }

  /// Eval javascript string
  ///
  /// ex: eval('console.log("Hello")');
  static void eval(String script) async {
    js.context.callMethod('eval', [script]);
  }

  static final Map<html.Element, Future> _mapper = {};

  static Future<T> waitLoad<T extends html.Element>(T element) async {
    if (_mapper[element] != null) {
      return await _mapper[element] as T;
    }

    final completer = Completer<T>();

    unawaited(
      element.onLoad.first.then((_) {
        completer.complete(element);
      }),
    );

    unawaited(
      element.onError.first.then((e) {
        completer.completeError(e);
      }),
    );

    return _mapper[element] = completer.future;
  }

  /// Indicates to tools that [future] is intentionally not `await`-ed.
  ///
  /// In an `async` context, it is normally expected that all [Future]s are
  /// awaited, and that is the basis of the lint `unawaited_futures`. However,
  /// there are times where one or more futures are intentionally not awaited.
  /// This function may be used to ignore a particular future. It silences the
  /// `unawaited_futures` lint.
  ///
  /// ```
  /// Future<void> saveUserPreferences() async {
  ///   await _writePreferences();
  ///
  ///   // While 'log' returns a Future, the consumer of 'saveUserPreferences'
  ///   // is unlikely to want to wait for that future to complete; they only
  ///   // care about the preferences being written).
  ///   unawaited(log('Preferences saved!'));
  /// }
  /// ```
  static void unawaited(Future<void> future) {}
}
