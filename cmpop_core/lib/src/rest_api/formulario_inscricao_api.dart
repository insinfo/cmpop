import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cmpop_core/cmpop_core.dart';
import 'package:http_parser/http_parser.dart';

//formulario_inscricao
class FormularioInscricaoApi extends RestApiBase {
  FormularioInscricaoApi(RestConfigBase restConfig) : super(restConfig, BackendRoutesPath.formularioInscricao);

  final String _basaApiPath = BackendRoutesPath.formularioInscricao;

  Future<void> enviaFormularioToEmail(FormularioInscricaoModel form) async {
    var url = Uri.parse('${restConfig.serverURL}$_basaApiPath/envia');
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({'Authorization': restConfig.defaultHeaders['Authorization']});
    request.fields['data'] = jsonEncode(form.toMap());

    form.files?.forEach((file) {
      request.files.add(http.MultipartFile.fromBytes('file[]', file.bytes,
          contentType: MediaType('application', 'octet-stream'), filename: file.name));
    });
    var resp = await request.send();
    /* var resp = await _client.post(Uri.parse('${restConfig.serverURL}$_basaApiPath/envia'),
        body: jsonEncode(form.toMap()), headers: restConfig.defaultHeaders);*/

    if (resp.statusCode != 200) {
      throw Exception('Falha ao enviar os dados');
    }
  }
}
