import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:cmpop_browser/src/modules/admin/components/galeria/galeria.dart';
import 'package:cmpop_browser/src/shared/pipes/truncate_pipe.dart';
import 'package:cmpop_core/cmpop_core.dart';

@Component(selector: 'midia-input', templateUrl: 'midia_input_component.html', styleUrls: [
  'package:angular_components/app_layout/layout.scss.css',
  'midia_input_component.css',
], directives: [
  coreDirectives,
  formDirectives,
  MaterialButtonComponent,
  MaterialFabComponent,
  MaterialIconComponent,
  MaterialDialogComponent,
  ModalComponent,
  ModalComponent,
  GaleriaComponent,
], providers: [
  overlayBindings,
  //ExistingProvider.forToken(ngValueAccessor, MidiaInputComponent),
], pipes: [
  TruncatePipe,
  commonPipes,
])
class MidiaInputComponent implements ControlValueAccessor, AfterViewInit, OnDestroy {
  Midia midia;

  @ViewChild('galeria')
  GaleriaComponent galeria;

  final NgControl ngControl;
  StreamSubscription ssControlValueChanges;
  //contrutor
  MidiaInputComponent(@Self() @Optional() this.ngControl, ChangeDetectorRef changeDetector) {
    if (ngControl != null) {
      ngControl.valueAccessor = this;
      if (ngControl.control != null) {
        //este ouvinte de evento é chamado todo vez que o modelo vinculado pelo ngModel muda
        ssControlValueChanges = ngControl.control.valueChanges.listen((value) {
          midia = value;
        });
      }
    }
  }

  bool showModalGaleria = false;

  void openModalGaleria() {
    showModalGaleria = true;
  }

  void closeGaleria() {
    showModalGaleria = false;
    galeria.clearSelections();
  }

  void removeMidia(Midia m, e) {
    e.stopPropagation();
    midia = null;
    onChangeControlValueAccessor(midia);
  }

  @Input()
  String placeholder = '';

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

  void onSelectMidia(Midia midiasSelected) {
    if (midia == null) {
      midia = midiasSelected;
    } else if (midia.id != midiasSelected.id) {
      midia = midiasSelected;
    }
    onChangeControlValueAccessor(midiasSelected);
  }

  @override
  void ngAfterViewInit() {}

  @override
  void ngOnDestroy() {
    ssControlValueChanges?.cancel();
    ssControlValueChanges = null;
  }
}
