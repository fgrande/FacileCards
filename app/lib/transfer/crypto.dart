// Password facoltativa sui file `.facilecards` (decisione 103): il contenuto
// (dati e foto, compresi nomi e numero di tessere) si cifra con AES-256-GCM;
// la chiave si ricava dalla password con PBKDF2-HMAC-SHA256. Sale, nonce e
// numero di ripetizioni stanno nell'intestazione in chiaro, così un file
// protetto si riconosce senza password. Nessuna chiave dentro l'app.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'archive_format.dart';

/// Ripetizioni di PBKDF2: circa un secondo su un telefono medio. Il valore
/// viaggia nel file, quindi si può alzare senza rompere i file vecchi.
const kdfIterations = 200000;
const minPasswordLength = 8;

/// Limiti per i parametri letti da un file ricevuto (un valore enorme
/// bloccherebbe il telefono).
const _minIterations = 10000;
const _maxIterations = 5000000;

const _cipherName = 'AES-256-GCM';
const _kdfName = 'PBKDF2-HMAC-SHA256';

/// Password sbagliata (o contenuto manomesso: con AES-GCM non si distingue).
class WrongPasswordException implements Exception {
  const WrongPasswordException();
}

/// La password va bene per proteggere un file? Null se sì, altrimenti il
/// motivo (videata 33).
String? passwordProblem(String password, String repeat) {
  if (password.length < minPasswordLength) {
    return 'Almeno $minPasswordLength caratteri.';
  }
  if (password != repeat) return 'Le due password non sono uguali.';
  return null;
}

Future<SecretKey> _deriveKey(String password, List<int> salt, int iterations) =>
    Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256)
        .deriveKeyFromPassword(password: password, nonce: salt);

List<int> _random(int n) {
  final r = Random.secure();
  return List<int>.generate(n, (_) => r.nextInt(256));
}

/// Cifra il contenuto. Restituisce i parametri da mettere nell'intestazione
/// e i byte cifrati (testo cifrato seguito dai 16 byte di autenticazione).
Future<({Map<String, Object?> params, Uint8List data})> encryptContent(
    Uint8List plain, String password,
    {int iterations = kdfIterations}) async {
  final salt = _random(16);
  final nonce = _random(12);
  final key = await _deriveKey(password, salt, iterations);
  final box =
      await AesGcm.with256bits().encrypt(plain, secretKey: key, nonce: nonce);
  final out = BytesBuilder(copy: false)
    ..add(box.cipherText)
    ..add(box.mac.bytes);
  return (
    params: {
      'cipher': _cipherName,
      'kdf': _kdfName,
      'iterations': iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
    },
    data: out.takeBytes(),
  );
}

/// Decifra il contenuto con i parametri dell'intestazione. Lancia
/// [WrongPasswordException] se la password non è quella giusta, e
/// [TransferException] se i parametri non sono validi.
Future<Uint8List> decryptContent(
    Uint8List data, Map<String, Object?> params, String password) async {
  final iterations = params['iterations'];
  final List<int> salt;
  final List<int> nonce;
  try {
    salt = base64Decode(params['salt'] as String);
    nonce = base64Decode(params['nonce'] as String);
  } catch (_) {
    throw const TransferException('Il file protetto è rovinato.');
  }
  if (params['cipher'] != _cipherName ||
      params['kdf'] != _kdfName ||
      iterations is! int ||
      iterations < _minIterations ||
      iterations > _maxIterations ||
      salt.length < 8 ||
      nonce.length != 12 ||
      data.length < 16) {
    throw const TransferException('Il file protetto è rovinato.');
  }
  final key = await _deriveKey(password, salt, iterations);
  final box = SecretBox(
    data.sublist(0, data.length - 16),
    nonce: nonce,
    mac: Mac(data.sublist(data.length - 16)),
  );
  try {
    return Uint8List.fromList(
        await AesGcm.with256bits().decrypt(box, secretKey: key));
  } on SecretBoxAuthenticationError {
    throw const WrongPasswordException();
  }
}
