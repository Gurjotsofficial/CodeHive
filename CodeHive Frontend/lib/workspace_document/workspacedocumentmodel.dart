class WorkspaceDocumentModel {
  final String id;
  final String name;
  final String content;
  final DateTime updatedAt;

  WorkspaceDocumentModel({
    required this.id,
    required this.name,
    required this.content,
    required this.updatedAt,
  });

  factory WorkspaceDocumentModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceDocumentModel(
      id: json['_id'],
      name: json['name'],
      content: json['content'] ?? "",
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}