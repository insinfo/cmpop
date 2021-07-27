import 'dart:typed_data';

class FormularioAnexo {
  FormularioAnexo({this.name, this.size, this.bytes, this.type});
  String name;
  //type mimeType
  String type;

  /// Size in bytes
  int size;

  Uint8List bytes;
  dynamic fileRef;

  dynamic dataUrl = '';
}
