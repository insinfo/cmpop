@JS()
library angular_recaptcha;

import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular/core.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:dart_browser_loader/dart_browser_loader.dart' show loadScript;
import 'package:dart_browser_loader/src/utils.dart' show waitLoad;
import 'package:js/js.dart';

@JS('grecaptcha.render')
external num _render(HtmlElement container, AngularRecaptchaParameters parameters);

@JS('grecaptcha.reset')
external void _reset(num id);

@JS()
@anonymous
class AngularRecaptchaParameters {
  external String get sitekey;

  external String get theme;

  external Function get callback;

  external String get type;

  external String get size;

  external String get tabindex;

  @JS('expired-callback')
  external Function get expiredCallback;

  external factory AngularRecaptchaParameters(
      {String sitekey,
      String theme,
      Function callback,
      String type,
      Function expiredCallback,
      String size,
      String tabindex});
}

@Component(
  selector: 'angular-recaptcha',
  styleUrls: ['angular_recaptcha.css'],
  template: '',
)
class AngularRecaptcha extends ValueAccessor implements AfterViewInit, OnDestroy {
  final _onExpireCtrl = StreamController<Null>();
  final NgModel _ngModel;
  final HtmlElement _ref;

  num _id;
  bool _autoRender = false;

  dynamic get value => _ngModel?.value;

  num get id => _id;

  bool get autoRender => _autoRender;

  @Output()
  Stream<Null> get expire => _onExpireCtrl.stream;

  @Input('tabindex')
  String tabindex = '0';

  @Input('size')
  String size = 'normal';

  @Input('key')
  String key;

  @Input('theme')
  String theme = 'light';

  @Input('type')
  String type = 'image';

  @Input('auto-render')
  set autoRender(val) {
    _autoRender = _parseBool(val);
  }

  AngularRecaptcha(this._ref, @Optional() this._ngModel) {
    _ngModel?.valueAccessor = this;
  }

  void _callbackResponse(response) {
    writeValue(response);
  }

  void _expireCallback() {
    writeValue(null);
    _onExpireCtrl.add(null);
  }

  @override
  void ngAfterViewInit() {
    if (_autoRender != false) {
      render();
    }
  }

  Future<num> render() async {
    _id = await _safeApiCall<num>(
      () => _render(
        _ref,
        AngularRecaptchaParameters(
          sitekey: key,
          theme: theme,
          callback: allowInterop(_callbackResponse),
          expiredCallback: allowInterop(_expireCallback),
          type: type,
          size: size,
          tabindex: tabindex,
        ),
      ),
    );
    return _id;
  }

  void reset() {
    _safeApiCall(() => _reset(id));
  }

  @override
  void writeValue(dynamic v) {
    _ngModel?.viewToModelUpdate(v);
  }

  // this abstract method does nothing
  // it is implemented only to avoid error messages
  // from analyzer plugin
  @override
  void onDisabledChanged(bool isDisabled) {}

  @override
  void ngOnDestroy() {
    _onExpireCtrl.close();
  }
}

bool _parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  switch (value) {
    case '':
      return true;
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      return false;
  }
}

abstract class ValueAccessor<T> implements ControlValueAccessor<T> {
  ChangeFunction<T> onModelChange = (_, {String rawValue}) {};
  TouchFunction onModelTouched = () {};

  @override
  void registerOnChange(ChangeFunction<T> fn) {
    onModelChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    onModelTouched = fn;
  }

  void touchHandler() {
    onModelTouched();
  }
}

typedef _VoidCallback<T> = FutureOr<T> Function();

Element _script;

FutureOr<T> _safeApiCall<T>(_VoidCallback<T> call) async {
  await loadScript(
    'https://www.google.com/recaptcha/api.js?render=explicit',
    isAsync: true,
    isDefer: true,
    id: 'grecaptcha-jssdk',
  );

  if (_script == null) {
    final scripts = document.querySelectorAll('script');
    _script = scripts.whereType<ScriptElement>().firstWhere(
          (s) => s.src.startsWith('https://www.gstatic.com/recaptcha/'),
          orElse: () => null,
        );
    if (_script == null) return null;
  }
  await waitLoad(_script);
  return await call();
}
