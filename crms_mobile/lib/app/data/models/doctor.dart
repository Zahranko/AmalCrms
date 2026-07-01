class Doctor {
  final int id;
  final String name;
  final bool isActive;

  Doctor({required this.id, required this.name, required this.isActive});

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        id: json['id'] as int,
        name: json['name'] as String,
        isActive: json['isActive'] as bool,
      );
}
