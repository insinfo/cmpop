import 'dart:io';
import 'package:galileo_production/galileo_production.dart';
import 'package:args/args.dart';

import 'package:cmpop_server/boot.dart';

dynamic main(List<String> args) {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Print this help information.', negatable: false)
    ..addFlag('respawn',
        help: 'Automatically respawn crashed application instances.', defaultsTo: true, negatable: true)
    ..addFlag('use-zone', negatable: false, help: 'Create a new Zone for each request.')
    ..addFlag('quiet', negatable: false, help: 'Completely mute logging.')
    ..addFlag('ssl', negatable: false, help: 'Listen for HTTPS instead of HTTP.')
    ..addFlag('http2', negatable: false, help: 'Listen for HTTP/2 instead of HTTP/1.1.')
    ..addOption('address', abbr: 'a', defaultsTo: '127.0.0.1', help: 'The address to listen on.')
    ..addOption('concurrency',
        abbr: 'j', defaultsTo: Platform.numberOfProcessors.toString(), help: 'The number of isolates to spawn.')
    ..addOption('port', abbr: 'p', defaultsTo: '3000', help: 'The port to listen on.')
    ..addOption('certificate-file', help: 'The PEM certificate file to read.')
    ..addOption('certificate-password', help: 'The PEM certificate file password.')
    ..addOption('key-file', help: 'The PEM key file to read.')
    ..addOption('key-password', help: 'The PEM key file password.')
    ..addOption('dbhost', defaultsTo: 'null', help: 'O Host do banco de dados da jubarte');
  //pega os argumento de linha de comando
  final argumentos = parser.parse(args);
  //pega o arquivo .env e modifica o DB_HOST para o dbhost passado por linha de comando se tiver
  if (argumentos['dbhost'] != 'null') {
    final envFile = File.fromUri(Uri.file('.env'));
    final lines = envFile.readAsLinesSync();
    final newLines = <String>[];
    lines.forEach((line) {
      if (line.startsWith('DB_HOST')) {
        newLines.add("DB_HOST=${argumentos['dbhost']}");
      } else {
        newLines.add(line);
      }
    });
    final content = newLines.join('\r\n');
    envFile.writeAsStringSync(content, flush: true);
  }

  final tempArgs = List<String>.from(args); //args.toList()
  tempArgs.removeWhere((e) => e.startsWith('--dbhost'));
  return Runner('cmpop_server', configureServer).run(tempArgs);
}
