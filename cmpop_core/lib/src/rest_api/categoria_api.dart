import 'package:cmpop_core/src/rest_api/rest_api_base.dart';
import 'package:cmpop_core/cmpop_core.dart';

class CategoriaApi extends RestApiBase {
  CategoriaApi(RestConfigBase restConfig) : super(restConfig, BackendRoutesPath.categorias);
}
