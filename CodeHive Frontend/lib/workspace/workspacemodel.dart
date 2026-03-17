class WorkspaceModel {
  final String id;
  final String name;
  final String createdAt;

  WorkspaceModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) { // what does this factory  do
    return WorkspaceModel(
      id: json['_id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']).toString(),
    );
  }

}