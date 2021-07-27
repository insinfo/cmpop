import 'package:angular/angular.dart';
import 'package:angular/core.dart';

import 'dart:html' as html;

@Directive(selector: '[custominnerhtml]') //custominnerhtml
class CustomInnerHTMLDirective implements AfterChanges {
  @Input('custominnerhtml')
  String content = '';

  final html.Element _el;

  CustomInnerHTMLDirective(this._el);

  @override
  void ngAfterChanges() {
    _el.setInnerHtml(content, treeSanitizer: html.NodeTreeSanitizer.trusted);
  }
}
