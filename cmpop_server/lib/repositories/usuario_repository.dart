import 'package:cmpop_core/cmpop_core.dart';
import 'package:cmpop_server/cmpop_server.dart';
import 'package:cmpop_server/exceptions/user_not_found_exception.dart';

import 'package:cmpop_server/shared/utils/criptografia.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UsuarioRepository {
  Future<List<Map<String, dynamic>>> getAllAsMap() {
    return db.collection('user').find().toList();
  }

  Future<Map<String, dynamic>> getByIdAsMap(String id) async {
    // return db.collection('user').find({'id': id}).first;
    return db.collection('user').findOne(where.id(ObjectId.fromHexString(id)));
  }

  Future<Usuario> getById(String id) async {
    final map = await getByIdAsMap(id);
    return Usuario.fromMap(map);
  }

  Future<Map<String, dynamic>> getByUsernameAsMap(String username) async {
    return db.collection('user').find({'username': username}).first;
  }

  Future<Map<String, dynamic>> getByUsernameAndPassAsMap(String username, String password) async {
    var p = password;
    if (!p.contains('@cript')) {
      final pws = Criptografia.encrypt(p, Criptografia.key);
      p = '$pws@cript';
    }
    final result = await db.collection('user').findOne({
      'username': username,
      'password': p,
    });
    if (result == null) {
      throw UserNotFoundException();
    }
    return result;
  }

  Future<Usuario> getByUsername(String username) async {
    final map = await getByUsernameAsMap(username);

    return Usuario.fromMap(map);
  }

  Future<Usuario> getByUsernameAndPass(String username, String password) async {
    final map = await getByUsernameAndPassAsMap(username, password);

    return Usuario.fromMap(map);
  }

  Future<void> createFromMap(Map<String, dynamic> data) async {
    final pws = Criptografia.encrypt(data['password'].toString(), Criptografia.key);
    data['password'] = '$pws@cript';
    await db.collection('user').insert(data);
  }

  Future<void> updateFromMap(String id, Map<String, dynamic> data) async {
    if (data.containsKey('password')) {
      if (!data['password'].toString().contains('@cript')) {
        final pws = Criptografia.encrypt(data['password'].toString(), Criptografia.key);
        data['password'] = '$pws@cript';
      }
    }
    //final Map<String, dynamic> item = await db.collection('user').findOne(where.id(ObjectId.fromHexString(id)));
    //final mesclado = CombinedMapView([data, item]);
    return await db.collection('user').updateOne(where.id(ObjectId.fromHexString(id)), data);
  }
}
