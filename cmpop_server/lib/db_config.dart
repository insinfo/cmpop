import 'package:dotenv/dotenv.dart' show env;

class DbConfig {
  DbConfig({this.username, this.password, this.host, this.port, this.database});
  String username;
  String password;
  String host;
  int port;
  String database;
}

final mongodbConInfo = DbConfig(
  database: env['DB_NAME'],
  username: env['DB_USERNAME'],
  password: env['DB_PASSWORD'],
  host: env['DB_HOST'],
  port: int.tryParse(env['DB_PORT']),
);
