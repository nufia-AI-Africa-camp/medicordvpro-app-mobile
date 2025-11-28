class Patient {
  const Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.birthDate,
    this.avatarUrl,
    this.address,
    this.city,
    this.postalCode,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final DateTime? birthDate;
  final String? avatarUrl;
  final String? address;
  final String? city;
  final String? postalCode;

  /// Nom complet du patient
  String get fullName => '$firstName $lastName';

  /// Crée une copie avec des valeurs modifiées
  Patient copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
    String? avatarUrl,
    String? address,
    String? city,
    String? postalCode,
  }) {
    return Patient(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
    );
  }
}


