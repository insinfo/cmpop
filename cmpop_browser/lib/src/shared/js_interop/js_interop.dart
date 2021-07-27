@JS()
library tinymce;

import 'dart:js_util';

import 'package:js/js.dart';

// Calls invoke JavaScript `JSON.stringify(obj)`.
/*@JS('JSON.stringify')
external String stringify(Object obj);*/

@JS('console.log')
external void consoleLog(dynamic string);

//function loadMap('map',51.505, -0.09, 13, 'A pretty CSS3 popup') {

@JS('loadMap')
external void loadMap(
    dynamic id, double latitude, double longitude, double zoom, String markerText, String accessToken);

/// obtem o conteudo editado do Editor de HTML
@JS('getContentOfTiny')
external String getContentOfTiny(String selector);

/// define o conteudo para edição no Editor de HTML
@JS('setContentOfTiny')
external void setContentOfTiny(String selector, String content);

/// remove a instancia do Editor de HTML
@JS('removeTiny')
external void removeTiny(String selector);

/// inicializa o Editor de HTML
@JS('initTiny')
external void initTiny(String selector, bool full_screen, int editor_height, String initialContent);

/// define o conteudo do editor de codigo
@JS('setContentOfSpck')
external void setContentOfSpck(String selector, String content);

/// obtem o conteudo do editor de codigo, retorna um Promise<String>
@JS('getContentOfSpck')
external dynamic _getContentOfSpck(String selector);

/// obtem o conteudo do editor de codigo, retorna um Future<String>
Future<String> getContentOfSpck(String selector) {
  return promiseToFuture<String>(_getContentOfSpck(selector));
}

@JS('gridMasonry')
external void gridMasonry(String selector);
