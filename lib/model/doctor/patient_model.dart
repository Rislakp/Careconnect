class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String bloodGroup;
  final String phone;
  final String? lastVisit;
  final String condition;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.phone,
    this.lastVisit,
    required this.condition,
  });
}