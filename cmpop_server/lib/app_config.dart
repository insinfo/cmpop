import 'package:dotenv/dotenv.dart' show env;

class AppConfig {
  static String storagePath = "${env['STORAGE_PATH']}/storage/$storageDirectoryName";
  static String storageWebPath = '/storage/$storageDirectoryName';
  static String storagePathMedia = "$storagePath/midias";
  static String storageWebPathMedia = '$storageWebPath/midias';
  static String storageDirectoryName = 'cmpop';
  static String webPathBase = "${env['WEB_PATH_BASE']}";
}
