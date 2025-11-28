class Disponibilite {
  const Disponibilite({
    required this.medecinId,
    required this.date,
    required this.slots,
  });

  final String medecinId;
  final DateTime date;
  final List<DateTime> slots;
}


