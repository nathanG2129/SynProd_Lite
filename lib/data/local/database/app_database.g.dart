// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductsTableTable extends ProductsTable
    with TableInfo<$ProductsTableTable, ProductEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productTypeCodeMeta = const VerificationMeta(
    'productTypeCode',
  );
  @override
  late final GeneratedColumn<String> productTypeCode = GeneratedColumn<String>(
    'product_type_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByDeviceIdMeta = const VerificationMeta(
    'createdByDeviceId',
  );
  @override
  late final GeneratedColumn<String> createdByDeviceId =
      GeneratedColumn<String>(
        'created_by_device_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdByDisplayNameMeta =
      const VerificationMeta('createdByDisplayName');
  @override
  late final GeneratedColumn<String> createdByDisplayName =
      GeneratedColumn<String>(
        'created_by_display_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _updatedByDeviceIdMeta = const VerificationMeta(
    'updatedByDeviceId',
  );
  @override
  late final GeneratedColumn<String> updatedByDeviceId =
      GeneratedColumn<String>(
        'updated_by_device_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedByDisplayNameMeta =
      const VerificationMeta('updatedByDisplayName');
  @override
  late final GeneratedColumn<String> updatedByDisplayName =
      GeneratedColumn<String>(
        'updated_by_display_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    productTypeCode,
    createdByDeviceId,
    createdByDisplayName,
    updatedByDeviceId,
    updatedByDisplayName,
    createdAt,
    updatedAt,
    isDeleted,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductEntry> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('product_type_code')) {
      context.handle(
        _productTypeCodeMeta,
        productTypeCode.isAcceptableOrUnknown(
          data['product_type_code']!,
          _productTypeCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productTypeCodeMeta);
    }
    if (data.containsKey('created_by_device_id')) {
      context.handle(
        _createdByDeviceIdMeta,
        createdByDeviceId.isAcceptableOrUnknown(
          data['created_by_device_id']!,
          _createdByDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByDeviceIdMeta);
    }
    if (data.containsKey('created_by_display_name')) {
      context.handle(
        _createdByDisplayNameMeta,
        createdByDisplayName.isAcceptableOrUnknown(
          data['created_by_display_name']!,
          _createdByDisplayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByDisplayNameMeta);
    }
    if (data.containsKey('updated_by_device_id')) {
      context.handle(
        _updatedByDeviceIdMeta,
        updatedByDeviceId.isAcceptableOrUnknown(
          data['updated_by_device_id']!,
          _updatedByDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('updated_by_display_name')) {
      context.handle(
        _updatedByDisplayNameMeta,
        updatedByDisplayName.isAcceptableOrUnknown(
          data['updated_by_display_name']!,
          _updatedByDisplayNameMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      productTypeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_type_code'],
      )!,
      createdByDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_device_id'],
      )!,
      createdByDisplayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_display_name'],
      )!,
      updatedByDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_device_id'],
      ),
      updatedByDisplayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_display_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $ProductsTableTable createAlias(String alias) {
    return $ProductsTableTable(attachedDatabase, alias);
  }
}

class ProductEntry extends DataClass implements Insertable<ProductEntry> {
  final String id;
  final String name;
  final String? description;
  final String productTypeCode;
  final String createdByDeviceId;
  final String createdByDisplayName;
  final String? updatedByDeviceId;
  final String? updatedByDisplayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
  const ProductEntry({
    required this.id,
    required this.name,
    this.description,
    required this.productTypeCode,
    required this.createdByDeviceId,
    required this.createdByDisplayName,
    this.updatedByDeviceId,
    this.updatedByDisplayName,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['product_type_code'] = Variable<String>(productTypeCode);
    map['created_by_device_id'] = Variable<String>(createdByDeviceId);
    map['created_by_display_name'] = Variable<String>(createdByDisplayName);
    if (!nullToAbsent || updatedByDeviceId != null) {
      map['updated_by_device_id'] = Variable<String>(updatedByDeviceId);
    }
    if (!nullToAbsent || updatedByDisplayName != null) {
      map['updated_by_display_name'] = Variable<String>(updatedByDisplayName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    return map;
  }

  ProductsTableCompanion toCompanion(bool nullToAbsent) {
    return ProductsTableCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      productTypeCode: Value(productTypeCode),
      createdByDeviceId: Value(createdByDeviceId),
      createdByDisplayName: Value(createdByDisplayName),
      updatedByDeviceId: updatedByDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByDeviceId),
      updatedByDisplayName: updatedByDisplayName == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByDisplayName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
    );
  }

  factory ProductEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      productTypeCode: serializer.fromJson<String>(json['productTypeCode']),
      createdByDeviceId: serializer.fromJson<String>(json['createdByDeviceId']),
      createdByDisplayName: serializer.fromJson<String>(
        json['createdByDisplayName'],
      ),
      updatedByDeviceId: serializer.fromJson<String?>(
        json['updatedByDeviceId'],
      ),
      updatedByDisplayName: serializer.fromJson<String?>(
        json['updatedByDisplayName'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'productTypeCode': serializer.toJson<String>(productTypeCode),
      'createdByDeviceId': serializer.toJson<String>(createdByDeviceId),
      'createdByDisplayName': serializer.toJson<String>(createdByDisplayName),
      'updatedByDeviceId': serializer.toJson<String?>(updatedByDeviceId),
      'updatedByDisplayName': serializer.toJson<String?>(updatedByDisplayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
    };
  }

  ProductEntry copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? productTypeCode,
    String? createdByDeviceId,
    String? createdByDisplayName,
    Value<String?> updatedByDeviceId = const Value.absent(),
    Value<String?> updatedByDisplayName = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    int? version,
  }) => ProductEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    productTypeCode: productTypeCode ?? this.productTypeCode,
    createdByDeviceId: createdByDeviceId ?? this.createdByDeviceId,
    createdByDisplayName: createdByDisplayName ?? this.createdByDisplayName,
    updatedByDeviceId: updatedByDeviceId.present
        ? updatedByDeviceId.value
        : this.updatedByDeviceId,
    updatedByDisplayName: updatedByDisplayName.present
        ? updatedByDisplayName.value
        : this.updatedByDisplayName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    version: version ?? this.version,
  );
  ProductEntry copyWithCompanion(ProductsTableCompanion data) {
    return ProductEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      productTypeCode: data.productTypeCode.present
          ? data.productTypeCode.value
          : this.productTypeCode,
      createdByDeviceId: data.createdByDeviceId.present
          ? data.createdByDeviceId.value
          : this.createdByDeviceId,
      createdByDisplayName: data.createdByDisplayName.present
          ? data.createdByDisplayName.value
          : this.createdByDisplayName,
      updatedByDeviceId: data.updatedByDeviceId.present
          ? data.updatedByDeviceId.value
          : this.updatedByDeviceId,
      updatedByDisplayName: data.updatedByDisplayName.present
          ? data.updatedByDisplayName.value
          : this.updatedByDisplayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('productTypeCode: $productTypeCode, ')
          ..write('createdByDeviceId: $createdByDeviceId, ')
          ..write('createdByDisplayName: $createdByDisplayName, ')
          ..write('updatedByDeviceId: $updatedByDeviceId, ')
          ..write('updatedByDisplayName: $updatedByDisplayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    productTypeCode,
    createdByDeviceId,
    createdByDisplayName,
    updatedByDeviceId,
    updatedByDisplayName,
    createdAt,
    updatedAt,
    isDeleted,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.productTypeCode == this.productTypeCode &&
          other.createdByDeviceId == this.createdByDeviceId &&
          other.createdByDisplayName == this.createdByDisplayName &&
          other.updatedByDeviceId == this.updatedByDeviceId &&
          other.updatedByDisplayName == this.updatedByDisplayName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version);
}

class ProductsTableCompanion extends UpdateCompanion<ProductEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> productTypeCode;
  final Value<String> createdByDeviceId;
  final Value<String> createdByDisplayName;
  final Value<String?> updatedByDeviceId;
  final Value<String?> updatedByDisplayName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<int> rowid;
  const ProductsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.productTypeCode = const Value.absent(),
    this.createdByDeviceId = const Value.absent(),
    this.createdByDisplayName = const Value.absent(),
    this.updatedByDeviceId = const Value.absent(),
    this.updatedByDisplayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String productTypeCode,
    required String createdByDeviceId,
    required String createdByDisplayName,
    this.updatedByDeviceId = const Value.absent(),
    this.updatedByDisplayName = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       productTypeCode = Value(productTypeCode),
       createdByDeviceId = Value(createdByDeviceId),
       createdByDisplayName = Value(createdByDisplayName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProductEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? productTypeCode,
    Expression<String>? createdByDeviceId,
    Expression<String>? createdByDisplayName,
    Expression<String>? updatedByDeviceId,
    Expression<String>? updatedByDisplayName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (productTypeCode != null) 'product_type_code': productTypeCode,
      if (createdByDeviceId != null) 'created_by_device_id': createdByDeviceId,
      if (createdByDisplayName != null)
        'created_by_display_name': createdByDisplayName,
      if (updatedByDeviceId != null) 'updated_by_device_id': updatedByDeviceId,
      if (updatedByDisplayName != null)
        'updated_by_display_name': updatedByDisplayName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? productTypeCode,
    Value<String>? createdByDeviceId,
    Value<String>? createdByDisplayName,
    Value<String?>? updatedByDeviceId,
    Value<String?>? updatedByDisplayName,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return ProductsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      productTypeCode: productTypeCode ?? this.productTypeCode,
      createdByDeviceId: createdByDeviceId ?? this.createdByDeviceId,
      createdByDisplayName: createdByDisplayName ?? this.createdByDisplayName,
      updatedByDeviceId: updatedByDeviceId ?? this.updatedByDeviceId,
      updatedByDisplayName: updatedByDisplayName ?? this.updatedByDisplayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (productTypeCode.present) {
      map['product_type_code'] = Variable<String>(productTypeCode.value);
    }
    if (createdByDeviceId.present) {
      map['created_by_device_id'] = Variable<String>(createdByDeviceId.value);
    }
    if (createdByDisplayName.present) {
      map['created_by_display_name'] = Variable<String>(
        createdByDisplayName.value,
      );
    }
    if (updatedByDeviceId.present) {
      map['updated_by_device_id'] = Variable<String>(updatedByDeviceId.value);
    }
    if (updatedByDisplayName.present) {
      map['updated_by_display_name'] = Variable<String>(
        updatedByDisplayName.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('productTypeCode: $productTypeCode, ')
          ..write('createdByDeviceId: $createdByDeviceId, ')
          ..write('createdByDisplayName: $createdByDisplayName, ')
          ..write('updatedByDeviceId: $updatedByDeviceId, ')
          ..write('updatedByDisplayName: $updatedByDisplayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompositionsTableTable extends CompositionsTable
    with TableInfo<$CompositionsTableTable, CompositionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompositionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _componentNameMeta = const VerificationMeta(
    'componentName',
  );
  @override
  late final GeneratedColumn<String> componentName = GeneratedColumn<String>(
    'component_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _percentageMeta = const VerificationMeta(
    'percentage',
  );
  @override
  late final GeneratedColumn<double> percentage = GeneratedColumn<double>(
    'percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    componentName,
    percentage,
    notes,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compositions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompositionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('component_name')) {
      context.handle(
        _componentNameMeta,
        componentName.isAcceptableOrUnknown(
          data['component_name']!,
          _componentNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_componentNameMeta);
    }
    if (data.containsKey('percentage')) {
      context.handle(
        _percentageMeta,
        percentage.isAcceptableOrUnknown(data['percentage']!, _percentageMeta),
      );
    } else if (isInserting) {
      context.missing(_percentageMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompositionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompositionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      componentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}component_name'],
      )!,
      percentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percentage'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CompositionsTableTable createAlias(String alias) {
    return $CompositionsTableTable(attachedDatabase, alias);
  }
}

class CompositionEntry extends DataClass
    implements Insertable<CompositionEntry> {
  final String id;
  final String productId;
  final String componentName;
  final double percentage;
  final String? notes;
  final int sortOrder;
  const CompositionEntry({
    required this.id,
    required this.productId,
    required this.componentName,
    required this.percentage,
    this.notes,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['component_name'] = Variable<String>(componentName);
    map['percentage'] = Variable<double>(percentage);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CompositionsTableCompanion toCompanion(bool nullToAbsent) {
    return CompositionsTableCompanion(
      id: Value(id),
      productId: Value(productId),
      componentName: Value(componentName),
      percentage: Value(percentage),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      sortOrder: Value(sortOrder),
    );
  }

  factory CompositionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompositionEntry(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      componentName: serializer.fromJson<String>(json['componentName']),
      percentage: serializer.fromJson<double>(json['percentage']),
      notes: serializer.fromJson<String?>(json['notes']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'componentName': serializer.toJson<String>(componentName),
      'percentage': serializer.toJson<double>(percentage),
      'notes': serializer.toJson<String?>(notes),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CompositionEntry copyWith({
    String? id,
    String? productId,
    String? componentName,
    double? percentage,
    Value<String?> notes = const Value.absent(),
    int? sortOrder,
  }) => CompositionEntry(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    componentName: componentName ?? this.componentName,
    percentage: percentage ?? this.percentage,
    notes: notes.present ? notes.value : this.notes,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CompositionEntry copyWithCompanion(CompositionsTableCompanion data) {
    return CompositionEntry(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      componentName: data.componentName.present
          ? data.componentName.value
          : this.componentName,
      percentage: data.percentage.present
          ? data.percentage.value
          : this.percentage,
      notes: data.notes.present ? data.notes.value : this.notes,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompositionEntry(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('componentName: $componentName, ')
          ..write('percentage: $percentage, ')
          ..write('notes: $notes, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, productId, componentName, percentage, notes, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompositionEntry &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.componentName == this.componentName &&
          other.percentage == this.percentage &&
          other.notes == this.notes &&
          other.sortOrder == this.sortOrder);
}

class CompositionsTableCompanion extends UpdateCompanion<CompositionEntry> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> componentName;
  final Value<double> percentage;
  final Value<String?> notes;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CompositionsTableCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.componentName = const Value.absent(),
    this.percentage = const Value.absent(),
    this.notes = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompositionsTableCompanion.insert({
    required String id,
    required String productId,
    required String componentName,
    required double percentage,
    this.notes = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       componentName = Value(componentName),
       percentage = Value(percentage);
  static Insertable<CompositionEntry> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? componentName,
    Expression<double>? percentage,
    Expression<String>? notes,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (componentName != null) 'component_name': componentName,
      if (percentage != null) 'percentage': percentage,
      if (notes != null) 'notes': notes,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompositionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? componentName,
    Value<double>? percentage,
    Value<String?>? notes,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CompositionsTableCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      componentName: componentName ?? this.componentName,
      percentage: percentage ?? this.percentage,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (componentName.present) {
      map['component_name'] = Variable<String>(componentName.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<double>(percentage.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompositionsTableCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('componentName: $componentName, ')
          ..write('percentage: $percentage, ')
          ..write('notes: $notes, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdditionalIngredientsTableTable extends AdditionalIngredientsTable
    with
        TableInfo<$AdditionalIngredientsTableTable, AdditionalIngredientEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdditionalIngredientsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ingredientNameMeta = const VerificationMeta(
    'ingredientName',
  );
  @override
  late final GeneratedColumn<String> ingredientName = GeneratedColumn<String>(
    'ingredient_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
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
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    ingredientName,
    quantity,
    unit,
    notes,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'additional_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdditionalIngredientEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('ingredient_name')) {
      context.handle(
        _ingredientNameMeta,
        ingredientName.isAcceptableOrUnknown(
          data['ingredient_name']!,
          _ingredientNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdditionalIngredientEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdditionalIngredientEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      ingredientName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $AdditionalIngredientsTableTable createAlias(String alias) {
    return $AdditionalIngredientsTableTable(attachedDatabase, alias);
  }
}

class AdditionalIngredientEntry extends DataClass
    implements Insertable<AdditionalIngredientEntry> {
  final String id;
  final String productId;
  final String ingredientName;
  final double quantity;
  final String unit;
  final String? notes;
  final int sortOrder;
  const AdditionalIngredientEntry({
    required this.id,
    required this.productId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    this.notes,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['ingredient_name'] = Variable<String>(ingredientName);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  AdditionalIngredientsTableCompanion toCompanion(bool nullToAbsent) {
    return AdditionalIngredientsTableCompanion(
      id: Value(id),
      productId: Value(productId),
      ingredientName: Value(ingredientName),
      quantity: Value(quantity),
      unit: Value(unit),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      sortOrder: Value(sortOrder),
    );
  }

  factory AdditionalIngredientEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdditionalIngredientEntry(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      ingredientName: serializer.fromJson<String>(json['ingredientName']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      notes: serializer.fromJson<String?>(json['notes']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'ingredientName': serializer.toJson<String>(ingredientName),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'notes': serializer.toJson<String?>(notes),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  AdditionalIngredientEntry copyWith({
    String? id,
    String? productId,
    String? ingredientName,
    double? quantity,
    String? unit,
    Value<String?> notes = const Value.absent(),
    int? sortOrder,
  }) => AdditionalIngredientEntry(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    ingredientName: ingredientName ?? this.ingredientName,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    notes: notes.present ? notes.value : this.notes,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  AdditionalIngredientEntry copyWithCompanion(
    AdditionalIngredientsTableCompanion data,
  ) {
    return AdditionalIngredientEntry(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      ingredientName: data.ingredientName.present
          ? data.ingredientName.value
          : this.ingredientName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      notes: data.notes.present ? data.notes.value : this.notes,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdditionalIngredientEntry(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('ingredientName: $ingredientName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('notes: $notes, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    ingredientName,
    quantity,
    unit,
    notes,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdditionalIngredientEntry &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.ingredientName == this.ingredientName &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.notes == this.notes &&
          other.sortOrder == this.sortOrder);
}

class AdditionalIngredientsTableCompanion
    extends UpdateCompanion<AdditionalIngredientEntry> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> ingredientName;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<String?> notes;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const AdditionalIngredientsTableCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.ingredientName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.notes = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdditionalIngredientsTableCompanion.insert({
    required String id,
    required String productId,
    required String ingredientName,
    required double quantity,
    required String unit,
    this.notes = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       ingredientName = Value(ingredientName),
       quantity = Value(quantity),
       unit = Value(unit);
  static Insertable<AdditionalIngredientEntry> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? ingredientName,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? notes,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (ingredientName != null) 'ingredient_name': ingredientName,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (notes != null) 'notes': notes,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdditionalIngredientsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? ingredientName,
    Value<double>? quantity,
    Value<String>? unit,
    Value<String?>? notes,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return AdditionalIngredientsTableCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      ingredientName: ingredientName ?? this.ingredientName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (ingredientName.present) {
      map['ingredient_name'] = Variable<String>(ingredientName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdditionalIngredientsTableCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('ingredientName: $ingredientName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('notes: $notes, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevicesTableTable extends DevicesTable
    with TableInfo<$DevicesTableTable, DeviceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleCodeMeta = const VerificationMeta(
    'roleCode',
  );
  @override
  late final GeneratedColumn<String> roleCode = GeneratedColumn<String>(
    'role_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairedAtMeta = const VerificationMeta(
    'pairedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pairedAt = GeneratedColumn<DateTime>(
    'paired_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRevokedMeta = const VerificationMeta(
    'isRevoked',
  );
  @override
  late final GeneratedColumn<bool> isRevoked = GeneratedColumn<bool>(
    'is_revoked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_revoked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    roleCode,
    pairedAt,
    lastSeenAt,
    isRevoked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('role_code')) {
      context.handle(
        _roleCodeMeta,
        roleCode.isAcceptableOrUnknown(data['role_code']!, _roleCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_roleCodeMeta);
    }
    if (data.containsKey('paired_at')) {
      context.handle(
        _pairedAtMeta,
        pairedAt.isAcceptableOrUnknown(data['paired_at']!, _pairedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_pairedAtMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    if (data.containsKey('is_revoked')) {
      context.handle(
        _isRevokedMeta,
        isRevoked.isAcceptableOrUnknown(data['is_revoked']!, _isRevokedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      roleCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_code'],
      )!,
      pairedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paired_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
      isRevoked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_revoked'],
      )!,
    );
  }

  @override
  $DevicesTableTable createAlias(String alias) {
    return $DevicesTableTable(attachedDatabase, alias);
  }
}

class DeviceEntry extends DataClass implements Insertable<DeviceEntry> {
  final String id;
  final String displayName;
  final String roleCode;
  final DateTime pairedAt;
  final DateTime lastSeenAt;
  final bool isRevoked;
  const DeviceEntry({
    required this.id,
    required this.displayName,
    required this.roleCode,
    required this.pairedAt,
    required this.lastSeenAt,
    required this.isRevoked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['role_code'] = Variable<String>(roleCode);
    map['paired_at'] = Variable<DateTime>(pairedAt);
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    map['is_revoked'] = Variable<bool>(isRevoked);
    return map;
  }

  DevicesTableCompanion toCompanion(bool nullToAbsent) {
    return DevicesTableCompanion(
      id: Value(id),
      displayName: Value(displayName),
      roleCode: Value(roleCode),
      pairedAt: Value(pairedAt),
      lastSeenAt: Value(lastSeenAt),
      isRevoked: Value(isRevoked),
    );
  }

  factory DeviceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceEntry(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      roleCode: serializer.fromJson<String>(json['roleCode']),
      pairedAt: serializer.fromJson<DateTime>(json['pairedAt']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
      isRevoked: serializer.fromJson<bool>(json['isRevoked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'roleCode': serializer.toJson<String>(roleCode),
      'pairedAt': serializer.toJson<DateTime>(pairedAt),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
      'isRevoked': serializer.toJson<bool>(isRevoked),
    };
  }

  DeviceEntry copyWith({
    String? id,
    String? displayName,
    String? roleCode,
    DateTime? pairedAt,
    DateTime? lastSeenAt,
    bool? isRevoked,
  }) => DeviceEntry(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    roleCode: roleCode ?? this.roleCode,
    pairedAt: pairedAt ?? this.pairedAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    isRevoked: isRevoked ?? this.isRevoked,
  );
  DeviceEntry copyWithCompanion(DevicesTableCompanion data) {
    return DeviceEntry(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      roleCode: data.roleCode.present ? data.roleCode.value : this.roleCode,
      pairedAt: data.pairedAt.present ? data.pairedAt.value : this.pairedAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      isRevoked: data.isRevoked.present ? data.isRevoked.value : this.isRevoked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceEntry(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('roleCode: $roleCode, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('isRevoked: $isRevoked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, displayName, roleCode, pairedAt, lastSeenAt, isRevoked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceEntry &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.roleCode == this.roleCode &&
          other.pairedAt == this.pairedAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.isRevoked == this.isRevoked);
}

class DevicesTableCompanion extends UpdateCompanion<DeviceEntry> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> roleCode;
  final Value<DateTime> pairedAt;
  final Value<DateTime> lastSeenAt;
  final Value<bool> isRevoked;
  final Value<int> rowid;
  const DevicesTableCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.roleCode = const Value.absent(),
    this.pairedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.isRevoked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesTableCompanion.insert({
    required String id,
    required String displayName,
    required String roleCode,
    required DateTime pairedAt,
    required DateTime lastSeenAt,
    this.isRevoked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       roleCode = Value(roleCode),
       pairedAt = Value(pairedAt),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<DeviceEntry> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? roleCode,
    Expression<DateTime>? pairedAt,
    Expression<DateTime>? lastSeenAt,
    Expression<bool>? isRevoked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (roleCode != null) 'role_code': roleCode,
      if (pairedAt != null) 'paired_at': pairedAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (isRevoked != null) 'is_revoked': isRevoked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? roleCode,
    Value<DateTime>? pairedAt,
    Value<DateTime>? lastSeenAt,
    Value<bool>? isRevoked,
    Value<int>? rowid,
  }) {
    return DevicesTableCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      roleCode: roleCode ?? this.roleCode,
      pairedAt: pairedAt ?? this.pairedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isRevoked: isRevoked ?? this.isRevoked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (roleCode.present) {
      map['role_code'] = Variable<String>(roleCode.value);
    }
    if (pairedAt.present) {
      map['paired_at'] = Variable<DateTime>(pairedAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (isRevoked.present) {
      map['is_revoked'] = Variable<bool>(isRevoked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesTableCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('roleCode: $roleCode, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('isRevoked: $isRevoked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkspacesTableTable extends WorkspacesTable
    with TableInfo<$WorkspacesTableTable, WorkspaceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspacesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _workspaceKeyMeta = const VerificationMeta(
    'workspaceKey',
  );
  @override
  late final GeneratedColumn<String> workspaceKey = GeneratedColumn<String>(
    'workspace_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, workspaceKey, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkspaceEntry> instance, {
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
    if (data.containsKey('workspace_key')) {
      context.handle(
        _workspaceKeyMeta,
        workspaceKey.isAcceptableOrUnknown(
          data['workspace_key']!,
          _workspaceKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkspaceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkspaceEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      workspaceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WorkspacesTableTable createAlias(String alias) {
    return $WorkspacesTableTable(attachedDatabase, alias);
  }
}

class WorkspaceEntry extends DataClass implements Insertable<WorkspaceEntry> {
  final String id;
  final String name;
  final String workspaceKey;
  final DateTime createdAt;
  const WorkspaceEntry({
    required this.id,
    required this.name,
    required this.workspaceKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['workspace_key'] = Variable<String>(workspaceKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WorkspacesTableCompanion toCompanion(bool nullToAbsent) {
    return WorkspacesTableCompanion(
      id: Value(id),
      name: Value(name),
      workspaceKey: Value(workspaceKey),
      createdAt: Value(createdAt),
    );
  }

  factory WorkspaceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkspaceEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      workspaceKey: serializer.fromJson<String>(json['workspaceKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'workspaceKey': serializer.toJson<String>(workspaceKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WorkspaceEntry copyWith({
    String? id,
    String? name,
    String? workspaceKey,
    DateTime? createdAt,
  }) => WorkspaceEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    workspaceKey: workspaceKey ?? this.workspaceKey,
    createdAt: createdAt ?? this.createdAt,
  );
  WorkspaceEntry copyWithCompanion(WorkspacesTableCompanion data) {
    return WorkspaceEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      workspaceKey: data.workspaceKey.present
          ? data.workspaceKey.value
          : this.workspaceKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('workspaceKey: $workspaceKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, workspaceKey, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkspaceEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.workspaceKey == this.workspaceKey &&
          other.createdAt == this.createdAt);
}

class WorkspacesTableCompanion extends UpdateCompanion<WorkspaceEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> workspaceKey;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WorkspacesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.workspaceKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspacesTableCompanion.insert({
    required String id,
    required String name,
    required String workspaceKey,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       workspaceKey = Value(workspaceKey),
       createdAt = Value(createdAt);
  static Insertable<WorkspaceEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? workspaceKey,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (workspaceKey != null) 'workspace_key': workspaceKey,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspacesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? workspaceKey,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WorkspacesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      workspaceKey: workspaceKey ?? this.workspaceKey,
      createdAt: createdAt ?? this.createdAt,
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
    if (workspaceKey.present) {
      map['workspace_key'] = Variable<String>(workspaceKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspacesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('workspaceKey: $workspaceKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PairingTokensTableTable extends PairingTokensTable
    with TableInfo<$PairingTokensTableTable, PairingTokenEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PairingTokensTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleCodeMeta = const VerificationMeta(
    'roleCode',
  );
  @override
  late final GeneratedColumn<String> roleCode = GeneratedColumn<String>(
    'role_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isUsedMeta = const VerificationMeta('isUsed');
  @override
  late final GeneratedColumn<bool> isUsed = GeneratedColumn<bool>(
    'is_used',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_used" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    displayName,
    roleCode,
    createdAt,
    expiresAt,
    isUsed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pairing_tokens';
  @override
  VerificationContext validateIntegrity(
    Insertable<PairingTokenEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('role_code')) {
      context.handle(
        _roleCodeMeta,
        roleCode.isAcceptableOrUnknown(data['role_code']!, _roleCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_roleCodeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('is_used')) {
      context.handle(
        _isUsedMeta,
        isUsed.isAcceptableOrUnknown(data['is_used']!, _isUsedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PairingTokenEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PairingTokenEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      roleCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_code'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      isUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_used'],
      )!,
    );
  }

  @override
  $PairingTokensTableTable createAlias(String alias) {
    return $PairingTokensTableTable(attachedDatabase, alias);
  }
}

class PairingTokenEntry extends DataClass
    implements Insertable<PairingTokenEntry> {
  final String id;
  final String deviceId;
  final String displayName;
  final String roleCode;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;
  const PairingTokenEntry({
    required this.id,
    required this.deviceId,
    required this.displayName,
    required this.roleCode,
    required this.createdAt,
    required this.expiresAt,
    required this.isUsed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['display_name'] = Variable<String>(displayName);
    map['role_code'] = Variable<String>(roleCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['is_used'] = Variable<bool>(isUsed);
    return map;
  }

  PairingTokensTableCompanion toCompanion(bool nullToAbsent) {
    return PairingTokensTableCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      displayName: Value(displayName),
      roleCode: Value(roleCode),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
      isUsed: Value(isUsed),
    );
  }

  factory PairingTokenEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PairingTokenEntry(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      roleCode: serializer.fromJson<String>(json['roleCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      isUsed: serializer.fromJson<bool>(json['isUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'displayName': serializer.toJson<String>(displayName),
      'roleCode': serializer.toJson<String>(roleCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'isUsed': serializer.toJson<bool>(isUsed),
    };
  }

  PairingTokenEntry copyWith({
    String? id,
    String? deviceId,
    String? displayName,
    String? roleCode,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isUsed,
  }) => PairingTokenEntry(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    displayName: displayName ?? this.displayName,
    roleCode: roleCode ?? this.roleCode,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
    isUsed: isUsed ?? this.isUsed,
  );
  PairingTokenEntry copyWithCompanion(PairingTokensTableCompanion data) {
    return PairingTokenEntry(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      roleCode: data.roleCode.present ? data.roleCode.value : this.roleCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      isUsed: data.isUsed.present ? data.isUsed.value : this.isUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PairingTokenEntry(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('displayName: $displayName, ')
          ..write('roleCode: $roleCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isUsed: $isUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    displayName,
    roleCode,
    createdAt,
    expiresAt,
    isUsed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PairingTokenEntry &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.displayName == this.displayName &&
          other.roleCode == this.roleCode &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt &&
          other.isUsed == this.isUsed);
}

class PairingTokensTableCompanion extends UpdateCompanion<PairingTokenEntry> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<String> displayName;
  final Value<String> roleCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> expiresAt;
  final Value<bool> isUsed;
  final Value<int> rowid;
  const PairingTokensTableCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.roleCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.isUsed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PairingTokensTableCompanion.insert({
    required String id,
    required String deviceId,
    required String displayName,
    required String roleCode,
    required DateTime createdAt,
    required DateTime expiresAt,
    this.isUsed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       displayName = Value(displayName),
       roleCode = Value(roleCode),
       createdAt = Value(createdAt),
       expiresAt = Value(expiresAt);
  static Insertable<PairingTokenEntry> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<String>? displayName,
    Expression<String>? roleCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
    Expression<bool>? isUsed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (displayName != null) 'display_name': displayName,
      if (roleCode != null) 'role_code': roleCode,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (isUsed != null) 'is_used': isUsed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PairingTokensTableCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<String>? displayName,
    Value<String>? roleCode,
    Value<DateTime>? createdAt,
    Value<DateTime>? expiresAt,
    Value<bool>? isUsed,
    Value<int>? rowid,
  }) {
    return PairingTokensTableCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      displayName: displayName ?? this.displayName,
      roleCode: roleCode ?? this.roleCode,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isUsed: isUsed ?? this.isUsed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (roleCode.present) {
      map['role_code'] = Variable<String>(roleCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (isUsed.present) {
      map['is_used'] = Variable<bool>(isUsed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PairingTokensTableCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('displayName: $displayName, ')
          ..write('roleCode: $roleCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isUsed: $isUsed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTableTable extends SyncConflictsTable
    with TableInfo<$SyncConflictsTableTable, SyncConflictEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conflictTypeMeta = const VerificationMeta(
    'conflictType',
  );
  @override
  late final GeneratedColumn<String> conflictType = GeneratedColumn<String>(
    'conflict_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winningDeviceIdMeta = const VerificationMeta(
    'winningDeviceId',
  );
  @override
  late final GeneratedColumn<String> winningDeviceId = GeneratedColumn<String>(
    'winning_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winningDeviceNameMeta = const VerificationMeta(
    'winningDeviceName',
  );
  @override
  late final GeneratedColumn<String> winningDeviceName =
      GeneratedColumn<String>(
        'winning_device_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _losingDeviceIdMeta = const VerificationMeta(
    'losingDeviceId',
  );
  @override
  late final GeneratedColumn<String> losingDeviceId = GeneratedColumn<String>(
    'losing_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _losingDeviceNameMeta = const VerificationMeta(
    'losingDeviceName',
  );
  @override
  late final GeneratedColumn<String> losingDeviceName = GeneratedColumn<String>(
    'losing_device_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _losingProductJsonMeta = const VerificationMeta(
    'losingProductJson',
  );
  @override
  late final GeneratedColumn<String> losingProductJson =
      GeneratedColumn<String>(
        'losing_product_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isResolvedMeta = const VerificationMeta(
    'isResolved',
  );
  @override
  late final GeneratedColumn<bool> isResolved = GeneratedColumn<bool>(
    'is_resolved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_resolved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    productName,
    conflictType,
    winningDeviceId,
    winningDeviceName,
    losingDeviceId,
    losingDeviceName,
    losingProductJson,
    reason,
    occurredAt,
    isResolved,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflictEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('conflict_type')) {
      context.handle(
        _conflictTypeMeta,
        conflictType.isAcceptableOrUnknown(
          data['conflict_type']!,
          _conflictTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conflictTypeMeta);
    }
    if (data.containsKey('winning_device_id')) {
      context.handle(
        _winningDeviceIdMeta,
        winningDeviceId.isAcceptableOrUnknown(
          data['winning_device_id']!,
          _winningDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_winningDeviceIdMeta);
    }
    if (data.containsKey('winning_device_name')) {
      context.handle(
        _winningDeviceNameMeta,
        winningDeviceName.isAcceptableOrUnknown(
          data['winning_device_name']!,
          _winningDeviceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_winningDeviceNameMeta);
    }
    if (data.containsKey('losing_device_id')) {
      context.handle(
        _losingDeviceIdMeta,
        losingDeviceId.isAcceptableOrUnknown(
          data['losing_device_id']!,
          _losingDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_losingDeviceIdMeta);
    }
    if (data.containsKey('losing_device_name')) {
      context.handle(
        _losingDeviceNameMeta,
        losingDeviceName.isAcceptableOrUnknown(
          data['losing_device_name']!,
          _losingDeviceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_losingDeviceNameMeta);
    }
    if (data.containsKey('losing_product_json')) {
      context.handle(
        _losingProductJsonMeta,
        losingProductJson.isAcceptableOrUnknown(
          data['losing_product_json']!,
          _losingProductJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_losingProductJsonMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('is_resolved')) {
      context.handle(
        _isResolvedMeta,
        isResolved.isAcceptableOrUnknown(data['is_resolved']!, _isResolvedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflictEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflictEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      conflictType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_type'],
      )!,
      winningDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winning_device_id'],
      )!,
      winningDeviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winning_device_name'],
      )!,
      losingDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}losing_device_id'],
      )!,
      losingDeviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}losing_device_name'],
      )!,
      losingProductJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}losing_product_json'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      isResolved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_resolved'],
      )!,
    );
  }

  @override
  $SyncConflictsTableTable createAlias(String alias) {
    return $SyncConflictsTableTable(attachedDatabase, alias);
  }
}

class SyncConflictEntry extends DataClass
    implements Insertable<SyncConflictEntry> {
  final String id;
  final String productId;
  final String productName;
  final String conflictType;
  final String winningDeviceId;
  final String winningDeviceName;
  final String losingDeviceId;
  final String losingDeviceName;
  final String losingProductJson;
  final String reason;
  final DateTime occurredAt;
  final bool isResolved;
  const SyncConflictEntry({
    required this.id,
    required this.productId,
    required this.productName,
    required this.conflictType,
    required this.winningDeviceId,
    required this.winningDeviceName,
    required this.losingDeviceId,
    required this.losingDeviceName,
    required this.losingProductJson,
    required this.reason,
    required this.occurredAt,
    required this.isResolved,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['conflict_type'] = Variable<String>(conflictType);
    map['winning_device_id'] = Variable<String>(winningDeviceId);
    map['winning_device_name'] = Variable<String>(winningDeviceName);
    map['losing_device_id'] = Variable<String>(losingDeviceId);
    map['losing_device_name'] = Variable<String>(losingDeviceName);
    map['losing_product_json'] = Variable<String>(losingProductJson);
    map['reason'] = Variable<String>(reason);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['is_resolved'] = Variable<bool>(isResolved);
    return map;
  }

  SyncConflictsTableCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsTableCompanion(
      id: Value(id),
      productId: Value(productId),
      productName: Value(productName),
      conflictType: Value(conflictType),
      winningDeviceId: Value(winningDeviceId),
      winningDeviceName: Value(winningDeviceName),
      losingDeviceId: Value(losingDeviceId),
      losingDeviceName: Value(losingDeviceName),
      losingProductJson: Value(losingProductJson),
      reason: Value(reason),
      occurredAt: Value(occurredAt),
      isResolved: Value(isResolved),
    );
  }

  factory SyncConflictEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflictEntry(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      conflictType: serializer.fromJson<String>(json['conflictType']),
      winningDeviceId: serializer.fromJson<String>(json['winningDeviceId']),
      winningDeviceName: serializer.fromJson<String>(json['winningDeviceName']),
      losingDeviceId: serializer.fromJson<String>(json['losingDeviceId']),
      losingDeviceName: serializer.fromJson<String>(json['losingDeviceName']),
      losingProductJson: serializer.fromJson<String>(json['losingProductJson']),
      reason: serializer.fromJson<String>(json['reason']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      isResolved: serializer.fromJson<bool>(json['isResolved']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'conflictType': serializer.toJson<String>(conflictType),
      'winningDeviceId': serializer.toJson<String>(winningDeviceId),
      'winningDeviceName': serializer.toJson<String>(winningDeviceName),
      'losingDeviceId': serializer.toJson<String>(losingDeviceId),
      'losingDeviceName': serializer.toJson<String>(losingDeviceName),
      'losingProductJson': serializer.toJson<String>(losingProductJson),
      'reason': serializer.toJson<String>(reason),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'isResolved': serializer.toJson<bool>(isResolved),
    };
  }

  SyncConflictEntry copyWith({
    String? id,
    String? productId,
    String? productName,
    String? conflictType,
    String? winningDeviceId,
    String? winningDeviceName,
    String? losingDeviceId,
    String? losingDeviceName,
    String? losingProductJson,
    String? reason,
    DateTime? occurredAt,
    bool? isResolved,
  }) => SyncConflictEntry(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    conflictType: conflictType ?? this.conflictType,
    winningDeviceId: winningDeviceId ?? this.winningDeviceId,
    winningDeviceName: winningDeviceName ?? this.winningDeviceName,
    losingDeviceId: losingDeviceId ?? this.losingDeviceId,
    losingDeviceName: losingDeviceName ?? this.losingDeviceName,
    losingProductJson: losingProductJson ?? this.losingProductJson,
    reason: reason ?? this.reason,
    occurredAt: occurredAt ?? this.occurredAt,
    isResolved: isResolved ?? this.isResolved,
  );
  SyncConflictEntry copyWithCompanion(SyncConflictsTableCompanion data) {
    return SyncConflictEntry(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      conflictType: data.conflictType.present
          ? data.conflictType.value
          : this.conflictType,
      winningDeviceId: data.winningDeviceId.present
          ? data.winningDeviceId.value
          : this.winningDeviceId,
      winningDeviceName: data.winningDeviceName.present
          ? data.winningDeviceName.value
          : this.winningDeviceName,
      losingDeviceId: data.losingDeviceId.present
          ? data.losingDeviceId.value
          : this.losingDeviceId,
      losingDeviceName: data.losingDeviceName.present
          ? data.losingDeviceName.value
          : this.losingDeviceName,
      losingProductJson: data.losingProductJson.present
          ? data.losingProductJson.value
          : this.losingProductJson,
      reason: data.reason.present ? data.reason.value : this.reason,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      isResolved: data.isResolved.present
          ? data.isResolved.value
          : this.isResolved,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictEntry(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('conflictType: $conflictType, ')
          ..write('winningDeviceId: $winningDeviceId, ')
          ..write('winningDeviceName: $winningDeviceName, ')
          ..write('losingDeviceId: $losingDeviceId, ')
          ..write('losingDeviceName: $losingDeviceName, ')
          ..write('losingProductJson: $losingProductJson, ')
          ..write('reason: $reason, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('isResolved: $isResolved')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    productName,
    conflictType,
    winningDeviceId,
    winningDeviceName,
    losingDeviceId,
    losingDeviceName,
    losingProductJson,
    reason,
    occurredAt,
    isResolved,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflictEntry &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.conflictType == this.conflictType &&
          other.winningDeviceId == this.winningDeviceId &&
          other.winningDeviceName == this.winningDeviceName &&
          other.losingDeviceId == this.losingDeviceId &&
          other.losingDeviceName == this.losingDeviceName &&
          other.losingProductJson == this.losingProductJson &&
          other.reason == this.reason &&
          other.occurredAt == this.occurredAt &&
          other.isResolved == this.isResolved);
}

class SyncConflictsTableCompanion extends UpdateCompanion<SyncConflictEntry> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> productName;
  final Value<String> conflictType;
  final Value<String> winningDeviceId;
  final Value<String> winningDeviceName;
  final Value<String> losingDeviceId;
  final Value<String> losingDeviceName;
  final Value<String> losingProductJson;
  final Value<String> reason;
  final Value<DateTime> occurredAt;
  final Value<bool> isResolved;
  final Value<int> rowid;
  const SyncConflictsTableCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.conflictType = const Value.absent(),
    this.winningDeviceId = const Value.absent(),
    this.winningDeviceName = const Value.absent(),
    this.losingDeviceId = const Value.absent(),
    this.losingDeviceName = const Value.absent(),
    this.losingProductJson = const Value.absent(),
    this.reason = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.isResolved = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsTableCompanion.insert({
    required String id,
    required String productId,
    required String productName,
    required String conflictType,
    required String winningDeviceId,
    required String winningDeviceName,
    required String losingDeviceId,
    required String losingDeviceName,
    required String losingProductJson,
    required String reason,
    required DateTime occurredAt,
    this.isResolved = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       productName = Value(productName),
       conflictType = Value(conflictType),
       winningDeviceId = Value(winningDeviceId),
       winningDeviceName = Value(winningDeviceName),
       losingDeviceId = Value(losingDeviceId),
       losingDeviceName = Value(losingDeviceName),
       losingProductJson = Value(losingProductJson),
       reason = Value(reason),
       occurredAt = Value(occurredAt);
  static Insertable<SyncConflictEntry> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<String>? conflictType,
    Expression<String>? winningDeviceId,
    Expression<String>? winningDeviceName,
    Expression<String>? losingDeviceId,
    Expression<String>? losingDeviceName,
    Expression<String>? losingProductJson,
    Expression<String>? reason,
    Expression<DateTime>? occurredAt,
    Expression<bool>? isResolved,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (conflictType != null) 'conflict_type': conflictType,
      if (winningDeviceId != null) 'winning_device_id': winningDeviceId,
      if (winningDeviceName != null) 'winning_device_name': winningDeviceName,
      if (losingDeviceId != null) 'losing_device_id': losingDeviceId,
      if (losingDeviceName != null) 'losing_device_name': losingDeviceName,
      if (losingProductJson != null) 'losing_product_json': losingProductJson,
      if (reason != null) 'reason': reason,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (isResolved != null) 'is_resolved': isResolved,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? productName,
    Value<String>? conflictType,
    Value<String>? winningDeviceId,
    Value<String>? winningDeviceName,
    Value<String>? losingDeviceId,
    Value<String>? losingDeviceName,
    Value<String>? losingProductJson,
    Value<String>? reason,
    Value<DateTime>? occurredAt,
    Value<bool>? isResolved,
    Value<int>? rowid,
  }) {
    return SyncConflictsTableCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      conflictType: conflictType ?? this.conflictType,
      winningDeviceId: winningDeviceId ?? this.winningDeviceId,
      winningDeviceName: winningDeviceName ?? this.winningDeviceName,
      losingDeviceId: losingDeviceId ?? this.losingDeviceId,
      losingDeviceName: losingDeviceName ?? this.losingDeviceName,
      losingProductJson: losingProductJson ?? this.losingProductJson,
      reason: reason ?? this.reason,
      occurredAt: occurredAt ?? this.occurredAt,
      isResolved: isResolved ?? this.isResolved,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (conflictType.present) {
      map['conflict_type'] = Variable<String>(conflictType.value);
    }
    if (winningDeviceId.present) {
      map['winning_device_id'] = Variable<String>(winningDeviceId.value);
    }
    if (winningDeviceName.present) {
      map['winning_device_name'] = Variable<String>(winningDeviceName.value);
    }
    if (losingDeviceId.present) {
      map['losing_device_id'] = Variable<String>(losingDeviceId.value);
    }
    if (losingDeviceName.present) {
      map['losing_device_name'] = Variable<String>(losingDeviceName.value);
    }
    if (losingProductJson.present) {
      map['losing_product_json'] = Variable<String>(losingProductJson.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (isResolved.present) {
      map['is_resolved'] = Variable<bool>(isResolved.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsTableCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('conflictType: $conflictType, ')
          ..write('winningDeviceId: $winningDeviceId, ')
          ..write('winningDeviceName: $winningDeviceName, ')
          ..write('losingDeviceId: $losingDeviceId, ')
          ..write('losingDeviceName: $losingDeviceName, ')
          ..write('losingProductJson: $losingProductJson, ')
          ..write('reason: $reason, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('isResolved: $isResolved, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTableTable productsTable = $ProductsTableTable(this);
  late final $CompositionsTableTable compositionsTable =
      $CompositionsTableTable(this);
  late final $AdditionalIngredientsTableTable additionalIngredientsTable =
      $AdditionalIngredientsTableTable(this);
  late final $DevicesTableTable devicesTable = $DevicesTableTable(this);
  late final $WorkspacesTableTable workspacesTable = $WorkspacesTableTable(
    this,
  );
  late final $PairingTokensTableTable pairingTokensTable =
      $PairingTokensTableTable(this);
  late final $SyncConflictsTableTable syncConflictsTable =
      $SyncConflictsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    productsTable,
    compositionsTable,
    additionalIngredientsTable,
    devicesTable,
    workspacesTable,
    pairingTokensTable,
    syncConflictsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'products',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('compositions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'products',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('additional_ingredients', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProductsTableTableCreateCompanionBuilder =
    ProductsTableCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required String productTypeCode,
      required String createdByDeviceId,
      required String createdByDisplayName,
      Value<String?> updatedByDeviceId,
      Value<String?> updatedByDisplayName,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isDeleted,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$ProductsTableTableUpdateCompanionBuilder =
    ProductsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String> productTypeCode,
      Value<String> createdByDeviceId,
      Value<String> createdByDisplayName,
      Value<String?> updatedByDeviceId,
      Value<String?> updatedByDisplayName,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<int> version,
      Value<int> rowid,
    });

final class $$ProductsTableTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTableTable, ProductEntry> {
  $$ProductsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CompositionsTableTable, List<CompositionEntry>>
  _compositionsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.compositionsTable,
        aliasName: $_aliasNameGenerator(
          db.productsTable.id,
          db.compositionsTable.productId,
        ),
      );

  $$CompositionsTableTableProcessedTableManager get compositionsTableRefs {
    final manager = $$CompositionsTableTableTableManager(
      $_db,
      $_db.compositionsTable,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _compositionsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AdditionalIngredientsTableTable,
    List<AdditionalIngredientEntry>
  >
  _additionalIngredientsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.additionalIngredientsTable,
        aliasName: $_aliasNameGenerator(
          db.productsTable.id,
          db.additionalIngredientsTable.productId,
        ),
      );

  $$AdditionalIngredientsTableTableProcessedTableManager
  get additionalIngredientsTableRefs {
    final manager = $$AdditionalIngredientsTableTableTableManager(
      $_db,
      $_db.additionalIngredientsTable,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _additionalIngredientsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productTypeCode => $composableBuilder(
    column: $table.productTypeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByDeviceId => $composableBuilder(
    column: $table.createdByDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByDisplayName => $composableBuilder(
    column: $table.createdByDisplayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDeviceId => $composableBuilder(
    column: $table.updatedByDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByDisplayName => $composableBuilder(
    column: $table.updatedByDisplayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> compositionsTableRefs(
    Expression<bool> Function($$CompositionsTableTableFilterComposer f) f,
  ) {
    final $$CompositionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compositionsTable,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompositionsTableTableFilterComposer(
            $db: $db,
            $table: $db.compositionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> additionalIngredientsTableRefs(
    Expression<bool> Function($$AdditionalIngredientsTableTableFilterComposer f)
    f,
  ) {
    final $$AdditionalIngredientsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.additionalIngredientsTable,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AdditionalIngredientsTableTableFilterComposer(
                $db: $db,
                $table: $db.additionalIngredientsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProductsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productTypeCode => $composableBuilder(
    column: $table.productTypeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByDeviceId => $composableBuilder(
    column: $table.createdByDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByDisplayName => $composableBuilder(
    column: $table.createdByDisplayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDeviceId => $composableBuilder(
    column: $table.updatedByDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByDisplayName => $composableBuilder(
    column: $table.updatedByDisplayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productTypeCode => $composableBuilder(
    column: $table.productTypeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdByDeviceId => $composableBuilder(
    column: $table.createdByDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdByDisplayName => $composableBuilder(
    column: $table.createdByDisplayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDeviceId => $composableBuilder(
    column: $table.updatedByDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByDisplayName => $composableBuilder(
    column: $table.updatedByDisplayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  Expression<T> compositionsTableRefs<T extends Object>(
    Expression<T> Function($$CompositionsTableTableAnnotationComposer a) f,
  ) {
    final $$CompositionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.compositionsTable,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompositionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.compositionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> additionalIngredientsTableRefs<T extends Object>(
    Expression<T> Function(
      $$AdditionalIngredientsTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$AdditionalIngredientsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.additionalIngredientsTable,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AdditionalIngredientsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.additionalIngredientsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProductsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTableTable,
          ProductEntry,
          $$ProductsTableTableFilterComposer,
          $$ProductsTableTableOrderingComposer,
          $$ProductsTableTableAnnotationComposer,
          $$ProductsTableTableCreateCompanionBuilder,
          $$ProductsTableTableUpdateCompanionBuilder,
          (ProductEntry, $$ProductsTableTableReferences),
          ProductEntry,
          PrefetchHooks Function({
            bool compositionsTableRefs,
            bool additionalIngredientsTableRefs,
          })
        > {
  $$ProductsTableTableTableManager(_$AppDatabase db, $ProductsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> productTypeCode = const Value.absent(),
                Value<String> createdByDeviceId = const Value.absent(),
                Value<String> createdByDisplayName = const Value.absent(),
                Value<String?> updatedByDeviceId = const Value.absent(),
                Value<String?> updatedByDisplayName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsTableCompanion(
                id: id,
                name: name,
                description: description,
                productTypeCode: productTypeCode,
                createdByDeviceId: createdByDeviceId,
                createdByDisplayName: createdByDisplayName,
                updatedByDeviceId: updatedByDeviceId,
                updatedByDisplayName: updatedByDisplayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required String productTypeCode,
                required String createdByDeviceId,
                required String createdByDisplayName,
                Value<String?> updatedByDeviceId = const Value.absent(),
                Value<String?> updatedByDisplayName = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsTableCompanion.insert(
                id: id,
                name: name,
                description: description,
                productTypeCode: productTypeCode,
                createdByDeviceId: createdByDeviceId,
                createdByDisplayName: createdByDisplayName,
                updatedByDeviceId: updatedByDeviceId,
                updatedByDisplayName: updatedByDisplayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                compositionsTableRefs = false,
                additionalIngredientsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (compositionsTableRefs) db.compositionsTable,
                    if (additionalIngredientsTableRefs)
                      db.additionalIngredientsTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (compositionsTableRefs)
                        await $_getPrefetchedData<
                          ProductEntry,
                          $ProductsTableTable,
                          CompositionEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableTableReferences
                              ._compositionsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).compositionsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (additionalIngredientsTableRefs)
                        await $_getPrefetchedData<
                          ProductEntry,
                          $ProductsTableTable,
                          AdditionalIngredientEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableTableReferences
                              ._additionalIngredientsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).additionalIngredientsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTableTable,
      ProductEntry,
      $$ProductsTableTableFilterComposer,
      $$ProductsTableTableOrderingComposer,
      $$ProductsTableTableAnnotationComposer,
      $$ProductsTableTableCreateCompanionBuilder,
      $$ProductsTableTableUpdateCompanionBuilder,
      (ProductEntry, $$ProductsTableTableReferences),
      ProductEntry,
      PrefetchHooks Function({
        bool compositionsTableRefs,
        bool additionalIngredientsTableRefs,
      })
    >;
typedef $$CompositionsTableTableCreateCompanionBuilder =
    CompositionsTableCompanion Function({
      required String id,
      required String productId,
      required String componentName,
      required double percentage,
      Value<String?> notes,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CompositionsTableTableUpdateCompanionBuilder =
    CompositionsTableCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> componentName,
      Value<double> percentage,
      Value<String?> notes,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$CompositionsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CompositionsTableTable,
          CompositionEntry
        > {
  $$CompositionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTableTable _productIdTable(_$AppDatabase db) =>
      db.productsTable.createAlias(
        $_aliasNameGenerator(
          db.compositionsTable.productId,
          db.productsTable.id,
        ),
      );

  $$ProductsTableTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableTableManager(
      $_db,
      $_db.productsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompositionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CompositionsTableTable> {
  $$CompositionsTableTableFilterComposer({
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

  ColumnFilters<String> get componentName => $composableBuilder(
    column: $table.componentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableTableFilterComposer get productId {
    final $$ProductsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableFilterComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompositionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CompositionsTableTable> {
  $$CompositionsTableTableOrderingComposer({
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

  ColumnOrderings<String> get componentName => $composableBuilder(
    column: $table.componentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableTableOrderingComposer get productId {
    final $$ProductsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableOrderingComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompositionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompositionsTableTable> {
  $$CompositionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get componentName => $composableBuilder(
    column: $table.componentName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$ProductsTableTableAnnotationComposer get productId {
    final $$ProductsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompositionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompositionsTableTable,
          CompositionEntry,
          $$CompositionsTableTableFilterComposer,
          $$CompositionsTableTableOrderingComposer,
          $$CompositionsTableTableAnnotationComposer,
          $$CompositionsTableTableCreateCompanionBuilder,
          $$CompositionsTableTableUpdateCompanionBuilder,
          (CompositionEntry, $$CompositionsTableTableReferences),
          CompositionEntry,
          PrefetchHooks Function({bool productId})
        > {
  $$CompositionsTableTableTableManager(
    _$AppDatabase db,
    $CompositionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompositionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompositionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompositionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> componentName = const Value.absent(),
                Value<double> percentage = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompositionsTableCompanion(
                id: id,
                productId: productId,
                componentName: componentName,
                percentage: percentage,
                notes: notes,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String componentName,
                required double percentage,
                Value<String?> notes = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompositionsTableCompanion.insert(
                id: id,
                productId: productId,
                componentName: componentName,
                percentage: percentage,
                notes: notes,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompositionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
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
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable:
                                    $$CompositionsTableTableReferences
                                        ._productIdTable(db),
                                referencedColumn:
                                    $$CompositionsTableTableReferences
                                        ._productIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$CompositionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompositionsTableTable,
      CompositionEntry,
      $$CompositionsTableTableFilterComposer,
      $$CompositionsTableTableOrderingComposer,
      $$CompositionsTableTableAnnotationComposer,
      $$CompositionsTableTableCreateCompanionBuilder,
      $$CompositionsTableTableUpdateCompanionBuilder,
      (CompositionEntry, $$CompositionsTableTableReferences),
      CompositionEntry,
      PrefetchHooks Function({bool productId})
    >;
typedef $$AdditionalIngredientsTableTableCreateCompanionBuilder =
    AdditionalIngredientsTableCompanion Function({
      required String id,
      required String productId,
      required String ingredientName,
      required double quantity,
      required String unit,
      Value<String?> notes,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$AdditionalIngredientsTableTableUpdateCompanionBuilder =
    AdditionalIngredientsTableCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> ingredientName,
      Value<double> quantity,
      Value<String> unit,
      Value<String?> notes,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$AdditionalIngredientsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AdditionalIngredientsTableTable,
          AdditionalIngredientEntry
        > {
  $$AdditionalIngredientsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTableTable _productIdTable(_$AppDatabase db) =>
      db.productsTable.createAlias(
        $_aliasNameGenerator(
          db.additionalIngredientsTable.productId,
          db.productsTable.id,
        ),
      );

  $$ProductsTableTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableTableManager(
      $_db,
      $_db.productsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AdditionalIngredientsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AdditionalIngredientsTableTable> {
  $$AdditionalIngredientsTableTableFilterComposer({
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

  ColumnFilters<String> get ingredientName => $composableBuilder(
    column: $table.ingredientName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableTableFilterComposer get productId {
    final $$ProductsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableFilterComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdditionalIngredientsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AdditionalIngredientsTableTable> {
  $$AdditionalIngredientsTableTableOrderingComposer({
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

  ColumnOrderings<String> get ingredientName => $composableBuilder(
    column: $table.ingredientName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableTableOrderingComposer get productId {
    final $$ProductsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableOrderingComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdditionalIngredientsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdditionalIngredientsTableTable> {
  $$AdditionalIngredientsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ingredientName => $composableBuilder(
    column: $table.ingredientName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$ProductsTableTableAnnotationComposer get productId {
    final $$ProductsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdditionalIngredientsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdditionalIngredientsTableTable,
          AdditionalIngredientEntry,
          $$AdditionalIngredientsTableTableFilterComposer,
          $$AdditionalIngredientsTableTableOrderingComposer,
          $$AdditionalIngredientsTableTableAnnotationComposer,
          $$AdditionalIngredientsTableTableCreateCompanionBuilder,
          $$AdditionalIngredientsTableTableUpdateCompanionBuilder,
          (
            AdditionalIngredientEntry,
            $$AdditionalIngredientsTableTableReferences,
          ),
          AdditionalIngredientEntry,
          PrefetchHooks Function({bool productId})
        > {
  $$AdditionalIngredientsTableTableTableManager(
    _$AppDatabase db,
    $AdditionalIngredientsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdditionalIngredientsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AdditionalIngredientsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AdditionalIngredientsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> ingredientName = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdditionalIngredientsTableCompanion(
                id: id,
                productId: productId,
                ingredientName: ingredientName,
                quantity: quantity,
                unit: unit,
                notes: notes,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String ingredientName,
                required double quantity,
                required String unit,
                Value<String?> notes = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdditionalIngredientsTableCompanion.insert(
                id: id,
                productId: productId,
                ingredientName: ingredientName,
                quantity: quantity,
                unit: unit,
                notes: notes,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AdditionalIngredientsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
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
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable:
                                    $$AdditionalIngredientsTableTableReferences
                                        ._productIdTable(db),
                                referencedColumn:
                                    $$AdditionalIngredientsTableTableReferences
                                        ._productIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$AdditionalIngredientsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdditionalIngredientsTableTable,
      AdditionalIngredientEntry,
      $$AdditionalIngredientsTableTableFilterComposer,
      $$AdditionalIngredientsTableTableOrderingComposer,
      $$AdditionalIngredientsTableTableAnnotationComposer,
      $$AdditionalIngredientsTableTableCreateCompanionBuilder,
      $$AdditionalIngredientsTableTableUpdateCompanionBuilder,
      (AdditionalIngredientEntry, $$AdditionalIngredientsTableTableReferences),
      AdditionalIngredientEntry,
      PrefetchHooks Function({bool productId})
    >;
typedef $$DevicesTableTableCreateCompanionBuilder =
    DevicesTableCompanion Function({
      required String id,
      required String displayName,
      required String roleCode,
      required DateTime pairedAt,
      required DateTime lastSeenAt,
      Value<bool> isRevoked,
      Value<int> rowid,
    });
typedef $$DevicesTableTableUpdateCompanionBuilder =
    DevicesTableCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String> roleCode,
      Value<DateTime> pairedAt,
      Value<DateTime> lastSeenAt,
      Value<bool> isRevoked,
      Value<int> rowid,
    });

class $$DevicesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTableTable> {
  $$DevicesTableTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleCode => $composableBuilder(
    column: $table.roleCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRevoked => $composableBuilder(
    column: $table.isRevoked,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTableTable> {
  $$DevicesTableTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleCode => $composableBuilder(
    column: $table.roleCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRevoked => $composableBuilder(
    column: $table.isRevoked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTableTable> {
  $$DevicesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roleCode =>
      $composableBuilder(column: $table.roleCode, builder: (column) => column);

  GeneratedColumn<DateTime> get pairedAt =>
      $composableBuilder(column: $table.pairedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRevoked =>
      $composableBuilder(column: $table.isRevoked, builder: (column) => column);
}

class $$DevicesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTableTable,
          DeviceEntry,
          $$DevicesTableTableFilterComposer,
          $$DevicesTableTableOrderingComposer,
          $$DevicesTableTableAnnotationComposer,
          $$DevicesTableTableCreateCompanionBuilder,
          $$DevicesTableTableUpdateCompanionBuilder,
          (
            DeviceEntry,
            BaseReferences<_$AppDatabase, $DevicesTableTable, DeviceEntry>,
          ),
          DeviceEntry,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableTableManager(_$AppDatabase db, $DevicesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> roleCode = const Value.absent(),
                Value<DateTime> pairedAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<bool> isRevoked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesTableCompanion(
                id: id,
                displayName: displayName,
                roleCode: roleCode,
                pairedAt: pairedAt,
                lastSeenAt: lastSeenAt,
                isRevoked: isRevoked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required String roleCode,
                required DateTime pairedAt,
                required DateTime lastSeenAt,
                Value<bool> isRevoked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesTableCompanion.insert(
                id: id,
                displayName: displayName,
                roleCode: roleCode,
                pairedAt: pairedAt,
                lastSeenAt: lastSeenAt,
                isRevoked: isRevoked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTableTable,
      DeviceEntry,
      $$DevicesTableTableFilterComposer,
      $$DevicesTableTableOrderingComposer,
      $$DevicesTableTableAnnotationComposer,
      $$DevicesTableTableCreateCompanionBuilder,
      $$DevicesTableTableUpdateCompanionBuilder,
      (
        DeviceEntry,
        BaseReferences<_$AppDatabase, $DevicesTableTable, DeviceEntry>,
      ),
      DeviceEntry,
      PrefetchHooks Function()
    >;
typedef $$WorkspacesTableTableCreateCompanionBuilder =
    WorkspacesTableCompanion Function({
      required String id,
      required String name,
      required String workspaceKey,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$WorkspacesTableTableUpdateCompanionBuilder =
    WorkspacesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> workspaceKey,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$WorkspacesTableTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspacesTableTable> {
  $$WorkspacesTableTableFilterComposer({
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

  ColumnFilters<String> get workspaceKey => $composableBuilder(
    column: $table.workspaceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkspacesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspacesTableTable> {
  $$WorkspacesTableTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceKey => $composableBuilder(
    column: $table.workspaceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspacesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspacesTableTable> {
  $$WorkspacesTableTableAnnotationComposer({
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

  GeneratedColumn<String> get workspaceKey => $composableBuilder(
    column: $table.workspaceKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WorkspacesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspacesTableTable,
          WorkspaceEntry,
          $$WorkspacesTableTableFilterComposer,
          $$WorkspacesTableTableOrderingComposer,
          $$WorkspacesTableTableAnnotationComposer,
          $$WorkspacesTableTableCreateCompanionBuilder,
          $$WorkspacesTableTableUpdateCompanionBuilder,
          (
            WorkspaceEntry,
            BaseReferences<
              _$AppDatabase,
              $WorkspacesTableTable,
              WorkspaceEntry
            >,
          ),
          WorkspaceEntry,
          PrefetchHooks Function()
        > {
  $$WorkspacesTableTableTableManager(
    _$AppDatabase db,
    $WorkspacesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspacesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspacesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspacesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> workspaceKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesTableCompanion(
                id: id,
                name: name,
                workspaceKey: workspaceKey,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String workspaceKey,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesTableCompanion.insert(
                id: id,
                name: name,
                workspaceKey: workspaceKey,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkspacesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspacesTableTable,
      WorkspaceEntry,
      $$WorkspacesTableTableFilterComposer,
      $$WorkspacesTableTableOrderingComposer,
      $$WorkspacesTableTableAnnotationComposer,
      $$WorkspacesTableTableCreateCompanionBuilder,
      $$WorkspacesTableTableUpdateCompanionBuilder,
      (
        WorkspaceEntry,
        BaseReferences<_$AppDatabase, $WorkspacesTableTable, WorkspaceEntry>,
      ),
      WorkspaceEntry,
      PrefetchHooks Function()
    >;
typedef $$PairingTokensTableTableCreateCompanionBuilder =
    PairingTokensTableCompanion Function({
      required String id,
      required String deviceId,
      required String displayName,
      required String roleCode,
      required DateTime createdAt,
      required DateTime expiresAt,
      Value<bool> isUsed,
      Value<int> rowid,
    });
typedef $$PairingTokensTableTableUpdateCompanionBuilder =
    PairingTokensTableCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<String> displayName,
      Value<String> roleCode,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
      Value<bool> isUsed,
      Value<int> rowid,
    });

class $$PairingTokensTableTableFilterComposer
    extends Composer<_$AppDatabase, $PairingTokensTableTable> {
  $$PairingTokensTableTableFilterComposer({
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

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleCode => $composableBuilder(
    column: $table.roleCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUsed => $composableBuilder(
    column: $table.isUsed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PairingTokensTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PairingTokensTableTable> {
  $$PairingTokensTableTableOrderingComposer({
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

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleCode => $composableBuilder(
    column: $table.roleCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUsed => $composableBuilder(
    column: $table.isUsed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PairingTokensTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PairingTokensTableTable> {
  $$PairingTokensTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roleCode =>
      $composableBuilder(column: $table.roleCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<bool> get isUsed =>
      $composableBuilder(column: $table.isUsed, builder: (column) => column);
}

class $$PairingTokensTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PairingTokensTableTable,
          PairingTokenEntry,
          $$PairingTokensTableTableFilterComposer,
          $$PairingTokensTableTableOrderingComposer,
          $$PairingTokensTableTableAnnotationComposer,
          $$PairingTokensTableTableCreateCompanionBuilder,
          $$PairingTokensTableTableUpdateCompanionBuilder,
          (
            PairingTokenEntry,
            BaseReferences<
              _$AppDatabase,
              $PairingTokensTableTable,
              PairingTokenEntry
            >,
          ),
          PairingTokenEntry,
          PrefetchHooks Function()
        > {
  $$PairingTokensTableTableTableManager(
    _$AppDatabase db,
    $PairingTokensTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PairingTokensTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PairingTokensTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PairingTokensTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> roleCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<bool> isUsed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PairingTokensTableCompanion(
                id: id,
                deviceId: deviceId,
                displayName: displayName,
                roleCode: roleCode,
                createdAt: createdAt,
                expiresAt: expiresAt,
                isUsed: isUsed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required String displayName,
                required String roleCode,
                required DateTime createdAt,
                required DateTime expiresAt,
                Value<bool> isUsed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PairingTokensTableCompanion.insert(
                id: id,
                deviceId: deviceId,
                displayName: displayName,
                roleCode: roleCode,
                createdAt: createdAt,
                expiresAt: expiresAt,
                isUsed: isUsed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PairingTokensTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PairingTokensTableTable,
      PairingTokenEntry,
      $$PairingTokensTableTableFilterComposer,
      $$PairingTokensTableTableOrderingComposer,
      $$PairingTokensTableTableAnnotationComposer,
      $$PairingTokensTableTableCreateCompanionBuilder,
      $$PairingTokensTableTableUpdateCompanionBuilder,
      (
        PairingTokenEntry,
        BaseReferences<
          _$AppDatabase,
          $PairingTokensTableTable,
          PairingTokenEntry
        >,
      ),
      PairingTokenEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableTableCreateCompanionBuilder =
    SyncConflictsTableCompanion Function({
      required String id,
      required String productId,
      required String productName,
      required String conflictType,
      required String winningDeviceId,
      required String winningDeviceName,
      required String losingDeviceId,
      required String losingDeviceName,
      required String losingProductJson,
      required String reason,
      required DateTime occurredAt,
      Value<bool> isResolved,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableTableUpdateCompanionBuilder =
    SyncConflictsTableCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> productName,
      Value<String> conflictType,
      Value<String> winningDeviceId,
      Value<String> winningDeviceName,
      Value<String> losingDeviceId,
      Value<String> losingDeviceName,
      Value<String> losingProductJson,
      Value<String> reason,
      Value<DateTime> occurredAt,
      Value<bool> isResolved,
      Value<int> rowid,
    });

class $$SyncConflictsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTableTable> {
  $$SyncConflictsTableTableFilterComposer({
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

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictType => $composableBuilder(
    column: $table.conflictType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winningDeviceId => $composableBuilder(
    column: $table.winningDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winningDeviceName => $composableBuilder(
    column: $table.winningDeviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get losingDeviceId => $composableBuilder(
    column: $table.losingDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get losingDeviceName => $composableBuilder(
    column: $table.losingDeviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get losingProductJson => $composableBuilder(
    column: $table.losingProductJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isResolved => $composableBuilder(
    column: $table.isResolved,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTableTable> {
  $$SyncConflictsTableTableOrderingComposer({
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

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictType => $composableBuilder(
    column: $table.conflictType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winningDeviceId => $composableBuilder(
    column: $table.winningDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winningDeviceName => $composableBuilder(
    column: $table.winningDeviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get losingDeviceId => $composableBuilder(
    column: $table.losingDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get losingDeviceName => $composableBuilder(
    column: $table.losingDeviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get losingProductJson => $composableBuilder(
    column: $table.losingProductJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isResolved => $composableBuilder(
    column: $table.isResolved,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTableTable> {
  $$SyncConflictsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conflictType => $composableBuilder(
    column: $table.conflictType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get winningDeviceId => $composableBuilder(
    column: $table.winningDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get winningDeviceName => $composableBuilder(
    column: $table.winningDeviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get losingDeviceId => $composableBuilder(
    column: $table.losingDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get losingDeviceName => $composableBuilder(
    column: $table.losingDeviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get losingProductJson => $composableBuilder(
    column: $table.losingProductJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isResolved => $composableBuilder(
    column: $table.isResolved,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTableTable,
          SyncConflictEntry,
          $$SyncConflictsTableTableFilterComposer,
          $$SyncConflictsTableTableOrderingComposer,
          $$SyncConflictsTableTableAnnotationComposer,
          $$SyncConflictsTableTableCreateCompanionBuilder,
          $$SyncConflictsTableTableUpdateCompanionBuilder,
          (
            SyncConflictEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncConflictsTableTable,
              SyncConflictEntry
            >,
          ),
          SyncConflictEntry,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableTableManager(
    _$AppDatabase db,
    $SyncConflictsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String> conflictType = const Value.absent(),
                Value<String> winningDeviceId = const Value.absent(),
                Value<String> winningDeviceName = const Value.absent(),
                Value<String> losingDeviceId = const Value.absent(),
                Value<String> losingDeviceName = const Value.absent(),
                Value<String> losingProductJson = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<bool> isResolved = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsTableCompanion(
                id: id,
                productId: productId,
                productName: productName,
                conflictType: conflictType,
                winningDeviceId: winningDeviceId,
                winningDeviceName: winningDeviceName,
                losingDeviceId: losingDeviceId,
                losingDeviceName: losingDeviceName,
                losingProductJson: losingProductJson,
                reason: reason,
                occurredAt: occurredAt,
                isResolved: isResolved,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String productName,
                required String conflictType,
                required String winningDeviceId,
                required String winningDeviceName,
                required String losingDeviceId,
                required String losingDeviceName,
                required String losingProductJson,
                required String reason,
                required DateTime occurredAt,
                Value<bool> isResolved = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsTableCompanion.insert(
                id: id,
                productId: productId,
                productName: productName,
                conflictType: conflictType,
                winningDeviceId: winningDeviceId,
                winningDeviceName: winningDeviceName,
                losingDeviceId: losingDeviceId,
                losingDeviceName: losingDeviceName,
                losingProductJson: losingProductJson,
                reason: reason,
                occurredAt: occurredAt,
                isResolved: isResolved,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTableTable,
      SyncConflictEntry,
      $$SyncConflictsTableTableFilterComposer,
      $$SyncConflictsTableTableOrderingComposer,
      $$SyncConflictsTableTableAnnotationComposer,
      $$SyncConflictsTableTableCreateCompanionBuilder,
      $$SyncConflictsTableTableUpdateCompanionBuilder,
      (
        SyncConflictEntry,
        BaseReferences<
          _$AppDatabase,
          $SyncConflictsTableTable,
          SyncConflictEntry
        >,
      ),
      SyncConflictEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db, _db.productsTable);
  $$CompositionsTableTableTableManager get compositionsTable =>
      $$CompositionsTableTableTableManager(_db, _db.compositionsTable);
  $$AdditionalIngredientsTableTableTableManager
  get additionalIngredientsTable =>
      $$AdditionalIngredientsTableTableTableManager(
        _db,
        _db.additionalIngredientsTable,
      );
  $$DevicesTableTableTableManager get devicesTable =>
      $$DevicesTableTableTableManager(_db, _db.devicesTable);
  $$WorkspacesTableTableTableManager get workspacesTable =>
      $$WorkspacesTableTableTableManager(_db, _db.workspacesTable);
  $$PairingTokensTableTableTableManager get pairingTokensTable =>
      $$PairingTokensTableTableTableManager(_db, _db.pairingTokensTable);
  $$SyncConflictsTableTableTableManager get syncConflictsTable =>
      $$SyncConflictsTableTableTableManager(_db, _db.syncConflictsTable);
}
