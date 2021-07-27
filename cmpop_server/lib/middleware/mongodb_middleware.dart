import 'dart:async';
import 'package:galileo_framework/galileo_framework.dart';

import 'package:cmpop_server/db_connect.dart';

class MongodbMiddleware {
  Future<bool> handleRequest(RequestContext req, ResponseContext res) async {
    if (db?.isConnected != true) {
      print('MongodbMiddleware dbConnect');
      await dbConnect();
    }
    return true;
  }
}
