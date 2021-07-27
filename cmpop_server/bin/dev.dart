import 'dart:io';
import 'package:cmpop_server/pretty_logging.dart';
import 'package:cmpop_server/boot.dart';
import 'package:galileo_framework/galileo_framework.dart';
import 'package:galileo_hot/galileo_hot.dart';
import 'package:logging/logging.dart';
import 'package:dotenv/dotenv.dart' show env, load;

dynamic main() async {
  // Watch the config/ and web/ directories for changes, and hot-reload the server.
  hierarchicalLoggingEnabled = true;

  load('.env');

  final hot = HotReloader(() async {
    final logger = Logger.detached('cmpop_server')
      ..level = Level.ALL
      ..onRecord.listen(prettyLog);
    final app = Galileo(logger: logger);
    await app.configure(configureServer);
    return app;
  }, [
    Directory('config'),
    Directory('lib'),
    Directory('lib/controller'),
  ]);

  final port = int.tryParse(env['APP_HOST_PORT']);
  final host = env['APP_HOST'];

  await hot.startServer(host, port); //127.0.0.1 3000
  print('startServer cmpop_server on http://$host:$port');
}
