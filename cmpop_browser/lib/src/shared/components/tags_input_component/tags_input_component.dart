import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

@Component(
  selector: 'tags-input',
  templateUrl: 'tags_input_component.html',
  styleUrls: ['tags_input_component.css'],
  directives: [
    coreDirectives,
    formDirectives,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, TagsInputComponent),
  ],
)
class TagsInputComponent implements ControlValueAccessor<List<String>> {
  String selected = '';
  var tags = <String>[];

  @Input()
  String placeholder = '';

  // ...could define a setter that call `_changeController.add(value)`

  final _changeController = StreamController<List<String>>();

  @Output('change')
  Stream<List<String>> get onChange => _changeController.stream;

  @override
  void writeValue(List<String> newVal) {
    tags = newVal;
    print('writeValue newVal $newVal');
  }

  @override
  void registerOnChange(callback) {
    onChange.listen((value) => callback(value));
  }

  // optionally you can implement the rest interface methods
  @override
  void registerOnTouched(TouchFunction callback) {}

  @override
  void onDisabledChanged(bool state) {}
}
