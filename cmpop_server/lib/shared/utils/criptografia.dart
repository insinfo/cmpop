//chaves de userdata encriptados pelo site
//https://www.tools4noobs.com/online_tools/encrypt/
//usando Algorithm: blowfish Mode: CBC Key: jubarte  Encode: Hexa

import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class Criptografia {
  static String key = '9B7D2C34A366BF890C730641E6CECF6F';
  //static String nonce = '/gUdnEgLZYoXANCCuxPo+DoBxO9Q+bDC';

  /// O metodo responsavel por descriptograr uma mensagem
  /// @param string $ciphertext Mensagem criptografada
  /// @param string $key Chave para realizar a descriptografia precisa ser a mesma usada na criptografia Exemplo: "skjj400ndkdçg00"
  /// @param string $nonce
  /// @return mixed
  static String decrypt(String ciphertext, [String key]) {
    key ??= Criptografia.key;
    final k = Key.fromUtf8(key);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(k));
    //utf8.encode
    final encrypted = Encrypted(base64.decode(ciphertext));
    final plainText = encrypter.decrypt(encrypted, iv: iv);
    return plainText;
  }

  /// O metodo responsavel por criptofrafar uma mensagem
  /// @param string $message Mensagem a ser criptograda
  /// @param string $key Chave para realizar a criptografia Exemplo: "9B7D2C34A366BF890C730641E6CECF6F"
  /// @param bool $returnBase64 retorna em base 64 a dados codificados
  /// @return  string
  static String encrypt(String message, [String key]) {
    key ??= Criptografia.key;
    final k = Key.fromUtf8(key);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(k));
    final encrypted = encrypter.encrypt(message, iv: iv);
    return encrypted.base64;
  }
}
