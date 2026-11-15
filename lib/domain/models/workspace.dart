class Workspace {
  final String id;
  final String name;
  final String workspaceKey;
  final DateTime createdAt;

  const Workspace({
    required this.id,
    required this.name,
    required this.workspaceKey,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'workspaceKey': workspaceKey,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Workspace.fromMap(Map<String, dynamic> map) {
    return Workspace(
      id: map['id'] as String,
      name: map['name'] as String,
      workspaceKey: map['workspaceKey'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
