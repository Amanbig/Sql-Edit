class DatabaseInfo {
  final String name;
  final String path;
  final bool isOpen;

  DatabaseInfo({
    required this.name,
    required this.path,
    this.isOpen = false,
  });

  // Allows updating fields immutably
  DatabaseInfo copyWith({
    String? name,
    String? path,
    bool? isOpen,
  }) {
    return DatabaseInfo(
      name: name ?? this.name,
      path: path ?? this.path,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}
