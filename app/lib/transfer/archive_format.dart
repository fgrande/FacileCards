// Formato dei file `.facilecards` (analisi, sezione 5.2; decisioni 19, 102,
// 103). Lo stesso formato serve per "Esporta tutto", per una sezione e per
// una singola tessera.
//
// Il file è un archivio zip con due voci:
// - `header.json`: intestazione sempre in chiaro (formato, versione, tipo,
//   data di creazione, se è cifrato e con quali parametri);
// - `content.zip` (o `content.bin` se cifrato): il contenuto, a sua volta uno
//   zip con `data.json` (sezioni e tessere) e le foto in `photos/`.
//
// All'importazione il file è contenuto non fidato: ogni campo si controlla e
// ci sono limiti di dimensione e di numero (vedi [decodeContent]).

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../l10n/l10n.dart';

const archiveFormatName = 'facilecards';
const archiveFormatVersion = 1;
const archiveExtension = '.facilecards';

/// Limiti per i file ricevuti.
const maxArchiveBytes = 300 * 1024 * 1024;
const maxArchiveCards = 2000;
const maxArchiveSections = 500;
const maxPhotoBytesInArchive = 5 * 1024 * 1024;

enum ArchiveKind { all, section, card }

/// Errore di lettura: file non nostro, rovinato o con dati non validi.
/// Cosa non va in un file o in un'importazione. Il testo si ricava solo
/// quando si mostra, nella lingua dell'app: il file si legge in un isolate,
/// dove la lingua scelta non è nota.
enum TransferProblem {
  notFacileCards,
  notFacileCardsOrDamaged,
  badVersion,
  newerVersion,
  badHeader,
  tooBig,
  incomplete,
  contentDamaged,
  dataDamaged,
  badData,
  tooManyCards,
  badSection,
  repeatedSection,
  badCard,
  repeatedCard,
  cardWithoutSection,
  badPhoto,
  photoTooBig,
  badId,
  badValue,
  missingValue,
  valueTooLong,
  badDate,
  protectedDamaged,
  sectionNameTaken,
}

class TransferException implements Exception {
  const TransferException(this.problem);
  final TransferProblem problem;

  String get message => switch (problem) {
        TransferProblem.notFacileCards => tr.transferNotFacileCards,
        TransferProblem.notFacileCardsOrDamaged => tr.transferNotFacileCardsOrDamaged,
        TransferProblem.badVersion => tr.transferBadVersion,
        TransferProblem.newerVersion => tr.transferNewerVersion,
        TransferProblem.badHeader => tr.transferBadHeader,
        TransferProblem.tooBig => tr.transferTooBig,
        TransferProblem.incomplete => tr.transferIncomplete,
        TransferProblem.contentDamaged => tr.transferContentDamaged,
        TransferProblem.dataDamaged => tr.transferDataDamaged,
        TransferProblem.badData => tr.transferBadData,
        TransferProblem.tooManyCards => tr.transferTooManyCards,
        TransferProblem.badSection => tr.transferBadSection,
        TransferProblem.repeatedSection => tr.transferRepeatedSection,
        TransferProblem.badCard => tr.transferBadCard,
        TransferProblem.repeatedCard => tr.transferRepeatedCard,
        TransferProblem.cardWithoutSection => tr.transferCardWithoutSection,
        TransferProblem.badPhoto => tr.transferBadPhoto,
        TransferProblem.photoTooBig => tr.transferPhotoTooBig,
        TransferProblem.badId => tr.transferBadId,
        TransferProblem.badValue => tr.transferBadValue,
        TransferProblem.missingValue => tr.transferMissingValue,
        TransferProblem.valueTooLong => tr.transferValueTooLong,
        TransferProblem.badDate => tr.transferBadDate,
        TransferProblem.protectedDamaged => tr.transferProtectedDamaged,
        TransferProblem.sectionNameTaken => tr.transferSectionNameTaken,
      };

  @override
  String toString() => 'TransferException: $problem';
}

class ArchiveHeader {
  const ArchiveHeader({
    required this.kind,
    required this.createdAt,
    this.version = archiveFormatVersion,
    this.encryption,
  });

  final int version;
  final ArchiveKind kind;
  final DateTime createdAt;

  /// Parametri della cifratura (decisione 103); null se il file è in chiaro.
  final Map<String, Object?>? encryption;

  bool get encrypted => encryption != null;

  Map<String, Object?> toJson() => {
        'format': archiveFormatName,
        'version': version,
        'kind': kind.name,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'encrypted': encrypted,
        if (encryption != null) 'encryption': encryption,
      };

  static ArchiveHeader fromJson(Object? json) {
    if (json is! Map || json['format'] != archiveFormatName) {
      throw const TransferException(TransferProblem.notFacileCards);
    }
    final version = json['version'];
    if (version is! int || version < 1) {
      throw const TransferException(TransferProblem.badVersion);
    }
    if (version > archiveFormatVersion) {
      throw const TransferException(TransferProblem.newerVersion);
    }
    final kind = ArchiveKind.values.where((k) => k.name == json['kind']);
    final created = DateTime.tryParse('${json['createdAt']}');
    if (kind.isEmpty || created == null) {
      throw const TransferException(TransferProblem.badHeader);
    }
    final enc = json['encryption'];
    return ArchiveHeader(
      version: version,
      kind: kind.first,
      createdAt: created.toLocal(),
      encryption: json['encrypted'] == true && enc is Map
          ? enc.cast<String, Object?>()
          : null,
    );
  }
}

class ArchiveSection {
  const ArchiveSection({
    required this.id,
    required this.name,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final bool isDefault;

  Map<String, Object?> toJson() =>
      {'id': id, 'name': name, if (isDefault) 'isDefault': true};
}

class ArchiveCard {
  const ArchiveCard({
    required this.id,
    required this.typeId,
    required this.name,
    required this.code,
    required this.codeFormat,
    required this.sectionId,
    this.holder,
    this.notes,
    this.expiresOn,
    this.createdAt,
    this.lastUsedAt,
    this.favorite = false,
    this.photos = const {},
  });

  final String id;
  final String typeId;
  final String name;
  final String code;
  final String codeFormat;
  final String sectionId;
  final String? holder;
  final String? notes;
  final DateTime? expiresOn;

  /// Solo nel backup completo: dati personali che tornano al proprietario.
  final DateTime? createdAt;
  final DateTime? lastUsedAt;
  final bool favorite;

  /// Lato ('front', 'back') → percorso della foto nell'archivio.
  final Map<String, String> photos;

  Map<String, Object?> toJson() => {
        'id': id,
        'typeId': typeId,
        'name': name,
        'code': code,
        'format': codeFormat,
        'sectionId': sectionId,
        if (holder != null) 'holder': holder,
        if (notes != null) 'notes': notes,
        if (expiresOn != null) 'expiresOn': _date(expiresOn!),
        if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
        if (lastUsedAt != null)
          'lastUsedAt': lastUsedAt!.toUtc().toIso8601String(),
        if (favorite) 'favorite': true,
        if (photos.isNotEmpty) 'photos': photos,
      };

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class ArchiveContent {
  const ArchiveContent({
    this.owner,
    required this.sections,
    required this.cards,
    this.photos = const {},
  });

  /// Nome di chi ha creato il file ("Archivio di Fabio Grande").
  final String? owner;
  final List<ArchiveSection> sections;
  final List<ArchiveCard> cards;

  /// Percorso nell'archivio → byte della foto.
  final Map<String, Uint8List> photos;

  int get photoBytes => photos.values.fold(0, (sum, b) => sum + b.length);
}

/// Il contenuto (dati e foto) come zip, prima dell'eventuale cifratura.
Uint8List encodeContent(ArchiveContent content) {
  final archive = Archive();
  final data = utf8.encode(jsonEncode({
    if (content.owner != null) 'owner': content.owner,
    'sections': [for (final s in content.sections) s.toJson()],
    'cards': [for (final c in content.cards) c.toJson()],
  }));
  archive.add(ArchiveFile.bytes('data.json', data));
  for (final e in content.photos.entries) {
    // Le foto sono già JPEG compressi: si archiviano così come sono.
    archive.add(ArchiveFile.bytes(e.key, e.value)
      ..compression = CompressionType.none);
  }
  return ZipEncoder().encodeBytes(archive);
}

/// Il file completo: intestazione in chiaro più il contenuto (già cifrato,
/// se l'intestazione lo dice).
Uint8List encodeArchive(ArchiveHeader header, Uint8List contentBytes) {
  final archive = Archive()
    ..add(ArchiveFile.bytes(
        'header.json', utf8.encode(jsonEncode(header.toJson()))))
    ..add(ArchiveFile.bytes(
        header.encrypted ? 'content.bin' : 'content.zip', contentBytes)
      ..compression = CompressionType.none);
  return ZipEncoder().encodeBytes(archive);
}

/// Legge intestazione e contenuto (ancora da decifrare, se cifrato).
({ArchiveHeader header, Uint8List content}) decodeArchive(Uint8List bytes) {
  if (bytes.length > maxArchiveBytes) {
    throw const TransferException(TransferProblem.tooBig);
  }
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes, verify: true);
  } catch (_) {
    throw const TransferException(TransferProblem.notFacileCardsOrDamaged);
  }
  final headerFile = archive.find('header.json');
  if (headerFile == null) {
    throw const TransferException(TransferProblem.notFacileCards);
  }
  final ArchiveHeader header;
  try {
    header = ArchiveHeader.fromJson(jsonDecode(utf8.decode(headerFile.content)));
  } on TransferException {
    rethrow;
  } catch (_) {
    throw const TransferException(TransferProblem.badHeader);
  }
  final content =
      archive.find(header.encrypted ? 'content.bin' : 'content.zip');
  if (content == null) {
    throw const TransferException(TransferProblem.incomplete);
  }
  return (header: header, content: content.content);
}

/// Legge e controlla il contenuto (già decifrato).
ArchiveContent decodeContent(Uint8List bytes) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes, verify: true);
  } catch (_) {
    throw const TransferException(TransferProblem.contentDamaged);
  }
  final dataFile = archive.find('data.json');
  if (dataFile == null) throw const TransferException(TransferProblem.incomplete);
  final Object? json;
  try {
    json = jsonDecode(utf8.decode(dataFile.content));
  } catch (_) {
    throw const TransferException(TransferProblem.dataDamaged);
  }
  if (json is! Map) throw const TransferException(TransferProblem.badData);

  final rawSections = json['sections'];
  final rawCards = json['cards'];
  if (rawSections is! List || rawCards is! List) {
    throw const TransferException(TransferProblem.badData);
  }
  if (rawSections.length > maxArchiveSections ||
      rawCards.length > maxArchiveCards) {
    throw const TransferException(TransferProblem.tooManyCards);
  }

  final sections = <ArchiveSection>[];
  final sectionIds = <String>{};
  for (final s in rawSections) {
    if (s is! Map) throw const TransferException(TransferProblem.badSection);
    final id = _id(s['id']);
    final name = _text(s['name'], 100, required: true)!;
    if (!sectionIds.add(id)) {
      throw const TransferException(TransferProblem.repeatedSection);
    }
    sections.add(
        ArchiveSection(id: id, name: name, isDefault: s['isDefault'] == true));
  }

  final photos = <String, Uint8List>{};
  final cards = <ArchiveCard>[];
  final cardIds = <String>{};
  for (final c in rawCards) {
    if (c is! Map) throw const TransferException(TransferProblem.badCard);
    final id = _id(c['id']);
    if (!cardIds.add(id)) {
      throw const TransferException(TransferProblem.repeatedCard);
    }
    final sectionId = _id(c['sectionId']);
    if (!sectionIds.contains(sectionId)) {
      throw const TransferException(TransferProblem.cardWithoutSection);
    }
    final cardPhotos = <String, String>{};
    final rawPhotos = c['photos'];
    if (rawPhotos is Map) {
      for (final e in rawPhotos.entries) {
        final side = e.key;
        final path = e.value;
        if ((side != 'front' && side != 'back') ||
            path is! String ||
            !path.startsWith('photos/') ||
            path.contains('..')) {
          throw const TransferException(TransferProblem.badPhoto);
        }
        final file = archive.find(path);
        if (file == null) continue; // foto mancante: si importa senza
        final bytes = file.content;
        if (bytes.length > maxPhotoBytesInArchive) {
          throw const TransferException(TransferProblem.photoTooBig);
        }
        photos[path] = bytes;
        cardPhotos[side as String] = path;
      }
    }
    cards.add(ArchiveCard(
      id: id,
      typeId: _text(c['typeId'], 64, required: true)!,
      name: _text(c['name'], 100, required: true)!,
      code: _text(c['code'], 2000, required: true, trim: false)!,
      codeFormat: _text(c['format'], 32, required: true)!,
      sectionId: sectionId,
      holder: _text(c['holder'], 100),
      notes: _text(c['notes'], 2000, trim: false),
      expiresOn: _dateOnly(c['expiresOn']),
      createdAt: _dateTime(c['createdAt']),
      lastUsedAt: _dateTime(c['lastUsedAt']),
      favorite: c['favorite'] == true,
      photos: cardPhotos,
    ));
  }
  final owner = _text(json['owner'], 100);
  return ArchiveContent(
      owner: owner, sections: sections, cards: cards, photos: photos);
}

final _idPattern = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

String _id(Object? v) {
  if (v is! String || !_idPattern.hasMatch(v)) {
    throw const TransferException(TransferProblem.badId);
  }
  return v;
}

String? _text(Object? v, int max, {bool required = false, bool trim = true}) {
  if (v == null && !required) return null;
  if (v is! String) throw const TransferException(TransferProblem.badValue);
  final t = trim ? v.trim() : v;
  if (t.isEmpty) {
    if (required) throw const TransferException(TransferProblem.missingValue);
    return null;
  }
  if (t.length > max) throw const TransferException(TransferProblem.valueTooLong);
  return t;
}

DateTime? _dateTime(Object? v) {
  if (v == null) return null;
  final d = v is String ? DateTime.tryParse(v) : null;
  if (d == null) throw const TransferException(TransferProblem.badDate);
  return d.toLocal();
}

DateTime? _dateOnly(Object? v) {
  if (v == null) return null;
  final d = v is String ? DateTime.tryParse(v) : null;
  if (d == null) throw const TransferException(TransferProblem.badDate);
  return DateTime(d.year, d.month, d.day);
}
