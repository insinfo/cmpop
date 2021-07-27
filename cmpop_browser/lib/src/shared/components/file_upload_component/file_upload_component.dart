import 'dart:async';
import 'dart:typed_data';

import 'package:angular/angular.dart';
import 'package:angular/security.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:cmpop_browser/src/shared/utils/utils.dart';
import 'package:cmpop_core/cmpop_core.dart';
import 'dart:html';

/*extension Uint8ListToImage on FormularioAnexo {
  String get asImage {
    return Url.createObjectUrl(Blob([bytes.buffer], mimeType));
  }
}*/

/*class MyFormularioAnexo extends FormularioAnexo {
  MyFormularioAnexo({String name, int size, Uint8List bytes, String mimeType})
      : super(name: name, size: size, bytes: bytes, mimeType: mimeType) {
    asImage = Url.createObjectUrl(Blob([bytes.buffer], mimeType));
  }
}*/

@Component(
    selector: 'file-upload',
    templateUrl: 'file_upload_component.html',
    styleUrls: ['file_upload_component.css'],
    directives: [coreDirectives, formDirectives],
    pipes: [])
class FileUploadComponent {
  final DomSanitizationService sanitizer;

  FileUploadComponent(this.sanitizer);

  @Input()
  String requiredFileType;

  @Input()
  String noFilesMessage = 'Nenhum arquivo carregado ainda.'; //"No file uploaded yet."

  @Input()
  bool multiple = true;

  @Input()
  List<FormularioAnexo> files = <FormularioAnexo>[];

  @Input('isValid')
  bool isValid = false;

  @Input()
  bool isLimitSize = true;

  int currentSizeInBytes = 0;

  String get currentSizeInMegabytesStr => (currentSizeInBytes / (1024 * 1024)).toStringAsFixed(2);

  @Input()
  int limitSizeInMB = 24;

  bool isLoadingFile = false;

  StreamController<FormularioAnexo> onChangeStreamController = StreamController<FormularioAnexo>();

  @Output('change')
  Stream get onChange => onChangeStreamController.stream;

  void onFileSelected(FileUploadInputElement inputFile) async {
    isLoadingFile = true;
    FormularioAnexo anexo;
    if (inputFile?.files?.isNotEmpty == true) {
      inputFile.files.forEach((file) {
        currentSizeInBytes += file.size;
      });

      /*if (inputFile.files.length > 3) {
        html.window.alert('O limite de arquivos anexados é 3');
        inputFile.value = '';
        sizeInBytes = 0;
        arquivosValidados = false;
      }
    */

      for (var f in inputFile.files) {
        if (isLimitSize) {
          var sizeInMB = (currentSizeInBytes / (1024 * 1024));
          if (sizeInMB > limitSizeInMB) {
            window.alert(
                'O limite total em megabytes de anexos é $limitSizeInMB Megabytes, você ultrapassou o limite tentando adicionar $currentSizeInMegabytesStr Megabytes, remova algum arquivo para corrigir');
            inputFile.value = '';
            //isValid = false;
            currentSizeInBytes -= f.size;
            isLoadingFile = false;
            return;
          }
        }

        var bytes = await Utils.fileToArrayBuffer(f);
        anexo = FormularioAnexo(bytes: bytes as Uint8List, name: f.name, size: f.size, type: f.type);
        if (f.type?.startsWith('image/') == true) {
          anexo.dataUrl = await Utils.fileToDataUrl(f);
        } else if (f.type?.startsWith('application/pdf') == true) {
          anexo.dataUrl = sanitizer.bypassSecurityTrustResourceUrl(await Utils.fileToDataUrl(f));
        }

        isValid = true;
        files.add(anexo);
      }

      //  print('currentSize $currentSizeInMegabytesStr Megabytes');
      // print('files ${files}');
    }

    onChangeStreamController.add(anexo);
    isLoadingFile = false;
    inputFile.value = '';
  }

  void removeFile(FormularioAnexo f) {
    //inputFile.value = '';
    currentSizeInBytes -= f.size;
    files.remove(f);
  }

  var isMaxmize = false;
  HtmlElement _inner;
  void maxmize(HtmlElement inner) {
    isMaxmize = true;
    _inner = inner;
    _inner.classes.add('maxmize');
  }

  void minimize(event, HtmlElement inner) {
    event.stopPropagation();
    isMaxmize = false;
    _inner.classes.remove('maxmize');
  }
}
