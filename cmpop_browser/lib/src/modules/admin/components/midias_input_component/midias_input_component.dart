import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:cmpop_browser/src/modules/admin/components/galeria/galeria.dart';
import 'package:cmpop_browser/src/shared/pipes/truncate_pipe.dart';
import 'package:cmpop_core/cmpop_core.dart';

@Component(selector: 'midias-input', templateUrl: 'midias_input_component.html', styleUrls: [
  'midias_input_component.css'
], directives: [
  coreDirectives,
  formDirectives,
  MaterialButtonComponent,
  MaterialFabComponent,
  MaterialIconComponent,
  MaterialDialogComponent,
  ModalComponent,
  GaleriaComponent,
], providers: [
  overlayBindings
], pipes: [
  TruncatePipe,
  commonPipes,
])
class MidiasInputComponent implements ControlValueAccessor {
  Midia selected;
  var midias = <Midia>[];

  @ViewChild('galeria')
  GaleriaComponent galeria;

  bool showModalGaleria = false;

  final NgControl ngControl;
  StreamSubscription ssControlValueChanges;
  //contrutor
  MidiasInputComponent(@Self() @Optional() this.ngControl, ChangeDetectorRef changeDetector) {
    if (ngControl != null) {
      ngControl.valueAccessor = this;
      if (ngControl.control != null) {
        //este ouvinte de evento é chamado todo vez que o modelo vinculado pelo ngModel muda
        ssControlValueChanges = ngControl.control.valueChanges.listen((value) {
          midias = value;
        });
      }
    }
  }

  void openModalGaleria() {
    showModalGaleria = true;
  }

  void closeGaleria() {
    showModalGaleria = false;
    galeria.clearSelections();
  }

  void removeMidia(Midia m, e) {
    e.stopPropagation();
    midias.remove(m);
  }

  /* final _changeController = StreamController<List<Midia>>();
  @Output('change')
  Stream<List<Midia>> get onChange => _changeController.stream;*/

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

  void onSelectMidias(List<Midia> midiasSelected) {
    midias ??= <Midia>[];
    midiasSelected.forEach((item) {
      var exist = false;
      midias.forEach((element) {
        if (element.id == item.id) {
          exist = true;
        }
      });
      if (exist == false) {
        midias.add(item);
        //_changeController.add(midias);
        onChangeControlValueAccessor(midias);
      }
    });
  }

  void addIfNotExist(Midia item) {
    var exist = false;
    midias.forEach((element) {
      if (element.id == item.id) {
        exist = true;
      }
    });
    if (exist == false) {
      midias.add(item);
      // _changeController.add(midias);
    }
  }
}
