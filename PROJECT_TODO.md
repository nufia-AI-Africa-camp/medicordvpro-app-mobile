# Plan de travail MédicoRDV

## 1. Authentification & rôles
- [x] Mettre en place les rôles **Patient** / **Médecin** côté `AuthController` et `AuthService` (mock).
- [x] Ajouter les comptes de démo :
  - Patient : `patient@demo.fr` / `demo1234`
  - Médecin : `medecin@demo.fr` / `demo1234`
- [ ] Prévoir la structure pour un **vrai backend auth** (token JWT, refresh, stockage sécurisé).
- [ ] Gérer la **déconnexion** (clear du state + retour à l’écran de login).

## 2. Espace Patient (app mobile)
- [x] Refonte écran **Connexion** (design + rôle patient/médecin + lien mot de passe oublié).
- [x] Écran **Mot de passe oublié** (design cohérent).
- [x] Dashboard Patient :
  - Carte "Bonjour, [Prénom]" + prochain rendez-vous
  - Statistiques rapides (À venir / Complétés / Annulés / Total)
  - Actions rapides (Nouveau RDV / Mes RDV)
  - Section "Prochains rendez-vous"
- [x] Écran **Mes RDV** (liste vide + filtres + bouton "Nouveau rendez-vous").
- [x] Écran **Dossier médical** (groupe sanguin, allergies, consultations, etc.).
- [x] Écran **Profil** (header, stats, infos personnelles, bandeau confidentialité).
- [x] Page **Nouveau RDV** (liste de médecins + filtres).
- [ ] Rendre toutes ces données **dynamiques** avec des `Provider` (appointments, stats, dossier, etc.).
- [ ] Ajouter la navigation depuis les boutons (Nouveau RDV, Mes RDV, etc.).

## 3. Espace Médecin (app mobile)
- [x] Créer `DoctorDashboardScreen` avec menu bas :
  - Mon agenda
  - Disponibilités
  - Rendez-vous
  - Statistiques
  - Rappels auto
- [x] **Mon agenda** : bandeau violet, résumé du jour, planning de la journée, stats par statut, prochains RDV.
- [x] **Disponibilités** : gestion des horaires par jour (matin / après-midi), bouton "Enregistrer", bloc informations.
- [x] **Rendez-vous** : liste détaillée (3 RDV mock), filtres par statut, boutons Modifier/Annuler.
- [x] **Statistiques** : dashboard (total RDV, consultations terminées, patients uniques, revenus, répartitions, indicateurs).
- [x] **Rappels auto** : configuration des rappels (activation, SMS / email, délai 24h, stats, prochains rappels, explications).
- [ ] Rendre ces écrans **responsives** et tester sur plusieurs tailles de téléphones (Pixel, iPhone).
- [ ] Connecter les écrans médecin aux **modèles de données réels** (Rendez-vous, Patients, Rappels…).

## 4. Modélisation & services
- [x] Modèle `Patient` et `Medecin` de base.
- [ ] Créer les modèles :
  - `RendezVous` (statut, patient, médecin, date/heure, motif, notes…)
  - `Disponibilite` (jour, plages horaires)
  - `RappelAutomatique` (canaux, délai, état)
- [ ] Créer les services mock :
  - `AppointmentService` (liste RDV patient/médecin)
  - `AvailabilityService`
  - `ReminderService`
- [ ] Prévoir les interfaces pour les futurs appels API REST / GraphQL.

## 5. Expérience mobile & design
- [x] Menu bas **Patient** (5 onglets).
- [x] Menu bas **Médecin** (5 onglets).
- [ ] Vérifier les marges / paddings sur petits écrans (320–360dp) et grands téléphones (Pixel XL, iPhone Pro Max).
- [ ] Gérer l’orientation portrait uniquement (si souhaité).
- [ ] Ajouter transitions / animations simples (Hero, `PageRouteBuilder` léger) pour les écrans clés (ouvrir un RDV, profil, etc.).

## 6. Techniques & qualité
- [x] Centraliser les routes avec `GoRouter` + `GoRouterRefreshStream`.
- [ ] Ajouter des tests unitaires de base pour `AuthController` et les futurs services.
- [ ] Ajouter des tests widget (ex. Dashboard patient, Mon agenda médecin).
- [ ] Configurer la génération de build **Android** (APK / AAB) et plus tard iOS.

---

> Tu peux utiliser ce fichier comme check‑list : coche les cases `[ ]` en `[x]` au fur et à mesure, et ajoute de nouveaux points si besoin.

