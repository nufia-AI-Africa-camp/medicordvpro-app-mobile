# Plan d'Implémentation - Ordre Recommandé

## 🎯 RECOMMANDATION : Commencer par les FONCTIONNALITÉS PATIENT

### Pourquoi commencer par le Patient ?

1. **Flux principal de l'application** : C'est le parcours utilisateur le plus important
2. **Écrans déjà créés** : Dashboard, liste RDV, nouveau RDV sont prêts
3. **Plus simple à tester** : On peut créer des RDV sans configuration complexe
4. **Validation end-to-end** : Permet de tester toute la chaîne (création → notification → affichage)

---

## 📋 ORDRE D'IMPLÉMENTATION DÉTAILLÉ

### **PHASE 1 : Fonctionnalités Patient (Priorité 1)**

#### 1.1 Recherche de Médecins ⭐ (COMMENCER ICI)
**Pourquoi en premier ?**
- Fonctionnalité de base nécessaire pour tout le reste
- Lecture seule, pas de permissions complexes
- Permet de valider la connexion Supabase

**À implémenter :**
- ✅ Service : `DoctorSearchService` (Supabase)
  - `searchDoctors({name?, speciality?, centre?, ville?})`
  - `getDoctorDetails(String medecinId)`
  - Utiliser la vue `v_medecins` pour simplifier
- ✅ Controller : `AppointmentSearchController` (déjà créé, à connecter)
- ✅ Écran : `NewAppointmentScreen` (déjà créé, à connecter)

**Tables utilisées :**
- `v_medecins` (vue SQL)
- `specialites`
- `centres_medicaux`

**Temps estimé :** 2-3h

---

#### 1.2 Création de Rendez-vous ⭐⭐
**Pourquoi ensuite ?**
- Fonctionnalité centrale de l'application
- Dépend de la recherche de médecins
- Déclenche les notifications automatiques (trigger SQL)

**À implémenter :**
- ✅ Service : `PatientAppointmentService` (Supabase)
  - `createAppointment({patientId, medecinId, dateTime, motif?, notes?, centreId?})`
  - Validation des créneaux (optionnel au début)
- ✅ Controller : `AppointmentDetailController` (déjà créé, à connecter)
- ✅ Écran : `NewAppointmentScreen` (formulaire de création)

**Tables utilisées :**
- `rendez_vous` (INSERT)
- `notifications` (créé automatiquement par trigger)

**Temps estimé :** 3-4h

---

#### 1.3 Consultation des Rendez-vous Patient ⭐⭐
**Pourquoi ensuite ?**
- Permet de voir les RDV créés
- Nécessaire pour modifier/annuler
- Affiche les données du dashboard

**À implémenter :**
- ✅ Service : `PatientAppointmentService` (Supabase)
  - `getPatientAppointments(String patientId, {upcoming?})`
  - `getAppointmentDetails(String appointmentId)`
- ✅ Controller : `DashboardController` (déjà créé, à connecter)
- ✅ Écran : `AppointmentsListScreen` (déjà créé, à connecter)
- ✅ Écran : `DashboardScreen` (section "Prochains rendez-vous")

**Tables utilisées :**
- `rendez_vous` (SELECT avec JOIN sur `utilisateurs`)

**Temps estimé :** 2-3h

---

#### 1.4 Modification/Annulation de Rendez-vous ⭐
**Pourquoi ensuite ?**
- Complète le cycle de vie d'un RDV
- Déclenche les notifications de modification/annulation

**À implémenter :**
- ✅ Service : `PatientAppointmentService` (Supabase)
  - `updateAppointment(String appointmentId, {dateTime?, motif?, notes?})`
  - `cancelAppointment(String appointmentId)`
- ✅ Écran : `AppointmentsListScreen` (boutons modifier/annuler)

**Tables utilisées :**
- `rendez_vous` (UPDATE)
- `notifications` (créé automatiquement par trigger)

**Temps estimé :** 2h

---

#### 1.5 Notifications Patient ⭐
**Pourquoi ensuite ?**
- Les notifications sont déjà créées par les triggers SQL
- Il suffit de les afficher

**À implémenter :**
- ✅ Service : `NotificationService` (Supabase) - partiellement créé
  - `getNotifications(String userId)`
  - `markAsRead(String notificationId)`
  - `getUnreadCount(String userId)`
- ✅ Controller : `NotificationsController` (déjà créé, à connecter)
- ✅ Écran : `NotificationsScreen` (déjà créé, à connecter)

**Tables utilisées :**
- `notifications` (SELECT, UPDATE)

**Temps estimé :** 2h

---

### **PHASE 2 : Fonctionnalités Médecin (Priorité 2)**

Une fois que les patients peuvent créer des RDV, on implémente la gestion côté médecin.

#### 2.1 Consultation des Rendez-vous Médecin ⭐⭐
**Pourquoi en premier côté médecin ?**
- Permet au médecin de voir les RDV créés par les patients
- Nécessaire pour toutes les autres actions

**À implémenter :**
- ✅ Service : `DoctorAppointmentService` (Supabase)
  - `getDoctorAppointments(String medecinId, {startDate?, endDate?, status?})`
  - `getAppointmentDetails(String appointmentId)`
  - `getDaySchedule(String medecinId, DateTime date)`
- ✅ Écran : `DoctorDashboardScreen` (section "Mon agenda")

**Tables utilisées :**
- `rendez_vous` (SELECT avec JOIN sur `utilisateurs`)

**Temps estimé :** 2-3h

---

#### 2.2 Gestion des Horaires ⭐⭐
**Pourquoi ensuite ?**
- Permet aux médecins de définir leurs disponibilités
- Nécessaire pour calculer les créneaux disponibles (futur)

**À implémenter :**
- ✅ Service : `DoctorScheduleService` (Supabase)
  - `getDoctorSchedules(String medecinId)`
  - `createSchedule(String medecinId, Schedule schedule)`
  - `updateSchedule(String scheduleId, Schedule schedule)`
  - `deleteSchedule(String scheduleId)`
- ✅ Écran : `DoctorDashboardScreen` (onglet "Disponibilités")

**Tables utilisées :**
- `horaires_medecins` (SELECT, INSERT, UPDATE, DELETE)

**Temps estimé :** 3-4h

---

#### 2.3 Confirmation/Modification/Annulation RDV Médecin ⭐
**Pourquoi ensuite ?**
- Permet au médecin de gérer les RDV
- Complète le cycle de vie côté médecin

**À implémenter :**
- ✅ Service : `DoctorAppointmentService` (Supabase)
  - `confirmAppointment(String appointmentId)`
  - `cancelAppointment(String appointmentId)`
  - `completeAppointment(String appointmentId)`
  - `updateAppointmentNotes(String appointmentId, String notes)`
- ✅ Écran : `DoctorDashboardScreen` (onglet "Rendez-vous")

**Tables utilisées :**
- `rendez_vous` (UPDATE)
- `notifications` (créé automatiquement par trigger)

**Temps estimé :** 2-3h

---

#### 2.4 Gestion des Indisponibilités ⭐
**Pourquoi ensuite ?**
- Permet aux médecins de bloquer des périodes
- Complément aux horaires

**À implémenter :**
- ✅ Service : `DoctorUnavailabilityService` (Supabase)
  - `getUnavailabilities(String medecinId)`
  - `createUnavailability(String medecinId, Unavailability unavailability)`
  - `deleteUnavailability(String unavailabilityId)`
- ✅ Écran : `DoctorDashboardScreen` (dans "Disponibilités")

**Tables utilisées :**
- `indisponibilites` (SELECT, INSERT, DELETE)

**Temps estimé :** 2h

---

## 📊 RÉSUMÉ DE L'ORDRE

### Phase 1 - Patient (Total : ~11-14h)
1. ✅ Recherche de Médecins (2-3h)
2. ✅ Création de Rendez-vous (3-4h)
3. ✅ Consultation des Rendez-vous (2-3h)
4. ✅ Modification/Annulation (2h)
5. ✅ Notifications (2h)

### Phase 2 - Médecin (Total : ~9-12h)
1. ✅ Consultation des Rendez-vous (2-3h)
2. ✅ Gestion des Horaires (3-4h)
3. ✅ Gestion des RDV (2-3h)
4. ✅ Indisponibilités (2h)

---

## 🚀 COMMENCER PAR : Recherche de Médecins

**Fichiers à créer/modifier :**

1. **Service** : `lib/core/services/doctor_search_service.dart`
   - Implémentation Supabase
   - Méthodes : `searchDoctors()`, `getDoctorDetails()`

2. **Controller** : `lib/appointments/application/appointment_search_controller.dart`
   - Connecter au service Supabase
   - Gérer les états (loading, error, results)

3. **Écran** : `lib/appointments/presentation/new_appointment_screen.dart`
   - Connecter au controller
   - Afficher les résultats de recherche

**Avantages de commencer ici :**
- ✅ Fonctionnalité simple (lecture seule)
- ✅ Pas de dépendances complexes
- ✅ Permet de valider la connexion Supabase
- ✅ Base pour toutes les autres fonctionnalités

---

## 💡 CONSEILS

1. **Tester au fur et à mesure** : Après chaque fonctionnalité, tester avec un compte patient et un compte médecin
2. **Utiliser les vues SQL** : `v_medecins` simplifie les requêtes
3. **Profiter des triggers** : Les notifications sont créées automatiquement
4. **Respecter les RLS** : Vérifier que les politiques permettent les opérations
5. **Gérer les erreurs** : Prévoir des messages d'erreur clairs

---

**Prêt à commencer ?** Je peux créer le service `DoctorSearchService` avec l'implémentation Supabase ! 🚀

