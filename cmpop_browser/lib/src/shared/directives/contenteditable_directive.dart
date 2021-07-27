import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

@Directive(
  selector: '[contenteditable][ngControl],'
      '[contenteditable][ngFormControl],'
      '[contenteditable][ngModel]',
  providers: [
    ExistingProvider.forToken(ngValueAccessor, ContentEditableDirective),
  ],
)
class ContentEditableDirective implements ControlValueAccessor, AfterViewInit, AfterChanges {
  @Input()
  String contenteditable = 'false';
  //@Input()
  // var propValueAccessor = 'textContent';

  @override
  void ngAfterChanges() {
    _element.setAttribute('contenteditable', contenteditable);
  }

  @override
  void ngAfterViewInit() {
    _element.setAttribute('contenteditable', contenteditable);
  }

  StreamSubscription removeDisabledState;

  final HtmlElement _element;

  ContentEditableDirective(this._element) {
    _element.setAttribute('contenteditable', contenteditable);
  }

  @HostListener('input')
  void handleChange() {
    onChange(_element.text, rawValue: _element.text);
  }

  /// Writes a new value to the element.
  /// This method will be called by the forms API to write
  /// to the view when programmatic (model -> view) changes are requested.
  /// See: [ControlValueAccessor](https://angular.io/api/forms/ControlValueAccessor#members)
  @override
  void writeValue(value) {
    var normalizedValue = value ?? '';
    _element.text = '$normalizedValue';
  }

  /// This function is called by the forms API when the control status changes to or from "DISABLED".
  /// Depending on the value, it should enable or disable the appropriate DOM element.
  @override
  void onDisabledChanged(bool isDisabled) {
    if (isDisabled) {
      _element.setAttribute('disabled', 'true');
      removeDisabledState = _element.onKeyDown.listen((e) => e.preventDefault());
    } else {
      if (removeDisabledState != null) {
        _element.removeAttribute('disabled');
        removeDisabledState.cancel();
      }
    }
  }

  TouchFunction onTouched = () {};

  @HostListener('blur')
  void touchHandler() {
    onTouched();
  }

  /// Registers a callback function that should be called when the control receives a blur event.
  /// This is called by the forms API on initialization so it can update the form model on blur.
  @override
  void registerOnTouched(TouchFunction fn) {
    onTouched = fn;
  }

  ChangeFunction<String> onChange = (String _, {String rawValue}) {};

  /// Registers a callback function that should be called when
  /// the control's value changes in the UI.
  ///
  /// This is called by the forms API on initialization so it can update
  /// the form model when values propagate from the view (view -> model).
  @override
  void registerOnChange(ChangeFunction<String> fn) {
    onChange = fn;
  }
}
