class ParentProfile {
  final String id;
  String name;
  String parentType;
  String birthYear;
  String city;
  String photoPath;
  DateTime createdAt;

  ParentProfile({
    required this.id,
    required this.name,
    required this.parentType,
    this.birthYear = '',
    this.city = '',
    this.photoPath = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentType': parentType,
      'birthYear': birthYear,
      'city': city,
      'photoPath': photoPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ParentProfile.fromMap(Map<String, dynamic> map) {
    return ParentProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      parentType: map['parentType'] ?? '',
      birthYear: map['birthYear'] ?? '',
      city: map['city'] ?? '',
      photoPath: map['photoPath'] ?? '',
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
}
