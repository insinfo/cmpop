import 'package:mongo_dart/mongo_dart.dart';
import 'package:cmpop_server/db_config.dart';

Db db;

Future<void> dbConnect() async {
  //if (db == null) {
  /* db = Db("mongodb://${mongodbConInfo.host}:${mongodbConInfo.port}/${mongodbConInfo.database}");
    await db.open();*/

  db = await Db.create(
      "mongodb://${mongodbConInfo.username}:${mongodbConInfo.password}@${mongodbConInfo.host}:${mongodbConInfo.port}/${mongodbConInfo.database}");
  await db.open();
  print('db_connect.dart mongodbConInfo ${mongodbConInfo.host}');
  //}
}

//Db get db => _db;

Future<Db> get getDb async {
  if (db?.isConnected == true) {
    return db;
  }
  await dbConnect();
  return db;
}
