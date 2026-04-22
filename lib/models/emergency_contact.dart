class EmergencyContact {
  final String name;
  final String phone;

  EmergencyContact({
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
      };
}