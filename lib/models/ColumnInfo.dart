class ColumnInfo {
  final String name;
  final String type;
  final bool isPrimaryKey;
  final bool isNullable;

  ColumnInfo({
    required this.name,
    required this.type,
    this.isPrimaryKey = false,
    this.isNullable = true,
  });

  ColumnInfo copyWith({
    String? name,
    String? type,
    bool? isPrimaryKey,
    bool? isNullable,
  }) {
    return ColumnInfo(
      name: name ?? this.name,
      type: type ?? this.type,
      isPrimaryKey: isPrimaryKey ?? this.isPrimaryKey,
      isNullable: isNullable ?? this.isNullable,
    );
  }
}
