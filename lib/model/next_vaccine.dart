// model/next_vaccine.dart
class NextVaccine {
  final String id;
  final String name;
  final int age;
  final DateTime vaccineDate;

  NextVaccine({
    required this.id,
    required this.name,
    required this.age,
    required this.vaccineDate,
  });

  // Convert NextVaccine to Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'vaccineDate': vaccineDate.toIso8601String(),
    };
  }

  // Create NextVaccine from Map
  factory NextVaccine.fromJson(Map<String, dynamic> json) {
    return NextVaccine(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      vaccineDate: DateTime.parse(json['vaccineDate']),
    );
  }
}