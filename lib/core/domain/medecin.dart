class Medecin {
  const Medecin({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.speciality,
    required this.centre,
    required this.address,
    this.tarif,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String speciality;
  final String centre;
  final String address;
  final double? tarif;
}


