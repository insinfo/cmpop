import 'dart:async';
import 'package:dotenv/dotenv.dart' show load, env;
import 'package:galileo_framework/galileo_framework.dart';
import 'package:galileo_cors/galileo_cors.dart';
import 'package:file/local.dart';
import 'package:galileo_configuration/galileo_configuration.dart';
import 'package:cmpop_core/cmpop_core.dart';
import 'db_connect.dart';
import 'routes.dart' as routes;

/// Configures the server instance.
Future configureServer(Galileo app) async {
  // The default options will allow CORS for any request.
  // Combined with `fallback`, you can enable CORS application-wide.
  app.fallback(cors());
  //add Middleware de Authentication
  //app.fallback(AuthMiddleware().handleRequest);

  app.fallback((RequestContext req, ResponseContext res) {
    res.headers['Access-Control-Expose-Headers'] = '*';
    return true;
  });

/*
  // You can also enable CORS for a single route.
  app.get(
    '/my_api',
    chain([
      cors(),
      (req, res) {
        // Request handling logic here...
      }
    ]),
  );

  // Likewise, you can apply CORS to a group.
  app.chain([cors()]).group('/api', (router) {
    router.get('/version', (req, res) => 'v0');
  });

  // Of course, you can configure CORS.
  // The following is just a subset of the available options;
  app.fallback(cors(
    CorsOptions(
      origin: 'https://pub.dartlang.org', successStatus: 200, // default 204
      allowedHeaders: ['POST'],
      preflightContinue: false, // default false
    ),
  ));

  // You can specify the origin in different ways:
  CorsOptions(origin: 'https://pub.dartlang.org');
  CorsOptions(origin: ['https://example.org', 'http://foo.bar']);
  CorsOptions(origin: RegExp(r'^foo\.[^$]+'));
  CorsOptions(origin: (String s) => s.length == 4);

  // Lastly, you can dynamically configure CORS:
  app.fallback(dynamicCors((req, res) {
    return CorsOptions(
      origin: [
        req.headers.value('origin') ?? 'https://pub.dartlang.org',
        RegExp(r'\.com$'),
      ],
    );
  }));*/

  //carrega o arquivo .env
  load('.env');
  //db connect
  await dbConnect();
  // Grab a handle to the file system, so that we can do things like
  // serve static files.
  const fs = LocalFileSystem();

  if (env['APP_ENV'] == 'development') {
    //AppConfig.basePath = '/cmpop_server/api/v1';
  }

  print('boot_galileo.dart AppConfig.basePath ${BackendRoutesPath.basePath}');
  //file system config
  await app.configure(configuration(fs));
  //routes config
  await app.configure(routes.configureServer(fs));
}
