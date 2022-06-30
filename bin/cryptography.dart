import 'package:encrypt/encrypt.dart';

class Cryptography {
  final key = Key.fromUtf8('put32charactershereeeeeeeeeeeee!'); //32 chars
  final iv = IV.fromUtf8('put16characters!'); //16 chars

  String encrypt(String textToEncrypt) {
    final e = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted_data = e.encrypt(textToEncrypt, iv: iv);
    return encrypted_data.base64;
  }

  String decrypt(String encryptedText) {
    final e = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted_data = e.decrypt(Encrypted.fromBase64(encryptedText), iv: iv);
    return decrypted_data;
  }
}