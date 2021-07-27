import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';

///Example1: <input [textMask]="'xxx.xxx.xxx-xx'" name="cpf" type="text">
///Example2: <input textMask="xxx.xxx.xxx-xx" name="cpf" type="text">
@Directive(selector: '[textMask]', providers: [ClassProvider(TextMaskDirective)])
class TextMaskDirective implements OnDestroy {
  String _textMask;

  @Input()
  set textMask(String val) {
    _textMask = val ?? 'xxx.xxx.xxx-xx';
  }

  /* int _maxLength = 14;
  @Input('maxLength')
  set maxLength(String val) {
    _maxLength = val != null ? int.tryParse(val) : 14;
  }*/

  String escapeCharacter = 'x';
  InputElement inputElement;
  final Element _el;
  var lastTextSize = 0;
  var lastTextValue = '';
  StreamSubscription ssOnInput;

  TextMaskDirective(this._el) {
    lastTextSize = 0;
    inputElement = _el;
    ssOnInput = inputElement.onInput.listen((e) {
      _onChange();
    });
  }

  void _onChange() {
    var text = inputElement.value;

    if (_textMask != null) {
      if (text.length <= _textMask.length) {
        // its deleting text
        if (text.length < lastTextSize) {
          if (_textMask[text.length] != escapeCharacter) {
            //inputElement.focus();
            inputElement.setSelectionRange(inputElement.value.length, inputElement.value.length);
            inputElement.select();
          }
        } else {
          // its typing
          if (text.length >= lastTextSize) {
            var position = text.length;
            position = position <= 0 ? 1 : position;
            if (position < _textMask.length - 1) {
              if ((_textMask[position - 1] != escapeCharacter) && (text[position - 1] != _textMask[position - 1])) {
                inputElement.value = _buildText(text);
              }
              if (_textMask[position] != escapeCharacter) {
                inputElement.value = '${inputElement.value}${_textMask[position]}';
              }
            }
          }

          if (inputElement.selectionStart < inputElement.value.length) {
            inputElement.setSelectionRange(inputElement.value.length, inputElement.value.length);
            inputElement.select();
          }
        }
        // update cursor position
        lastTextSize = inputElement.value.length;
        lastTextValue = inputElement.value;
      } else {
        inputElement.value = lastTextValue;
      }
    } //mask != null
  }

  String _buildText(String text) {
    var result = '';
    for (var i = 0; i < text.length - 1; i++) {
      result += text[i];
    }
    result += _textMask[text.length - 1];
    result += text[text.length - 1];
    return result;
  }

  @override
  void ngOnDestroy() {
    ssOnInput?.cancel();
  }
}
