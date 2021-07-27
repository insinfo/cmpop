import 'dart:math';

//2^32 = 4294967296
//const int int64MaxValue = 9223372036854775807;
const int int32MaxValue = 4294967296;

class Captcha {
  static String generateCaptcha1() {
    final random = Random();
    //return Integer.toHexString(random.nextInt());
    return (random.nextInt(int32MaxValue)).toRadixString(16);
  }

  static String generateCaptcha2(int value) {
    var s = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    var sb = StringBuffer();
    while (sb.length < value) {
      var index = (Random().nextDouble() * s.length).ceil();
      sb.write(s.substring(index, index + 1));
    }
    return sb.toString();
  }

  static String generateCaptcha3(int value) {
    var random = Random();
    //return (Long.toString(Math.abs(random.nextLong()), 36)).substring(0, value);
    var intRand = random.nextInt(int32MaxValue).abs();
    var str = intRand.toRadixString(36);
    if (str.length > value) {
      return str.substring(0, value);
    } else {
      return str;
    }
  }

  static String generateCaptcha4() {
    var random = Random();
    var length = 7 + (random.nextInt(int32MaxValue).abs() % 3);

    var sb = StringBuffer();
    for (var i = 0; i < length; i++) {
      var baseCharNumber = random.nextInt(int32MaxValue).abs() % 62;
      var charNumber = 0;
      if (baseCharNumber < 26) {
        charNumber = 65 + baseCharNumber;
      } else if (baseCharNumber < 52) {
        charNumber = 97 + (baseCharNumber - 26);
      } else {
        charNumber = 48 + (baseCharNumber - 52);
      }
      sb.write(String.fromCharCode(charNumber));
    }

    return sb.toString();
  }

  static String generateCaptcha5() {
    var random = Random.secure();

    // randomly generated BigInteger
    var bigInteger = BigInt.from(random.nextInt(int32MaxValue));

    // String representation of this BigInteger in the given radix.
    return bigInteger.toRadixString(32);
  }
}
