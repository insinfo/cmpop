import 'dart:async';
import 'package:angular/angular.dart';

import 'package:angular_forms/angular_forms.dart';
import 'package:cmpop_browser/src/shared/pipes/truncate_pipe.dart';
import 'dart:html' as html;

//const List<Type> customSelectInputDirectives = [CustomSelectInputComponent];

@Component(selector: 'select-input', templateUrl: 'select_input_component.html', styleUrls: [
  'select_input_component.css',
], directives: [
  coreDirectives,
  formDirectives,
], providers: [
  //ExistingProvider.forToken(ngValueAccessor, MidiaInputComponent),
], pipes: [
  TruncatePipe,
  commonPipes,
])
class CustomSelectInputComponent implements ControlValueAccessor, AfterViewInit, OnDestroy {
  //contrutor
  CustomSelectInputComponent(@Self() @Optional() this.ngControl, ChangeDetectorRef changeDetector) {
    if (ngControl != null) {
      ngControl.valueAccessor = this;
      if (ngControl.control != null) {
        //este ouvinte de evento é chamado todo vez que o modelo vinculado pelo ngModel muda
        ssControlValueChanges = ngControl.control.valueChanges.listen((value) {
          itemSelected = value;
        });
      }
    }
  }

  dynamic itemSelected;

  @ViewChild('list')
  html.UListElement list;

  @Input('customInputClass')
  String customInputClass = '';

  @Input('customListClass')
  String customListClass = '';

  @Input('options')
  set options(List<dynamic> o) {
    selectOptions = o;
    selectOptionsBkp.addAll(o);
  }

  List<dynamic> selectOptions;

  List<dynamic> selectOptionsBkp = [];

  void inputKeypressHandle(html.KeyboardEvent e, html.InputElement input) {
    //print(e.key);
    selectOptions = [];
    if (input.value.isNotEmpty) {
      var matchValues = [];
      selectOptionsBkp.forEach((element) {
        if (element.toString().contains(input.value)) {
          matchValues.add(element);
        }
      });

      selectOptions.addAll(matchValues);
    } else {
      selectOptions.addAll(selectOptionsBkp);
    }
  }

  StreamController<dynamic> onChangeStreamController = StreamController<dynamic>();

  @Output('change')
  Stream get onChange => onChangeStreamController.stream;

  @Input('readonly')
  bool readonly = true;

  final NgControl ngControl;
  StreamSubscription ssControlValueChanges;

  bool isShowList = false;

  @Input('placeholder')
  String placeholder = 'Selecione';

  /// Select or fontIcon
  @Input('type')
  String type = 'select';

  @Input('customOptionTemplate')
  dynamic customOptionTemplate;

  bool get isCustomOptionTemplate => customOptionTemplate != null;

  @Input('customInputTemplate')
  dynamic customInputTemplate;

  bool get isCustomInputTemplate => customOptionTemplate != null;

// **************** INICIO FUNÇÔES DO NGMODEL ControlValueAccessor *********************
  @override
  void writeValue(newVal) {
    // midia = newVal;
  }

  //função a ser chamada para notificar e modificar o modelo vinculado pelo ngmodel
  ChangeFunction<dynamic> onChangeControlValueAccessor = (dynamic _, {String rawValue}) {};
  TouchFunction onTouchedControlValueAccessor = () {};

  @override
  void registerOnChange(ChangeFunction<dynamic> fn) {
    onChangeControlValueAccessor = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    onTouchedControlValueAccessor = fn;
  }

  @override
  void onDisabledChanged(bool state) {}

  //**************** /FIM FUNÇÔES DO NGMODEL ControlValueAccessor ****************

  void toggleList() {
    //list.classes.toggle('show');
    isShowList = !isShowList;
  }

  void showList() {
    isShowList = true;
  }

  void hideList() {
    isShowList = false;
  }

  void onSelect(selected) {
    itemSelected = selected;
    onChangeControlValueAccessor(selected);
    hideList();

    onChangeStreamController.add(itemSelected);
  }

  @override
  void ngAfterViewInit() {}

  @override
  void ngOnDestroy() {
    ssControlValueChanges?.cancel();
    ssControlValueChanges = null;
  }
}
