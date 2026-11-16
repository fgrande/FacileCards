// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SectionsTable extends Sections with TableInfo<$SectionsTable, Section> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isDefault, hidden];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Section> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Section map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Section(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
    );
  }

  @override
  $SectionsTable createAlias(String alias) {
    return $SectionsTable(attachedDatabase, alias);
  }
}

class Section extends DataClass implements Insertable<Section> {
  final String id;
  final String name;
  final bool isDefault;
  final bool hidden;
  const Section({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.hidden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_default'] = Variable<bool>(isDefault);
    map['hidden'] = Variable<bool>(hidden);
    return map;
  }

  SectionsCompanion toCompanion(bool nullToAbsent) {
    return SectionsCompanion(
      id: Value(id),
      name: Value(name),
      isDefault: Value(isDefault),
      hidden: Value(hidden),
    );
  }

  factory Section.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Section(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      hidden: serializer.fromJson<bool>(json['hidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isDefault': serializer.toJson<bool>(isDefault),
      'hidden': serializer.toJson<bool>(hidden),
    };
  }

  Section copyWith({String? id, String? name, bool? isDefault, bool? hidden}) =>
      Section(
        id: id ?? this.id,
        name: name ?? this.name,
        isDefault: isDefault ?? this.isDefault,
        hidden: hidden ?? this.hidden,
      );
  Section copyWithCompanion(SectionsCompanion data) {
    return Section(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Section(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('hidden: $hidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isDefault, hidden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Section &&
          other.id == this.id &&
          other.name == this.name &&
          other.isDefault == this.isDefault &&
          other.hidden == this.hidden);
}

class SectionsCompanion extends UpdateCompanion<Section> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isDefault;
  final Value<bool> hidden;
  final Value<int> rowid;
  const SectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.hidden = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SectionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isDefault = const Value.absent(),
    this.hidden = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Section> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isDefault,
    Expression<bool>? hidden,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isDefault != null) 'is_default': isDefault,
      if (hidden != null) 'hidden': hidden,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isDefault,
    Value<bool>? hidden,
    Value<int>? rowid,
  }) {
    return SectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      hidden: hidden ?? this.hidden,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('hidden: $hidden, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardTypesTable extends CardTypes
    with TableInfo<$CardTypesTable, CardType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoMeta = const VerificationMeta('logo');
  @override
  late final GeneratedColumn<String> logo = GeneratedColumn<String>(
    'logo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeFormatMeta = const VerificationMeta(
    'codeFormat',
  );
  @override
  late final GeneratedColumn<String> codeFormat = GeneratedColumn<String>(
    'code_format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('altro'),
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isGenericMeta = const VerificationMeta(
    'isGeneric',
  );
  @override
  late final GeneratedColumn<bool> isGeneric = GeneratedColumn<bool>(
    'is_generic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_generic" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _retiredMeta = const VerificationMeta(
    'retired',
  );
  @override
  late final GeneratedColumn<bool> retired = GeneratedColumn<bool>(
    'retired',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("retired" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _retiredOnMeta = const VerificationMeta(
    'retiredOn',
  );
  @override
  late final GeneratedColumn<DateTime> retiredOn = GeneratedColumn<DateTime>(
    'retired_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replacedByMeta = const VerificationMeta(
    'replacedBy',
  );
  @override
  late final GeneratedColumn<String> replacedBy = GeneratedColumn<String>(
    'replaced_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replacementNeedsNewCodeMeta =
      const VerificationMeta('replacementNeedsNewCode');
  @override
  late final GeneratedColumn<bool> replacementNeedsNewCode =
      GeneratedColumn<bool>(
        'replacement_needs_new_code',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("replacement_needs_new_code" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    logo,
    color,
    codeFormat,
    category,
    country,
    isGeneric,
    retired,
    retiredOn,
    replacedBy,
    replacementNeedsNewCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('logo')) {
      context.handle(
        _logoMeta,
        logo.isAcceptableOrUnknown(data['logo']!, _logoMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('code_format')) {
      context.handle(
        _codeFormatMeta,
        codeFormat.isAcceptableOrUnknown(data['code_format']!, _codeFormatMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('is_generic')) {
      context.handle(
        _isGenericMeta,
        isGeneric.isAcceptableOrUnknown(data['is_generic']!, _isGenericMeta),
      );
    }
    if (data.containsKey('retired')) {
      context.handle(
        _retiredMeta,
        retired.isAcceptableOrUnknown(data['retired']!, _retiredMeta),
      );
    }
    if (data.containsKey('retired_on')) {
      context.handle(
        _retiredOnMeta,
        retiredOn.isAcceptableOrUnknown(data['retired_on']!, _retiredOnMeta),
      );
    }
    if (data.containsKey('replaced_by')) {
      context.handle(
        _replacedByMeta,
        replacedBy.isAcceptableOrUnknown(data['replaced_by']!, _replacedByMeta),
      );
    }
    if (data.containsKey('replacement_needs_new_code')) {
      context.handle(
        _replacementNeedsNewCodeMeta,
        replacementNeedsNewCode.isAcceptableOrUnknown(
          data['replacement_needs_new_code']!,
          _replacementNeedsNewCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      logo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      codeFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_format'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      isGeneric: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_generic'],
      )!,
      retired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}retired'],
      )!,
      retiredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}retired_on'],
      ),
      replacedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replaced_by'],
      ),
      replacementNeedsNewCode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}replacement_needs_new_code'],
      )!,
    );
  }

  @override
  $CardTypesTable createAlias(String alias) {
    return $CardTypesTable(attachedDatabase, alias);
  }
}

class CardType extends DataClass implements Insertable<CardType> {
  final String id;
  final String name;
  final String? logo;
  final int? color;
  final String? codeFormat;
  final String category;
  final String? country;
  final bool isGeneric;
  final bool retired;
  final DateTime? retiredOn;
  final String? replacedBy;
  final bool replacementNeedsNewCode;
  const CardType({
    required this.id,
    required this.name,
    this.logo,
    this.color,
    this.codeFormat,
    required this.category,
    this.country,
    required this.isGeneric,
    required this.retired,
    this.retiredOn,
    this.replacedBy,
    required this.replacementNeedsNewCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || logo != null) {
      map['logo'] = Variable<String>(logo);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    if (!nullToAbsent || codeFormat != null) {
      map['code_format'] = Variable<String>(codeFormat);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    map['is_generic'] = Variable<bool>(isGeneric);
    map['retired'] = Variable<bool>(retired);
    if (!nullToAbsent || retiredOn != null) {
      map['retired_on'] = Variable<DateTime>(retiredOn);
    }
    if (!nullToAbsent || replacedBy != null) {
      map['replaced_by'] = Variable<String>(replacedBy);
    }
    map['replacement_needs_new_code'] = Variable<bool>(replacementNeedsNewCode);
    return map;
  }

  CardTypesCompanion toCompanion(bool nullToAbsent) {
    return CardTypesCompanion(
      id: Value(id),
      name: Value(name),
      logo: logo == null && nullToAbsent ? const Value.absent() : Value(logo),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      codeFormat: codeFormat == null && nullToAbsent
          ? const Value.absent()
          : Value(codeFormat),
      category: Value(category),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      isGeneric: Value(isGeneric),
      retired: Value(retired),
      retiredOn: retiredOn == null && nullToAbsent
          ? const Value.absent()
          : Value(retiredOn),
      replacedBy: replacedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(replacedBy),
      replacementNeedsNewCode: Value(replacementNeedsNewCode),
    );
  }

  factory CardType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardType(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      logo: serializer.fromJson<String?>(json['logo']),
      color: serializer.fromJson<int?>(json['color']),
      codeFormat: serializer.fromJson<String?>(json['codeFormat']),
      category: serializer.fromJson<String>(json['category']),
      country: serializer.fromJson<String?>(json['country']),
      isGeneric: serializer.fromJson<bool>(json['isGeneric']),
      retired: serializer.fromJson<bool>(json['retired']),
      retiredOn: serializer.fromJson<DateTime?>(json['retiredOn']),
      replacedBy: serializer.fromJson<String?>(json['replacedBy']),
      replacementNeedsNewCode: serializer.fromJson<bool>(
        json['replacementNeedsNewCode'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'logo': serializer.toJson<String?>(logo),
      'color': serializer.toJson<int?>(color),
      'codeFormat': serializer.toJson<String?>(codeFormat),
      'category': serializer.toJson<String>(category),
      'country': serializer.toJson<String?>(country),
      'isGeneric': serializer.toJson<bool>(isGeneric),
      'retired': serializer.toJson<bool>(retired),
      'retiredOn': serializer.toJson<DateTime?>(retiredOn),
      'replacedBy': serializer.toJson<String?>(replacedBy),
      'replacementNeedsNewCode': serializer.toJson<bool>(
        replacementNeedsNewCode,
      ),
    };
  }

  CardType copyWith({
    String? id,
    String? name,
    Value<String?> logo = const Value.absent(),
    Value<int?> color = const Value.absent(),
    Value<String?> codeFormat = const Value.absent(),
    String? category,
    Value<String?> country = const Value.absent(),
    bool? isGeneric,
    bool? retired,
    Value<DateTime?> retiredOn = const Value.absent(),
    Value<String?> replacedBy = const Value.absent(),
    bool? replacementNeedsNewCode,
  }) => CardType(
    id: id ?? this.id,
    name: name ?? this.name,
    logo: logo.present ? logo.value : this.logo,
    color: color.present ? color.value : this.color,
    codeFormat: codeFormat.present ? codeFormat.value : this.codeFormat,
    category: category ?? this.category,
    country: country.present ? country.value : this.country,
    isGeneric: isGeneric ?? this.isGeneric,
    retired: retired ?? this.retired,
    retiredOn: retiredOn.present ? retiredOn.value : this.retiredOn,
    replacedBy: replacedBy.present ? replacedBy.value : this.replacedBy,
    replacementNeedsNewCode:
        replacementNeedsNewCode ?? this.replacementNeedsNewCode,
  );
  CardType copyWithCompanion(CardTypesCompanion data) {
    return CardType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      logo: data.logo.present ? data.logo.value : this.logo,
      color: data.color.present ? data.color.value : this.color,
      codeFormat: data.codeFormat.present
          ? data.codeFormat.value
          : this.codeFormat,
      category: data.category.present ? data.category.value : this.category,
      country: data.country.present ? data.country.value : this.country,
      isGeneric: data.isGeneric.present ? data.isGeneric.value : this.isGeneric,
      retired: data.retired.present ? data.retired.value : this.retired,
      retiredOn: data.retiredOn.present ? data.retiredOn.value : this.retiredOn,
      replacedBy: data.replacedBy.present
          ? data.replacedBy.value
          : this.replacedBy,
      replacementNeedsNewCode: data.replacementNeedsNewCode.present
          ? data.replacementNeedsNewCode.value
          : this.replacementNeedsNewCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardType(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logo: $logo, ')
          ..write('color: $color, ')
          ..write('codeFormat: $codeFormat, ')
          ..write('category: $category, ')
          ..write('country: $country, ')
          ..write('isGeneric: $isGeneric, ')
          ..write('retired: $retired, ')
          ..write('retiredOn: $retiredOn, ')
          ..write('replacedBy: $replacedBy, ')
          ..write('replacementNeedsNewCode: $replacementNeedsNewCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    logo,
    color,
    codeFormat,
    category,
    country,
    isGeneric,
    retired,
    retiredOn,
    replacedBy,
    replacementNeedsNewCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardType &&
          other.id == this.id &&
          other.name == this.name &&
          other.logo == this.logo &&
          other.color == this.color &&
          other.codeFormat == this.codeFormat &&
          other.category == this.category &&
          other.country == this.country &&
          other.isGeneric == this.isGeneric &&
          other.retired == this.retired &&
          other.retiredOn == this.retiredOn &&
          other.replacedBy == this.replacedBy &&
          other.replacementNeedsNewCode == this.replacementNeedsNewCode);
}

class CardTypesCompanion extends UpdateCompanion<CardType> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> logo;
  final Value<int?> color;
  final Value<String?> codeFormat;
  final Value<String> category;
  final Value<String?> country;
  final Value<bool> isGeneric;
  final Value<bool> retired;
  final Value<DateTime?> retiredOn;
  final Value<String?> replacedBy;
  final Value<bool> replacementNeedsNewCode;
  final Value<int> rowid;
  const CardTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.logo = const Value.absent(),
    this.color = const Value.absent(),
    this.codeFormat = const Value.absent(),
    this.category = const Value.absent(),
    this.country = const Value.absent(),
    this.isGeneric = const Value.absent(),
    this.retired = const Value.absent(),
    this.retiredOn = const Value.absent(),
    this.replacedBy = const Value.absent(),
    this.replacementNeedsNewCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardTypesCompanion.insert({
    required String id,
    required String name,
    this.logo = const Value.absent(),
    this.color = const Value.absent(),
    this.codeFormat = const Value.absent(),
    this.category = const Value.absent(),
    this.country = const Value.absent(),
    this.isGeneric = const Value.absent(),
    this.retired = const Value.absent(),
    this.retiredOn = const Value.absent(),
    this.replacedBy = const Value.absent(),
    this.replacementNeedsNewCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CardType> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? logo,
    Expression<int>? color,
    Expression<String>? codeFormat,
    Expression<String>? category,
    Expression<String>? country,
    Expression<bool>? isGeneric,
    Expression<bool>? retired,
    Expression<DateTime>? retiredOn,
    Expression<String>? replacedBy,
    Expression<bool>? replacementNeedsNewCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (logo != null) 'logo': logo,
      if (color != null) 'color': color,
      if (codeFormat != null) 'code_format': codeFormat,
      if (category != null) 'category': category,
      if (country != null) 'country': country,
      if (isGeneric != null) 'is_generic': isGeneric,
      if (retired != null) 'retired': retired,
      if (retiredOn != null) 'retired_on': retiredOn,
      if (replacedBy != null) 'replaced_by': replacedBy,
      if (replacementNeedsNewCode != null)
        'replacement_needs_new_code': replacementNeedsNewCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardTypesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? logo,
    Value<int?>? color,
    Value<String?>? codeFormat,
    Value<String>? category,
    Value<String?>? country,
    Value<bool>? isGeneric,
    Value<bool>? retired,
    Value<DateTime?>? retiredOn,
    Value<String?>? replacedBy,
    Value<bool>? replacementNeedsNewCode,
    Value<int>? rowid,
  }) {
    return CardTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      color: color ?? this.color,
      codeFormat: codeFormat ?? this.codeFormat,
      category: category ?? this.category,
      country: country ?? this.country,
      isGeneric: isGeneric ?? this.isGeneric,
      retired: retired ?? this.retired,
      retiredOn: retiredOn ?? this.retiredOn,
      replacedBy: replacedBy ?? this.replacedBy,
      replacementNeedsNewCode:
          replacementNeedsNewCode ?? this.replacementNeedsNewCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (logo.present) {
      map['logo'] = Variable<String>(logo.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (codeFormat.present) {
      map['code_format'] = Variable<String>(codeFormat.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (isGeneric.present) {
      map['is_generic'] = Variable<bool>(isGeneric.value);
    }
    if (retired.present) {
      map['retired'] = Variable<bool>(retired.value);
    }
    if (retiredOn.present) {
      map['retired_on'] = Variable<DateTime>(retiredOn.value);
    }
    if (replacedBy.present) {
      map['replaced_by'] = Variable<String>(replacedBy.value);
    }
    if (replacementNeedsNewCode.present) {
      map['replacement_needs_new_code'] = Variable<bool>(
        replacementNeedsNewCode.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logo: $logo, ')
          ..write('color: $color, ')
          ..write('codeFormat: $codeFormat, ')
          ..write('category: $category, ')
          ..write('country: $country, ')
          ..write('isGeneric: $isGeneric, ')
          ..write('retired: $retired, ')
          ..write('retiredOn: $retiredOn, ')
          ..write('replacedBy: $replacedBy, ')
          ..write('replacementNeedsNewCode: $replacementNeedsNewCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardsTable extends Cards with TableInfo<$CardsTable, Card> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
  );
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<String> typeId = GeneratedColumn<String>(
    'type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_types (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeFormatMeta = const VerificationMeta(
    'codeFormat',
  );
  @override
  late final GeneratedColumn<String> codeFormat = GeneratedColumn<String>(
    'code_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _holderMeta = const VerificationMeta('holder');
  @override
  late final GeneratedColumn<String> holder = GeneratedColumn<String>(
    'holder',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresOnMeta = const VerificationMeta(
    'expiresOn',
  );
  @override
  late final GeneratedColumn<DateTime> expiresOn = GeneratedColumn<DateTime>(
    'expires_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sections (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    typeId,
    name,
    code,
    codeFormat,
    notes,
    holder,
    expiresOn,
    sectionId,
    createdAt,
    lastUsedAt,
    favorite,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Card> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type_id')) {
      context.handle(
        _typeIdMeta,
        typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_typeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('code_format')) {
      context.handle(
        _codeFormatMeta,
        codeFormat.isAcceptableOrUnknown(data['code_format']!, _codeFormatMeta),
      );
    } else if (isInserting) {
      context.missing(_codeFormatMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('holder')) {
      context.handle(
        _holderMeta,
        holder.isAcceptableOrUnknown(data['holder']!, _holderMeta),
      );
    }
    if (data.containsKey('expires_on')) {
      context.handle(
        _expiresOnMeta,
        expiresOn.isAcceptableOrUnknown(data['expires_on']!, _expiresOnMeta),
      );
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Card map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Card(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      typeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      codeFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_format'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      holder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}holder'],
      ),
      expiresOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_on'],
      ),
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class Card extends DataClass implements Insertable<Card> {
  final String id;
  final String typeId;
  final String name;
  final String code;
  final String codeFormat;
  final String? notes;
  final String? holder;
  final DateTime? expiresOn;
  final String sectionId;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final bool favorite;
  final DateTime? deletedAt;
  const Card({
    required this.id,
    required this.typeId,
    required this.name,
    required this.code,
    required this.codeFormat,
    this.notes,
    this.holder,
    this.expiresOn,
    required this.sectionId,
    required this.createdAt,
    this.lastUsedAt,
    required this.favorite,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type_id'] = Variable<String>(typeId);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    map['code_format'] = Variable<String>(codeFormat);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || holder != null) {
      map['holder'] = Variable<String>(holder);
    }
    if (!nullToAbsent || expiresOn != null) {
      map['expires_on'] = Variable<DateTime>(expiresOn);
    }
    map['section_id'] = Variable<String>(sectionId);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    map['favorite'] = Variable<bool>(favorite);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      typeId: Value(typeId),
      name: Value(name),
      code: Value(code),
      codeFormat: Value(codeFormat),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      holder: holder == null && nullToAbsent
          ? const Value.absent()
          : Value(holder),
      expiresOn: expiresOn == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresOn),
      sectionId: Value(sectionId),
      createdAt: Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
      favorite: Value(favorite),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Card.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Card(
      id: serializer.fromJson<String>(json['id']),
      typeId: serializer.fromJson<String>(json['typeId']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      codeFormat: serializer.fromJson<String>(json['codeFormat']),
      notes: serializer.fromJson<String?>(json['notes']),
      holder: serializer.fromJson<String?>(json['holder']),
      expiresOn: serializer.fromJson<DateTime?>(json['expiresOn']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'typeId': serializer.toJson<String>(typeId),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'codeFormat': serializer.toJson<String>(codeFormat),
      'notes': serializer.toJson<String?>(notes),
      'holder': serializer.toJson<String?>(holder),
      'expiresOn': serializer.toJson<DateTime?>(expiresOn),
      'sectionId': serializer.toJson<String>(sectionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
      'favorite': serializer.toJson<bool>(favorite),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Card copyWith({
    String? id,
    String? typeId,
    String? name,
    String? code,
    String? codeFormat,
    Value<String?> notes = const Value.absent(),
    Value<String?> holder = const Value.absent(),
    Value<DateTime?> expiresOn = const Value.absent(),
    String? sectionId,
    DateTime? createdAt,
    Value<DateTime?> lastUsedAt = const Value.absent(),
    bool? favorite,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Card(
    id: id ?? this.id,
    typeId: typeId ?? this.typeId,
    name: name ?? this.name,
    code: code ?? this.code,
    codeFormat: codeFormat ?? this.codeFormat,
    notes: notes.present ? notes.value : this.notes,
    holder: holder.present ? holder.value : this.holder,
    expiresOn: expiresOn.present ? expiresOn.value : this.expiresOn,
    sectionId: sectionId ?? this.sectionId,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
    favorite: favorite ?? this.favorite,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Card copyWithCompanion(CardsCompanion data) {
    return Card(
      id: data.id.present ? data.id.value : this.id,
      typeId: data.typeId.present ? data.typeId.value : this.typeId,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      codeFormat: data.codeFormat.present
          ? data.codeFormat.value
          : this.codeFormat,
      notes: data.notes.present ? data.notes.value : this.notes,
      holder: data.holder.present ? data.holder.value : this.holder,
      expiresOn: data.expiresOn.present ? data.expiresOn.value : this.expiresOn,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Card(')
          ..write('id: $id, ')
          ..write('typeId: $typeId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('codeFormat: $codeFormat, ')
          ..write('notes: $notes, ')
          ..write('holder: $holder, ')
          ..write('expiresOn: $expiresOn, ')
          ..write('sectionId: $sectionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('favorite: $favorite, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    typeId,
    name,
    code,
    codeFormat,
    notes,
    holder,
    expiresOn,
    sectionId,
    createdAt,
    lastUsedAt,
    favorite,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Card &&
          other.id == this.id &&
          other.typeId == this.typeId &&
          other.name == this.name &&
          other.code == this.code &&
          other.codeFormat == this.codeFormat &&
          other.notes == this.notes &&
          other.holder == this.holder &&
          other.expiresOn == this.expiresOn &&
          other.sectionId == this.sectionId &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt &&
          other.favorite == this.favorite &&
          other.deletedAt == this.deletedAt);
}

class CardsCompanion extends UpdateCompanion<Card> {
  final Value<String> id;
  final Value<String> typeId;
  final Value<String> name;
  final Value<String> code;
  final Value<String> codeFormat;
  final Value<String?> notes;
  final Value<String?> holder;
  final Value<DateTime?> expiresOn;
  final Value<String> sectionId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUsedAt;
  final Value<bool> favorite;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.typeId = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.codeFormat = const Value.absent(),
    this.notes = const Value.absent(),
    this.holder = const Value.absent(),
    this.expiresOn = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.favorite = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    this.id = const Value.absent(),
    required String typeId,
    required String name,
    required String code,
    required String codeFormat,
    this.notes = const Value.absent(),
    this.holder = const Value.absent(),
    this.expiresOn = const Value.absent(),
    required String sectionId,
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.favorite = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : typeId = Value(typeId),
       name = Value(name),
       code = Value(code),
       codeFormat = Value(codeFormat),
       sectionId = Value(sectionId);
  static Insertable<Card> custom({
    Expression<String>? id,
    Expression<String>? typeId,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? codeFormat,
    Expression<String>? notes,
    Expression<String>? holder,
    Expression<DateTime>? expiresOn,
    Expression<String>? sectionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
    Expression<bool>? favorite,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typeId != null) 'type_id': typeId,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (codeFormat != null) 'code_format': codeFormat,
      if (notes != null) 'notes': notes,
      if (holder != null) 'holder': holder,
      if (expiresOn != null) 'expires_on': expiresOn,
      if (sectionId != null) 'section_id': sectionId,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (favorite != null) 'favorite': favorite,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith({
    Value<String>? id,
    Value<String>? typeId,
    Value<String>? name,
    Value<String>? code,
    Value<String>? codeFormat,
    Value<String?>? notes,
    Value<String?>? holder,
    Value<DateTime?>? expiresOn,
    Value<String>? sectionId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastUsedAt,
    Value<bool>? favorite,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      typeId: typeId ?? this.typeId,
      name: name ?? this.name,
      code: code ?? this.code,
      codeFormat: codeFormat ?? this.codeFormat,
      notes: notes ?? this.notes,
      holder: holder ?? this.holder,
      expiresOn: expiresOn ?? this.expiresOn,
      sectionId: sectionId ?? this.sectionId,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      favorite: favorite ?? this.favorite,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (typeId.present) {
      map['type_id'] = Variable<String>(typeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (codeFormat.present) {
      map['code_format'] = Variable<String>(codeFormat.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (holder.present) {
      map['holder'] = Variable<String>(holder.value);
    }
    if (expiresOn.present) {
      map['expires_on'] = Variable<DateTime>(expiresOn.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('typeId: $typeId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('codeFormat: $codeFormat, ')
          ..write('notes: $notes, ')
          ..write('holder: $holder, ')
          ..write('expiresOn: $expiresOn, ')
          ..write('sectionId: $sectionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('favorite: $favorite, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardImagesTable extends CardImages
    with TableInfo<$CardImagesTable, CardImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cards (id)',
    ),
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cardId, side, fileName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId, side};
  @override
  CardImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardImage(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
    );
  }

  @override
  $CardImagesTable createAlias(String alias) {
    return $CardImagesTable(attachedDatabase, alias);
  }
}

class CardImage extends DataClass implements Insertable<CardImage> {
  final String cardId;
  final String side;
  final String fileName;
  const CardImage({
    required this.cardId,
    required this.side,
    required this.fileName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['side'] = Variable<String>(side);
    map['file_name'] = Variable<String>(fileName);
    return map;
  }

  CardImagesCompanion toCompanion(bool nullToAbsent) {
    return CardImagesCompanion(
      cardId: Value(cardId),
      side: Value(side),
      fileName: Value(fileName),
    );
  }

  factory CardImage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardImage(
      cardId: serializer.fromJson<String>(json['cardId']),
      side: serializer.fromJson<String>(json['side']),
      fileName: serializer.fromJson<String>(json['fileName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'side': serializer.toJson<String>(side),
      'fileName': serializer.toJson<String>(fileName),
    };
  }

  CardImage copyWith({String? cardId, String? side, String? fileName}) =>
      CardImage(
        cardId: cardId ?? this.cardId,
        side: side ?? this.side,
        fileName: fileName ?? this.fileName,
      );
  CardImage copyWithCompanion(CardImagesCompanion data) {
    return CardImage(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      side: data.side.present ? data.side.value : this.side,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardImage(')
          ..write('cardId: $cardId, ')
          ..write('side: $side, ')
          ..write('fileName: $fileName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, side, fileName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardImage &&
          other.cardId == this.cardId &&
          other.side == this.side &&
          other.fileName == this.fileName);
}

class CardImagesCompanion extends UpdateCompanion<CardImage> {
  final Value<String> cardId;
  final Value<String> side;
  final Value<String> fileName;
  final Value<int> rowid;
  const CardImagesCompanion({
    this.cardId = const Value.absent(),
    this.side = const Value.absent(),
    this.fileName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardImagesCompanion.insert({
    required String cardId,
    required String side,
    required String fileName,
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       side = Value(side),
       fileName = Value(fileName);
  static Insertable<CardImage> custom({
    Expression<String>? cardId,
    Expression<String>? side,
    Expression<String>? fileName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (side != null) 'side': side,
      if (fileName != null) 'file_name': fileName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardImagesCompanion copyWith({
    Value<String>? cardId,
    Value<String>? side,
    Value<String>? fileName,
    Value<int>? rowid,
  }) {
    return CardImagesCompanion(
      cardId: cardId ?? this.cardId,
      side: side ?? this.side,
      fileName: fileName ?? this.fileName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardImagesCompanion(')
          ..write('cardId: $cardId, ')
          ..write('side: $side, ')
          ..write('fileName: $fileName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SectionsTable sections = $SectionsTable(this);
  late final $CardTypesTable cardTypes = $CardTypesTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $CardImagesTable cardImages = $CardImagesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sections,
    cardTypes,
    cards,
    cardImages,
    settings,
  ];
}

typedef $$SectionsTableCreateCompanionBuilder = SectionsCompanion Function({
  Value<String> id,
  required String name,
  Value<bool> isDefault,
  Value<bool> hidden,
  Value<int> rowid,
});
typedef $$SectionsTableUpdateCompanionBuilder = SectionsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<bool> isDefault,
  Value<bool> hidden,
  Value<int> rowid,
});

final class $$SectionsTableReferences
    extends BaseReferences<_$AppDatabase, $SectionsTable, Section> {
  $$SectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardsTable, List<Card>> _cardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cards,
    aliasName: 'sections__id__cards__section_id',
  );

  $$CardsTableProcessedTableManager get cardsRefs {
    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SectionsTableFilterComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardsRefs(
    Expression<bool> Function($$CardsTableFilterComposer f) f,
  ) {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  Expression<T> cardsRefs<T extends Object>(
    Expression<T> Function($$CardsTableAnnotationComposer a) f,
  ) {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SectionsTable,
          Section,
          $$SectionsTableFilterComposer,
          $$SectionsTableOrderingComposer,
          $$SectionsTableAnnotationComposer,
          $$SectionsTableCreateCompanionBuilder,
          $$SectionsTableUpdateCompanionBuilder,
          (Section, $$SectionsTableReferences),
          Section,
          PrefetchHooks Function({bool cardsRefs})
        > {
  $$SectionsTableTableManager(_$AppDatabase db, $SectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SectionsCompanion(
                id: id,
                name: name,
                isDefault: isDefault,
                hidden: hidden,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                Value<bool> isDefault = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SectionsCompanion.insert(
                id: id,
                name: name,
                isDefault: isDefault,
                hidden: hidden,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SectionsTable, Section>(table),
                  $$SectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardsRefs) db.cards],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardsRefs)
                    await $_getPrefetchedDataByColumns<
                      Section,
                      $SectionsTable,
                      Card,
                      $CardsTable
                    >(
                      currentTable: table,
                      referencedTable: $$SectionsTableReferences
                          ._cardsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SectionsTableReferences(db, table, p0).cardsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'section_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SectionsTable,
      Section,
      $$SectionsTableFilterComposer,
      $$SectionsTableOrderingComposer,
      $$SectionsTableAnnotationComposer,
      $$SectionsTableCreateCompanionBuilder,
      $$SectionsTableUpdateCompanionBuilder,
      (Section, $$SectionsTableReferences),
      Section,
      PrefetchHooks Function({bool cardsRefs})
    >;
typedef $$CardTypesTableCreateCompanionBuilder = CardTypesCompanion Function({
  required String id,
  required String name,
  Value<String?> logo,
  Value<int?> color,
  Value<String?> codeFormat,
  Value<String> category,
  Value<String?> country,
  Value<bool> isGeneric,
  Value<bool> retired,
  Value<DateTime?> retiredOn,
  Value<String?> replacedBy,
  Value<bool> replacementNeedsNewCode,
  Value<int> rowid,
});
typedef $$CardTypesTableUpdateCompanionBuilder = CardTypesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> logo,
  Value<int?> color,
  Value<String?> codeFormat,
  Value<String> category,
  Value<String?> country,
  Value<bool> isGeneric,
  Value<bool> retired,
  Value<DateTime?> retiredOn,
  Value<String?> replacedBy,
  Value<bool> replacementNeedsNewCode,
  Value<int> rowid,
});

final class $$CardTypesTableReferences
    extends BaseReferences<_$AppDatabase, $CardTypesTable, CardType> {
  $$CardTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardsTable, List<Card>> _cardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cards,
    aliasName: 'card_types__id__cards__type_id',
  );

  $$CardsTableProcessedTableManager get cardsRefs {
    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.typeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardTypesTableFilterComposer
    extends Composer<_$AppDatabase, $CardTypesTable> {
  $$CardTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codeFormat => $composableBuilder(
    column: $table.codeFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGeneric => $composableBuilder(
    column: $table.isGeneric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get retired => $composableBuilder(
    column: $table.retired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get retiredOn => $composableBuilder(
    column: $table.retiredOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replacedBy => $composableBuilder(
    column: $table.replacedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get replacementNeedsNewCode => $composableBuilder(
    column: $table.replacementNeedsNewCode,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardsRefs(
    Expression<bool> Function($$CardsTableFilterComposer f) f,
  ) {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.typeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTypesTable> {
  $$CardTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codeFormat => $composableBuilder(
    column: $table.codeFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGeneric => $composableBuilder(
    column: $table.isGeneric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get retired => $composableBuilder(
    column: $table.retired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get retiredOn => $composableBuilder(
    column: $table.retiredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replacedBy => $composableBuilder(
    column: $table.replacedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get replacementNeedsNewCode => $composableBuilder(
    column: $table.replacementNeedsNewCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTypesTable> {
  $$CardTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get logo =>
      $composableBuilder(column: $table.logo, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get codeFormat => $composableBuilder(
    column: $table.codeFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<bool> get isGeneric =>
      $composableBuilder(column: $table.isGeneric, builder: (column) => column);

  GeneratedColumn<bool> get retired =>
      $composableBuilder(column: $table.retired, builder: (column) => column);

  GeneratedColumn<DateTime> get retiredOn =>
      $composableBuilder(column: $table.retiredOn, builder: (column) => column);

  GeneratedColumn<String> get replacedBy => $composableBuilder(
    column: $table.replacedBy,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get replacementNeedsNewCode => $composableBuilder(
    column: $table.replacementNeedsNewCode,
    builder: (column) => column,
  );

  Expression<T> cardsRefs<T extends Object>(
    Expression<T> Function($$CardsTableAnnotationComposer a) f,
  ) {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.typeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardTypesTable,
          CardType,
          $$CardTypesTableFilterComposer,
          $$CardTypesTableOrderingComposer,
          $$CardTypesTableAnnotationComposer,
          $$CardTypesTableCreateCompanionBuilder,
          $$CardTypesTableUpdateCompanionBuilder,
          (CardType, $$CardTypesTableReferences),
          CardType,
          PrefetchHooks Function({bool cardsRefs})
        > {
  $$CardTypesTableTableManager(_$AppDatabase db, $CardTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> logo = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String?> codeFormat = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<bool> isGeneric = const Value.absent(),
                Value<bool> retired = const Value.absent(),
                Value<DateTime?> retiredOn = const Value.absent(),
                Value<String?> replacedBy = const Value.absent(),
                Value<bool> replacementNeedsNewCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardTypesCompanion(
                id: id,
                name: name,
                logo: logo,
                color: color,
                codeFormat: codeFormat,
                category: category,
                country: country,
                isGeneric: isGeneric,
                retired: retired,
                retiredOn: retiredOn,
                replacedBy: replacedBy,
                replacementNeedsNewCode: replacementNeedsNewCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> logo = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String?> codeFormat = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<bool> isGeneric = const Value.absent(),
                Value<bool> retired = const Value.absent(),
                Value<DateTime?> retiredOn = const Value.absent(),
                Value<String?> replacedBy = const Value.absent(),
                Value<bool> replacementNeedsNewCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardTypesCompanion.insert(
                id: id,
                name: name,
                logo: logo,
                color: color,
                codeFormat: codeFormat,
                category: category,
                country: country,
                isGeneric: isGeneric,
                retired: retired,
                retiredOn: retiredOn,
                replacedBy: replacedBy,
                replacementNeedsNewCode: replacementNeedsNewCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardTypesTable, CardType>(table),
                  $$CardTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardsRefs) db.cards],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardsRefs)
                    await $_getPrefetchedDataByColumns<
                      CardType,
                      $CardTypesTable,
                      Card,
                      $CardsTable
                    >(
                      currentTable: table,
                      referencedTable: $$CardTypesTableReferences
                          ._cardsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CardTypesTableReferences(db, table, p0).cardsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'type_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CardTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardTypesTable,
      CardType,
      $$CardTypesTableFilterComposer,
      $$CardTypesTableOrderingComposer,
      $$CardTypesTableAnnotationComposer,
      $$CardTypesTableCreateCompanionBuilder,
      $$CardTypesTableUpdateCompanionBuilder,
      (CardType, $$CardTypesTableReferences),
      CardType,
      PrefetchHooks Function({bool cardsRefs})
    >;
typedef $$CardsTableCreateCompanionBuilder = CardsCompanion Function({
  Value<String> id,
  required String typeId,
  required String name,
  required String code,
  required String codeFormat,
  Value<String?> notes,
  Value<String?> holder,
  Value<DateTime?> expiresOn,
  required String sectionId,
  Value<DateTime> createdAt,
  Value<DateTime?> lastUsedAt,
  Value<bool> favorite,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$CardsTableUpdateCompanionBuilder = CardsCompanion Function({
  Value<String> id,
  Value<String> typeId,
  Value<String> name,
  Value<String> code,
  Value<String> codeFormat,
  Value<String?> notes,
  Value<String?> holder,
  Value<DateTime?> expiresOn,
  Value<String> sectionId,
  Value<DateTime> createdAt,
  Value<DateTime?> lastUsedAt,
  Value<bool> favorite,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

final class $$CardsTableReferences
    extends BaseReferences<_$AppDatabase, $CardsTable, Card> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardTypesTable _typeIdTable(_$AppDatabase db) =>
      db.cardTypes.createAlias('cards__type_id__card_types__id');

  $$CardTypesTableProcessedTableManager get typeId {
    final $_column = $_itemColumn<String>('type_id')!;

    final manager = $$CardTypesTableTableManager(
      $_db,
      $_db.cardTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_typeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SectionsTable _sectionIdTable(_$AppDatabase db) =>
      db.sections.createAlias('cards__section_id__sections__id');

  $$SectionsTableProcessedTableManager get sectionId {
    final $_column = $_itemColumn<String>('section_id')!;

    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CardImagesTable, List<CardImage>>
  _cardImagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardImages,
    aliasName: 'cards__id__card_images__card_id',
  );

  $$CardImagesTableProcessedTableManager get cardImagesRefs {
    final manager = $$CardImagesTableTableManager(
      $_db,
      $_db.cardImages,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardImagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codeFormat => $composableBuilder(
    column: $table.codeFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get holder => $composableBuilder(
    column: $table.holder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresOn => $composableBuilder(
    column: $table.expiresOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CardTypesTableFilterComposer get typeId {
    final $$CardTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.cardTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardTypesTableFilterComposer(
            $db: $db,
            $table: $db.cardTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableFilterComposer get sectionId {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cardImagesRefs(
    Expression<bool> Function($$CardImagesTableFilterComposer f) f,
  ) {
    final $$CardImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardImages,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardImagesTableFilterComposer(
            $db: $db,
            $table: $db.cardImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codeFormat => $composableBuilder(
    column: $table.codeFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get holder => $composableBuilder(
    column: $table.holder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresOn => $composableBuilder(
    column: $table.expiresOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardTypesTableOrderingComposer get typeId {
    final $$CardTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.cardTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardTypesTableOrderingComposer(
            $db: $db,
            $table: $db.cardTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableOrderingComposer get sectionId {
    final $$SectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableOrderingComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get codeFormat => $composableBuilder(
    column: $table.codeFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get holder =>
      $composableBuilder(column: $table.holder, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresOn =>
      $composableBuilder(column: $table.expiresOn, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CardTypesTableAnnotationComposer get typeId {
    final $$CardTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.cardTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.cardTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableAnnotationComposer get sectionId {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cardImagesRefs<T extends Object>(
    Expression<T> Function($$CardImagesTableAnnotationComposer a) f,
  ) {
    final $$CardImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardImages,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.cardImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsTable,
          Card,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (Card, $$CardsTableReferences),
          Card,
          PrefetchHooks Function({
            bool typeId,
            bool sectionId,
            bool cardImagesRefs,
          })
        > {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> typeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> codeFormat = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> holder = const Value.absent(),
                Value<DateTime?> expiresOn = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                typeId: typeId,
                name: name,
                code: code,
                codeFormat: codeFormat,
                notes: notes,
                holder: holder,
                expiresOn: expiresOn,
                sectionId: sectionId,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                favorite: favorite,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String typeId,
                required String name,
                required String code,
                required String codeFormat,
                Value<String?> notes = const Value.absent(),
                Value<String?> holder = const Value.absent(),
                Value<DateTime?> expiresOn = const Value.absent(),
                required String sectionId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                typeId: typeId,
                name: name,
                code: code,
                codeFormat: codeFormat,
                notes: notes,
                holder: holder,
                expiresOn: expiresOn,
                sectionId: sectionId,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                favorite: favorite,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardsTable, Card>(table),
                  $$CardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({typeId = false, sectionId = false, cardImagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (cardImagesRefs) db.cardImages],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (typeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.typeId,
                            referencedTable: $$CardsTableReferences
                                ._typeIdTable(db),
                            referencedColumn: $$CardsTableReferences
                                ._typeIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (sectionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sectionId,
                            referencedTable: $$CardsTableReferences
                                ._sectionIdTable(db),
                            referencedColumn: $$CardsTableReferences
                                ._sectionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cardImagesRefs)
                        await $_getPrefetchedDataByColumns<
                          Card,
                          $CardsTable,
                          CardImage,
                          $CardImagesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CardsTableReferences
                              ._cardImagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardImagesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'card_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsTable,
      Card,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (Card, $$CardsTableReferences),
      Card,
      PrefetchHooks Function({bool typeId, bool sectionId, bool cardImagesRefs})
    >;
typedef $$CardImagesTableCreateCompanionBuilder = CardImagesCompanion Function({
  required String cardId,
  required String side,
  required String fileName,
  Value<int> rowid,
});
typedef $$CardImagesTableUpdateCompanionBuilder = CardImagesCompanion Function({
  Value<String> cardId,
  Value<String> side,
  Value<String> fileName,
  Value<int> rowid,
});

final class $$CardImagesTableReferences
    extends BaseReferences<_$AppDatabase, $CardImagesTable, CardImage> {
  $$CardImagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardsTable _cardIdTable(_$AppDatabase db) =>
      db.cards.createAlias('card_images__card_id__cards__id');

  $$CardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardImagesTableFilterComposer
    extends Composer<_$AppDatabase, $CardImagesTable> {
  $$CardImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CardImagesTable> {
  $$CardImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableOrderingComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardImagesTable> {
  $$CardImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardImagesTable,
          CardImage,
          $$CardImagesTableFilterComposer,
          $$CardImagesTableOrderingComposer,
          $$CardImagesTableAnnotationComposer,
          $$CardImagesTableCreateCompanionBuilder,
          $$CardImagesTableUpdateCompanionBuilder,
          (CardImage, $$CardImagesTableReferences),
          CardImage,
          PrefetchHooks Function({bool cardId})
        > {
  $$CardImagesTableTableManager(_$AppDatabase db, $CardImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardImagesCompanion(
                cardId: cardId,
                side: side,
                fileName: fileName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required String side,
                required String fileName,
                Value<int> rowid = const Value.absent(),
              }) => CardImagesCompanion.insert(
                cardId: cardId,
                side: side,
                fileName: fileName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardImagesTable, CardImage>(table),
                  $$CardImagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cardId,
                        referencedTable: $$CardImagesTableReferences
                            ._cardIdTable(db),
                        referencedColumn: $$CardImagesTableReferences
                            ._cardIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CardImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardImagesTable,
      CardImage,
      $$CardImagesTableFilterComposer,
      $$CardImagesTableOrderingComposer,
      $$CardImagesTableAnnotationComposer,
      $$CardImagesTableCreateCompanionBuilder,
      $$CardImagesTableUpdateCompanionBuilder,
      (CardImage, $$CardImagesTableReferences),
      CardImage,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db, _db.sections);
  $$CardTypesTableTableManager get cardTypes =>
      $$CardTypesTableTableManager(_db, _db.cardTypes);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$CardImagesTableTableManager get cardImages =>
      $$CardImagesTableTableManager(_db, _db.cardImages);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
