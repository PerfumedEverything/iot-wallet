import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart' hide KeyPair;
import 'package:pinenacl/ed25519.dart';
import 'package:tonutils/src/crypto/nacl/api.dart';
import 'package:tonutils/tonutils.dart' show Mnemonic, KeyPair;

class FastMnemonic {
  /// Синхронна версія для compute() — використовує оригінальний tonutils
  static KeyPair toKeyPairSync(List<String> mnemonic, [String password = '']) {
    return Mnemonic.toKeyPair(mnemonic, password);
  }

  /// Асинхронна швидка версія — НЕ для compute(), викликати напряму
  static Future<KeyPair> toKeyPair(List<String> mnemonic,
      [String password = '']) async {
    var entropy = Mnemonic.toEntropy(mnemonic, password);

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha512(),
      iterations: 100000,
      bits: 512,
    );

    var key = await pbkdf2.deriveKey(
      secretKey: SecretKey(entropy),
      nonce: utf8.encode('TON default seed'),
    );

    var seed64 = Uint8List.fromList(await key.extractBytes());
    var seed32 = Uint8List.fromList(seed64.take(32).toList(growable: false));

    var signingKey = SigningKey(seed: seed32);

    return KeyPair(
      publicKey: signingKey.publicKey.toUint8List(),
      privateKey: signingKey.toUint8List(),
    );
  }
}