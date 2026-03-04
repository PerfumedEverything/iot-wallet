import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:tonutils/tonutils.dart' as ton;

/// Fast TON key derivation using platform-native PBKDF2.
/// Produces V4R2 addresses matching Tonkeeper.
class TonKeyService {
  /// Derives a WalletV4R2 address from a mnemonic phrase.
  /// Uses native PBKDF2 (iOS CommonCrypto / Android javax.crypto)
  /// instead of pure-Dart implementation — typically 10-50x faster.
  static Future<String> mnemonicToAddress(List<String> words) async {
    final publicKeyBytes = await _derivePublicKey(words);
    final wallet = ton.WalletContractV4R2.create(publicKey: publicKeyBytes);
    return wallet.address.toString(isBounceable: false);
  }

  // ── internals ──────────────────────────────────────────────────────────────

  static Future<Uint8List> _derivePublicKey(List<String> words) async {
    final seed = await _pbkdf2(words);
    final privateKeySeed = seed.sublist(0, 32);

    final ed25519 = Ed25519();
    final keyPair = await ed25519.newKeyPairFromSeed(privateKeySeed);
    final publicKey = await keyPair.extractPublicKey();
    return Uint8List.fromList(publicKey.bytes);
  }

  /// TON seed derivation:
  /// 1. entropy = HMAC-SHA512(key=mnemonic, message="")
  /// 2. seed    = PBKDF2(HMAC-SHA512, password=entropy, salt="TON default seed", 100000) → 64 bytes
  static Future<Uint8List> _pbkdf2(List<String> words) async {
    // Step 1: entropy
    final entropy = await Hmac.sha512().calculateMac(
      Uint8List(0),
      secretKey: SecretKey(utf8.encode(words.join(' '))),
    );

    // Step 2: PBKDF2
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha512(),
      iterations: 100000,
      bits: 512,
    );

    final derived = await pbkdf2.deriveKey(
      secretKey: SecretKey(entropy.bytes),
      nonce: utf8.encode('TON default seed'),
    );

    return Uint8List.fromList(await derived.extractBytes());
  }
}
