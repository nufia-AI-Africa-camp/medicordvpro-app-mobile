import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/medecin.dart';
import '../application/appointment_creation_controller.dart';

class SelectDateTimeScreen extends ConsumerStatefulWidget {
  const SelectDateTimeScreen({
    super.key,
    required this.medecin,
  });

  final Medecin medecin;

  static const routeName = 'select-date-time';
  static const routePath = '/appointments/select-date-time';
  static const subRoutePath = '/select-date-time';

  @override
  ConsumerState<SelectDateTimeScreen> createState() =>
      _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends ConsumerState<SelectDateTimeScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _motifController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _motifController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 90)); // 3 mois à l'avance

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Sélectionner une date',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1D5BFF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Réinitialiser l'heure si on change de date
        if (_selectedTime != null) {
          final combined = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );
          if (combined.isBefore(now)) {
            _selectedTime = null;
          }
        }
      });
    }
  }

  Future<void> _selectTime() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez d\'abord sélectionner une date'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final initialTime = _selectedTime ?? TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Sélectionner une heure',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1D5BFF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final combined = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        picked.hour,
        picked.minute,
      );

      // Vérifier que la date/heure n'est pas dans le passé
      if (combined.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La date et l\'heure ne peuvent pas être dans le passé'),
          ),
        );
        return;
      }

      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createAppointment() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date et une heure'),
        ),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final controller = ref.read(appointmentCreationControllerProvider.notifier);
    
    try {
      await controller.createAppointment(
        medecinId: widget.medecin.id,
        dateTime: dateTime,
        motif: _motifController.text.isEmpty ? null : _motifController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        centreMedicalId: widget.medecin.centreMedicalId,
      );

      if (!mounted) return;

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rendez-vous créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      // Retourner à l'écran précédent
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D5BFF);
    final creationState = ref.watch(appointmentCreationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Date & Heure'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFFF5F7FF),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stepper header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _StepItem(
                    label: 'Médecin',
                    isActive: false,
                    isCompleted: true,
                    index: 1,
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      indent: 8,
                      endIndent: 8,
                    ),
                  ),
                  _StepItem(
                    label: 'Date & heure',
                    isActive: true,
                    isCompleted: false,
                    index: 2,
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      indent: 8,
                      endIndent: 8,
                    ),
                  ),
                  _StepItem(
                    label: 'Confirmation',
                    isActive: false,
                    isCompleted: false,
                    index: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Informations du médecin
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFE4ECFF),
                      backgroundImage: widget.medecin.photoProfil != null
                          ? NetworkImage(widget.medecin.photoProfil!)
                          : null,
                      child: widget.medecin.photoProfil == null
                          ? Text(
                              widget.medecin.fullName[0].toUpperCase(),
                              style: const TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. ${widget.medecin.fullName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.medecin.speciality,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (widget.medecin.centreMedicalNom != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.medecin.centreMedicalNom!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sélection de la date
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: primaryBlue),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDate != null
                                  ? _formatDate(_selectedDate!)
                                  : 'Sélectionner une date',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _selectedDate != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: _selectedDate != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sélection de l'heure
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: primaryBlue),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Heure',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedTime != null
                                  ? _selectedTime!.format(context)
                                  : 'Sélectionner une heure',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: _selectedTime != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: _selectedTime != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Motif de consultation
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Motif de consultation (optionnel)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _motifController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Consultation de routine, douleur...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F7),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes (optionnel)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Informations complémentaires...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F7),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Bouton de confirmation
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: creationState.isLoading ||
                        _selectedDate == null ||
                        _selectedTime == null
                    ? null
                    : _createAppointment,
                child: creationState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Confirmer le rendez-vous',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Message d'erreur
            if (creationState.errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          creationState.errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.label,
    required this.index,
    required this.isActive,
    required this.isCompleted,
  });

  final String label;
  final int index;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D5BFF);

    Color circleColor;
    Color textColor;

    if (isCompleted || isActive) {
      circleColor = primaryBlue;
      textColor = primaryBlue;
    } else {
      circleColor = Colors.grey.shade300;
      textColor = Colors.grey;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: circleColor,
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

