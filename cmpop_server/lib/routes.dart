import 'package:galileo_framework/galileo_framework.dart';

import 'package:dotenv/dotenv.dart';
import 'package:file/file.dart';
import 'package:cmpop_core/cmpop_core.dart';
import 'package:cmpop_server/controllers/authentication_controller.dart';
import 'package:cmpop_server/controllers/dynamic_rest_controller.dart';
import 'package:cmpop_server/controllers/midia_controller.dart';
import 'package:cmpop_server/controllers/categoria_controller.dart';
import 'package:cmpop_server/controllers/formulario_inscricao_controller.dart';
import 'package:cmpop_server/middleware/auth_middleware.dart';
import 'package:cmpop_server/middleware/mongodb_middleware.dart';
import 'package:cmpop_server/services/static_file_server/my_virtual_directory.dart';

///arquivo de rotas
GalileoConfigurer configureServer(FileSystem fileSystem) {
  return (Galileo app) async {
    // Render `views/hello.jl` when a user visits the application root.
    //app.get('/', (req, res) => res.render('hello'));

    app.get('/', (req, res) => res.write('cmpop Server API'));

    //rotas publicas
    app.chain([MongodbMiddleware().handleRequest]).group(BackendRoutesPath.basePath, (router) {
      router.get('/', (req, res) => res.write('cmpop Server API ${BackendRoutesPath.basePath}'));
      //rotas de autenticação
      router.post('/auth/login', AuthenticationController.authenticate);
      router.post('/auth/check', AuthenticationController.checkToken);
      //router.post('/auth/validateqrcode', AuthenticationController.validateQrCode);

      router.get('/rest', DynamicRestController.all);
      router.get('/rest/findFirstBy', DynamicRestController.findFirstBy);

      //rotas CRUD gastronomia

      //rotas CRUD categorias
      router.get('${BackendRoutesPath.categorias}', CategoriaController.all);
      router.get('${BackendRoutesPath.categorias}/:id', CategoriaController.findById);
      router.get('${BackendRoutesPath.categorias}/by/:byKey/:byValue', CategoriaController.findByKeyValue);
      router.get('${BackendRoutesPath.categorias}/count/slug/', CategoriaController.countSlug);
      router.get('${BackendRoutesPath.categorias}/by/map/', CategoriaController.findByMap);

      //rotas Formulario de inventario
      router.post(
          '${BackendRoutesPath.formularioInscricao}/envia', FormularioInscricaoController.enviaFormularioToEmail);
      router.get('${BackendRoutesPath.formularioInscricao}', FormularioInscricaoController.all);
      router.get('${BackendRoutesPath.formularioInscricao}/:id', FormularioInscricaoController.findById);
      router.get(
          '${BackendRoutesPath.formularioInscricao}/by/:byKey/:byValue', FormularioInscricaoController.findByKeyValue);
      router.get('${BackendRoutesPath.formularioInscricao}/count/slug/', FormularioInscricaoController.countSlug);
      router.get('${BackendRoutesPath.formularioInscricao}/by/map/', FormularioInscricaoController.findByMap);
    });

    //rotas privadas
    app.chain([AuthMiddleware().handleRequest, MongodbMiddleware().handleRequest]).group(BackendRoutesPath.basePath,
        (router) {
      router.post('/auth/usuario', AuthenticationController.createUsuario);
      router.put('/auth/usuario/by/username', AuthenticationController.updateUsuarioByUsername);
      router.put('/auth/usuario/by/id', AuthenticationController.updateUsuarioById);

      //rotas dynamic REST API
      router.post('/rest', DynamicRestController.create);
      router.put('/rest', DynamicRestController.updateBy);
      router.delete('/rest', DynamicRestController.deleteBy);

      //rotas CRUD midias arquivos de imagem jpeg, png
      router.post('/midias', MidiaController.create);
      router.get('/midias', MidiaController.all);
      router.get('/midias/:id', MidiaController.getById);
      router.post('/midias/:id', MidiaController.update);
      //router.delete('/midias/all', MidiaController.deleteAll);
      router.delete('/midias/:id', MidiaController.delete);

      //rotas CRUD categorias
      router.post('${BackendRoutesPath.categorias}', CategoriaController.create);
      router.put('${BackendRoutesPath.categorias}/:id', CategoriaController.updateById);
      router.delete('${BackendRoutesPath.categorias}/:id', CategoriaController.deleteById);

      //rotas CRUD Inventario
      router.post('${BackendRoutesPath.formularioInscricao}', FormularioInscricaoController.create);
      router.put('${BackendRoutesPath.formularioInscricao}/:id', FormularioInscricaoController.updateById);
      router.delete('${BackendRoutesPath.formularioInscricao}/:id', FormularioInscricaoController.deleteById);
    });

    // Mount static server at web in development.
    // The `CachingVirtualDirectory` variant of `VirtualDirectory` also sends `Cache-Control` headers.
    //
    // In production, however, prefer serving static files through NGINX or a
    // similar reverse proxy.
    //
    // Read the following two sources for documentation:
    // * https://medium.com/the-Galileo-framework/serving-static-files-with-the-Galileo-framework-2ddc7a2b84ae
    // * https://github.com/Galileo-dart/static
    //isso vai servir os arquivos estaticos em desemvolvimento
    if (!app.environment.isProduction) {
      //STORAGE_PATH=C:\wamp64\www\  /var/www/html/
      final vDir = MyVirtualDirectory(app, fileSystem, source: fileSystem.directory(env['STORAGE_PATH']), //web
          callback: (f, rec, res) {
        res.headers['x-frame-options'] = '*';
        return true;
      });
      app.fallback(vDir.handleRequest);
    }

    // Throw a 404 if no route matched the request.
    app.fallback((req, res) => throw GalileoHttpException.notFound());

    // Set our application up to handle different errors.
    //
    // Read the following for documentation:
    // * https://github.com/Galileo-dart/Galileo/wiki/Error-Handling

    final oldErrorHandler = app.errorHandler;
    app.errorHandler = (e, req, res) async {
      if (req.accepts('text/html', strict: true)) {
        if (e.statusCode == 404 && req.accepts('text/html', strict: true)) {
          await res.render('error', {'message': 'No file exists at ${req.uri}.'});
        } else {
          await res.render('error', {'message': e.message});
        }
      } else {
        return await oldErrorHandler(e, req, res);
      }
    };
  };
}
