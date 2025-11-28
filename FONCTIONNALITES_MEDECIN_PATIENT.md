# Fonctionnalités à Implémenter - Médecins et Patients

## 📋 Vue d'ensemble

Ce document liste toutes les fonctionnalités à mettre en place pour les **médecins** (`medecin_utilisateur_id`) et les **patients** (`patient_utilisateur_id`) après la connexion, basées sur la structure Supabase.

---

## 👨‍⚕️ FONCTIONNALITÉS MÉDECIN (`medecin_utilisateur_id`)

### 1. **Gestion du Profil Médecin**
- ✅ **Voir son profil** (`utilisateurs` WHERE `id = medecin_utilisateur_id`)
- ✅ **Modifier son profil** :
  - Informations personnelles (nom, prénom, email, téléphone, photo)
  - Spécialité (`specialite_id`)
  - Centre médical (`centre_medical_id`)
  - Numéro d'ordre (`numero_ordre`)
  - Tarif de consultation (`tarif_consultation`)
  - Bio (`bio`)
  - Années d'expérience (`annees_experience`)
  - Langues parlées (`langues_parlees`)
  - Accepter nouveaux patients (`accepte_nouveaux_patients`)

### 2. **Gestion des Horaires** (`horaires_medecins`)
- ✅ **Créer des horaires** par jour de la semaine
  - Jour (`jour`: lundi, mardi, mercredi, jeudi, vendredi, samedi, dimanche)
  - Heure de début (`heure_debut`)
  - Heure de fin (`heure_fin`)
  - Durée de consultation (`duree_consultation` en minutes)
  - Disponibilité (`is_available`)
- ✅ **Modifier des horaires existants**
- ✅ **Supprimer des horaires**
- ✅ **Voir tous ses horaires** (planning hebdomadaire)
- ✅ **Activer/Désactiver un créneau** (`is_available`)

### 3. **Gestion des Indisponibilités** (`indisponibilites`)
- ✅ **Créer une indisponibilité** :
  - Date de début (`date_debut`)
  - Date de fin (`date_fin`)
  - Raison (`raison`)
- ✅ **Voir toutes ses indisponibilités**
- ✅ **Modifier une indisponibilité**
- ✅ **Supprimer une indisponibilité**
- ⚠️ **Vérifier les conflits** avec les rendez-vous existants avant création

### 4. **Gestion des Rendez-vous** (`rendez_vous`)
- ✅ **Voir tous ses rendez-vous** (filtrés par `medecin_utilisateur_id`)
  - Filtrer par statut (`en_attente`, `confirmé`, `annulé`, `terminé`, `absent`)
  - Filtrer par date (aujourd'hui, cette semaine, ce mois)
  - Trier par date/heure
- ✅ **Voir les détails d'un rendez-vous** :
  - Informations patient
  - Date/heure
  - Motif de consultation
  - Notes patient
  - Statut
- ✅ **Confirmer un rendez-vous** (changer statut `en_attente` → `confirmé`)
- ✅ **Modifier un rendez-vous** :
  - Changer la date/heure (`date_heure`)
  - Modifier la durée (`duree`)
  - Ajouter/modifier les notes médecin (`notes_medecin`)
  - Changer le statut
- ✅ **Annuler un rendez-vous** (changer statut → `annulé`)
- ✅ **Marquer comme terminé** (changer statut → `terminé`)
- ✅ **Marquer comme absent** (changer statut → `absent`)
- ✅ **Voir le planning du jour** (agenda journalier)
- ✅ **Voir le planning de la semaine** (agenda hebdomadaire)

### 5. **Historique des Consultations** (`historique_consultations`)
- ✅ **Créer un historique après consultation** :
  - Lier au rendez-vous (`rendez_vous_id`)
  - Date de consultation (`date_consultation`)
  - Diagnostic (`diagnostic`)
  - Traitement (`traitement`)
  - Ordonnance (`ordonnance`)
  - Notes (`notes`)
  - Documents joints (`documents_joints` - URLs)
- ✅ **Voir l'historique d'un patient** (filtré par `patient_utilisateur_id`)
- ✅ **Modifier un historique existant**
- ✅ **Voir tous ses historiques de consultations**

### 6. **Notifications** (`notifications`)
- ✅ **Voir toutes ses notifications** (filtrées par `utilisateur_id`)
- ✅ **Marquer une notification comme lue** (`is_read = true`, `read_at = NOW()`)
- ✅ **Marquer toutes comme lues**
- ✅ **Filtrer par type** (`confirmation`, `rappel`, `annulation`, `modification`, `message`)
- ✅ **Voir les notifications non lues** (`is_read = false`)
- ✅ **Supprimer une notification**

### 7. **Statistiques et Rapports**
- ✅ **Statistiques générales** :
  - Total de rendez-vous
  - Rendez-vous confirmés
  - Rendez-vous annulés
  - Rendez-vous terminés
  - Patients uniques
  - Revenus totaux (`montant` dans `rendez_vous`)
- ✅ **Statistiques par période** (jour, semaine, mois, année)
- ✅ **Répartition par statut**
- ✅ **Répartition par spécialité** (si plusieurs spécialités)
- ✅ **Taux d'occupation** (créneaux occupés / créneaux disponibles)

### 8. **Recherche et Filtres**
- ✅ **Rechercher un patient** (par nom, prénom, email)
- ✅ **Voir la liste de ses patients** (patients ayant pris rendez-vous avec lui)
- ✅ **Voir les rendez-vous d'un patient spécifique**

---

## 👤 FONCTIONNALITÉS PATIENT (`patient_utilisateur_id`)

### 1. **Gestion du Profil Patient**
- ✅ **Voir son profil** (`utilisateurs` WHERE `id = patient_utilisateur_id`)
- ✅ **Modifier son profil** :
  - Informations personnelles (nom, prénom, email, téléphone, photo)
  - Date de naissance (`date_naissance`)
  - Adresse (`adresse`, `ville`, `code_postal`)
  - Activation authentification biométrique (`bio_auth_enabled`)

### 2. **Recherche de Médecins**
- ✅ **Rechercher des médecins** :
  - Par nom/prénom
  - Par spécialité (`specialites`)
  - Par centre médical (`centres_medicaux`)
  - Par ville
- ✅ **Voir la liste de tous les médecins disponibles**
- ✅ **Voir les détails d'un médecin** :
  - Informations complètes (spécialité, centre, tarif, bio, expérience)
  - Horaires disponibles (`horaires_medecins`)
  - Indisponibilités (pour éviter les créneaux)
  - Langues parlées
  - Accepte nouveaux patients
- ✅ **Voir les disponibilités d'un médecin** (créneaux libres)

### 3. **Gestion des Rendez-vous** (`rendez_vous`)
- ✅ **Créer un nouveau rendez-vous** :
  - Sélectionner un médecin (`medecin_utilisateur_id`)
  - Sélectionner un centre médical (`centre_medical_id`) - optionnel
  - Choisir une date/heure (`date_heure`)
  - Définir la durée (`duree`) - optionnel, par défaut 30 min
  - Ajouter un motif de consultation (`motif_consultation`)
  - Ajouter des notes (`notes_patient`)
- ✅ **Voir tous ses rendez-vous** (filtrés par `patient_utilisateur_id`)
  - Filtrer par statut
  - Filtrer par date (à venir, passés)
  - Trier par date/heure
- ✅ **Voir les détails d'un rendez-vous** :
  - Informations médecin
  - Date/heure
  - Statut
  - Motif
  - Notes
- ✅ **Modifier un rendez-vous** :
  - Changer la date/heure
  - Modifier le motif
  - Modifier les notes patient
- ✅ **Annuler un rendez-vous** (changer statut → `annulé`)
- ✅ **Voir les prochains rendez-vous** (à venir)
- ✅ **Voir l'historique des rendez-vous** (passés)

### 4. **Favoris** (`favoris`)
- ✅ **Ajouter un médecin aux favoris** :
  - Vérifier l'unicité (`UNIQUE(patient_utilisateur_id, medecin_utilisateur_id)`)
- ✅ **Voir tous ses médecins favoris**
- ✅ **Supprimer un médecin des favoris**
- ✅ **Vérifier si un médecin est en favoris**

### 5. **Historique Médical** (`historique_consultations`)
- ✅ **Voir son historique médical complet** :
  - Toutes les consultations passées
  - Diagnostic, traitement, ordonnance
  - Notes du médecin
  - Documents joints
- ✅ **Voir l'historique avec un médecin spécifique**
- ✅ **Filtrer par date** (mois, année)
- ✅ **Télécharger/voir les documents joints**

### 6. **Notifications** (`notifications`)
- ✅ **Voir toutes ses notifications** (filtrées par `utilisateur_id`)
- ✅ **Marquer une notification comme lue**
- ✅ **Marquer toutes comme lues**
- ✅ **Filtrer par type** :
  - Confirmations de rendez-vous
  - Rappels de rendez-vous
  - Annulations
  - Modifications
  - Messages
- ✅ **Voir les notifications non lues**
- ✅ **Supprimer une notification**
- ✅ **Recevoir des notifications automatiques** :
  - Confirmation lors de la création d'un RDV (trigger SQL)
  - Rappel 24h avant le RDV
  - Notification d'annulation
  - Notification de modification

### 7. **Statistiques Personnelles**
- ✅ **Statistiques de rendez-vous** :
  - Total de rendez-vous
  - Rendez-vous à venir
  - Rendez-vous complétés
  - Rendez-vous annulés
- ✅ **Médecins consultés** (liste unique)
- ✅ **Fréquence des consultations** (par mois/année)

### 8. **Dossier Médical** (à créer si nécessaire)
- ⚠️ **Groupe sanguin** (pas dans la structure actuelle)
- ⚠️ **Allergies** (pas dans la structure actuelle)
- ⚠️ **Médicaments en cours** (pas dans la structure actuelle)
- ⚠️ **Antécédents médicaux** (pas dans la structure actuelle)
- ✅ **Historique des consultations** (via `historique_consultations`)

---

## 🔄 FONCTIONNALITÉS PARTAGÉES (Médecins et Patients)

### 1. **Notifications en Temps Réel**
- ✅ **Écouter les nouvelles notifications** (Supabase Realtime)
- ✅ **Badge de notifications non lues** sur l'icône
- ✅ **Notifications push** (si configuré)

### 2. **Recherche et Filtres Communs**
- ✅ **Recherche de spécialités** (`specialites`)
- ✅ **Recherche de centres médicaux** (`centres_medicaux`)
- ✅ **Filtres par ville** (pour centres médicaux)

### 3. **Gestion des Disponibilités**
- ✅ **Vérifier les créneaux disponibles** avant de créer un RDV :
  - Vérifier les horaires du médecin
  - Vérifier les indisponibilités
  - Vérifier les rendez-vous existants
  - Calculer les créneaux libres

---

## 📊 SERVICES À CRÉER/IMPLÉMENTER

### Services Médecin
1. **`DoctorProfileService`**
   - `getDoctorProfile(String medecinId)`
   - `updateDoctorProfile(String medecinId, Map<String, dynamic> updates)`

2. **`DoctorScheduleService`**
   - `getDoctorSchedules(String medecinId)`
   - `createSchedule(String medecinId, Schedule schedule)`
   - `updateSchedule(String scheduleId, Schedule schedule)`
   - `deleteSchedule(String scheduleId)`
   - `toggleScheduleAvailability(String scheduleId, bool isAvailable)`

3. **`DoctorUnavailabilityService`**
   - `getUnavailabilities(String medecinId)`
   - `createUnavailability(String medecinId, Unavailability unavailability)`
   - `updateUnavailability(String unavailabilityId, Unavailability unavailability)`
   - `deleteUnavailability(String unavailabilityId)`

4. **`DoctorAppointmentService`**
   - `getDoctorAppointments(String medecinId, {DateTime? startDate, DateTime? endDate, AppointmentStatus? status})`
   - `getAppointmentDetails(String appointmentId)`
   - `confirmAppointment(String appointmentId)`
   - `cancelAppointment(String appointmentId)`
   - `completeAppointment(String appointmentId)`
   - `markAbsent(String appointmentId)`
   - `updateAppointmentNotes(String appointmentId, String notes)`
   - `getDaySchedule(String medecinId, DateTime date)`
   - `getWeekSchedule(String medecinId, DateTime weekStart)`

5. **`ConsultationHistoryService`**
   - `createConsultationHistory(String appointmentId, ConsultationHistory history)`
   - `getPatientHistory(String patientId)`
   - `getConsultationHistory(String historyId)`
   - `updateConsultationHistory(String historyId, ConsultationHistory history)`

6. **`DoctorStatisticsService`**
   - `getDoctorStatistics(String medecinId, {DateTime? startDate, DateTime? endDate})`
   - `getAppointmentStats(String medecinId, {DateTime? startDate, DateTime? endDate})`
   - `getRevenueStats(String medecinId, {DateTime? startDate, DateTime? endDate})`

### Services Patient
1. **`PatientProfileService`**
   - `getPatientProfile(String patientId)`
   - `updatePatientProfile(String patientId, Map<String, dynamic> updates)`

2. **`DoctorSearchService`**
   - `searchDoctors({String? name, String? speciality, String? centre, String? ville})`
   - `getDoctorDetails(String medecinId)`
   - `getDoctorAvailability(String medecinId, DateTime startDate, DateTime endDate)`

3. **`PatientAppointmentService`**
   - `createAppointment({required String patientId, required String medecinId, required DateTime dateTime, String? motif, String? notes, String? centreId})`
   - `getPatientAppointments(String patientId, {bool? upcoming})`
   - `getAppointmentDetails(String appointmentId)`
   - `updateAppointment(String appointmentId, {DateTime? dateTime, String? motif, String? notes})`
   - `cancelAppointment(String appointmentId)`

4. **`FavoritesService`**
   - `addToFavorites(String patientId, String medecinId)`
   - `removeFromFavorites(String patientId, String medecinId)`
   - `getFavorites(String patientId)`
   - `isFavorite(String patientId, String medecinId)`

5. **`MedicalHistoryService`**
   - `getPatientMedicalHistory(String patientId)`
   - `getHistoryWithDoctor(String patientId, String medecinId)`
   - `getConsultationDetails(String historyId)`

6. **`PatientStatisticsService`**
   - `getPatientStatistics(String patientId)`
   - `getAppointmentStats(String patientId)`

### Services Partagés
1. **`NotificationService`** (déjà partiellement créé)
   - `getNotifications(String userId)`
   - `markAsRead(String notificationId)`
   - `markAllAsRead(String userId)`
   - `deleteNotification(String notificationId)`
   - `getUnreadCount(String userId)`
   - `subscribeToNotifications(String userId)` (Realtime)

2. **`SpecialityService`**
   - `getAllSpecialities()`
   - `getSpeciality(String specialityId)`

3. **`MedicalCenterService`**
   - `getAllCenters()`
   - `getCentersByCity(String city)`
   - `getCenterDetails(String centerId)`

4. **`AvailabilityService`** (pour calculer les créneaux disponibles)
   - `getAvailableSlots(String medecinId, DateTime date)`
   - `checkSlotAvailability(String medecinId, DateTime dateTime)`

---

## 🗄️ REQUÊTES SQL PRINCIPALES À IMPLÉMENTER

### Pour les Médecins

#### Récupérer le profil médecin
```sql
SELECT * FROM v_medecins WHERE id = :medecin_utilisateur_id;
```

#### Récupérer les horaires
```sql
SELECT * FROM horaires_medecins 
WHERE medecin_utilisateur_id = :medecin_utilisateur_id
ORDER BY jour, heure_debut;
```

#### Récupérer les rendez-vous
```sql
SELECT rv.*, 
       p.nom as patient_nom, p.prenom as patient_prenom,
       p.email as patient_email, p.telephone as patient_telephone
FROM rendez_vous rv
JOIN utilisateurs p ON rv.patient_utilisateur_id = p.id
WHERE rv.medecin_utilisateur_id = :medecin_utilisateur_id
  AND rv.date_heure >= :start_date
  AND rv.date_heure <= :end_date
ORDER BY rv.date_heure;
```

#### Créer un historique de consultation
```sql
INSERT INTO historique_consultations (
  rendez_vous_id, patient_utilisateur_id, medecin_utilisateur_id,
  date_consultation, diagnostic, traitement, ordonnance, notes
) VALUES (...);
```

### Pour les Patients

#### Rechercher des médecins
```sql
SELECT * FROM v_medecins
WHERE (:name IS NULL OR (nom ILIKE '%' || :name || '%' OR prenom ILIKE '%' || :name || '%'))
  AND (:specialite_id IS NULL OR specialite_id = :specialite_id)
  AND (:centre_id IS NULL OR centre_medical_id = :centre_id)
  AND accepte_nouveaux_patients = true;
```

#### Récupérer les rendez-vous patient
```sql
SELECT rv.*,
       m.nom as medecin_nom, m.prenom as medecin_prenom,
       s.nom as specialite_nom
FROM rendez_vous rv
JOIN utilisateurs m ON rv.medecin_utilisateur_id = m.id
LEFT JOIN specialites s ON m.specialite_id = s.id
WHERE rv.patient_utilisateur_id = :patient_utilisateur_id
ORDER BY rv.date_heure DESC;
```

#### Vérifier les créneaux disponibles
```sql
-- Récupérer les horaires du médecin pour un jour donné
SELECT * FROM horaires_medecins
WHERE medecin_utilisateur_id = :medecin_utilisateur_id
  AND jour = :jour_semaine
  AND is_available = true;

-- Récupérer les rendez-vous existants
SELECT date_heure, duree FROM rendez_vous
WHERE medecin_utilisateur_id = :medecin_utilisateur_id
  AND DATE(date_heure) = :date
  AND statut NOT IN ('annulé', 'absent');

-- Récupérer les indisponibilités
SELECT * FROM indisponibilites
WHERE medecin_utilisateur_id = :medecin_utilisateur_id
  AND date_debut <= :date_time
  AND date_fin >= :date_time;
```

---

## ✅ PRIORITÉS D'IMPLÉMENTATION

### Phase 1 - Essentiel (MVP)
1. ✅ Gestion du profil (médecin et patient)
2. ✅ Création de rendez-vous (patient)
3. ✅ Consultation des rendez-vous (médecin et patient)
4. ✅ Modification/Annulation de rendez-vous
5. ✅ Gestion des horaires (médecin)
6. ✅ Notifications de base

### Phase 2 - Important
1. ✅ Recherche de médecins (patient)
2. ✅ Gestion des indisponibilités (médecin)
3. ✅ Historique des consultations
4. ✅ Favoris (patient)
5. ✅ Statistiques de base

### Phase 3 - Amélioration
1. ✅ Statistiques avancées
2. ✅ Notifications en temps réel
3. ✅ Calcul automatique des créneaux disponibles
4. ✅ Rappels automatiques
5. ✅ Documents joints

---

## 📝 NOTES IMPORTANTES

1. **RLS (Row Level Security)** : Toutes les tables ont RLS activé. Vérifier que les politiques permettent les opérations nécessaires.

2. **Triggers SQL** : 
   - Les notifications sont créées automatiquement via le trigger `appointment_notification_trigger`
   - Les timestamps `updated_at` sont mis à jour automatiquement

3. **Contraintes** :
   - Un patient doit avoir une `date_naissance`
   - Un médecin doit avoir une `specialite_id`
   - Les favoris sont uniques (`UNIQUE(patient_utilisateur_id, medecin_utilisateur_id)`)

4. **Vues SQL** : Utiliser `v_medecins` et `v_patients` pour simplifier les requêtes.

5. **Indexes** : Les indexes sont déjà créés pour optimiser les performances.

---

**Dernière mise à jour** : Basé sur `supabase_structure_complete.sql`

