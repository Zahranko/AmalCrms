class Department {
  final int id;
  final String name;
  final bool isActive;

  Department({required this.id, required this.name, required this.isActive});

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        id: json['id'] as int,
        name: json['name'] as String,
        isActive: json['isActive'] as bool,
      );
}
