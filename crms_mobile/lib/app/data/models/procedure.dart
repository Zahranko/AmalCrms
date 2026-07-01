class Procedure {
  final int id;
  final String name;
  final bool isActive;

  Procedure({required this.id, required this.name, required this.isActive});

  factory Procedure.fromJson(Map<String, dynamic> json) => Procedure(
        id: json['id'] as int,
        name: json['name'] as String,
        isActive: json['isActive'] as bool,
      );
}
