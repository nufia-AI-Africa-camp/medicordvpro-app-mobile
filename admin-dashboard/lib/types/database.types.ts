export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type UserRole = 'patient' | 'medecin' | 'admin'
export type AppointmentStatus = 'en_attente' | 'confirmé' | 'annulé' | 'terminé' | 'absent'
export type NotificationType = 'confirmation' | 'rappel' | 'annulation' | 'modification' | 'message'
export type JourSemaine = 'lundi' | 'mardi' | 'mercredi' | 'jeudi' | 'vendredi' | 'samedi' | 'dimanche'

export interface Utilisateur {
  id: string
  user_id: string | null
  role: UserRole
  nom: string
  prenom: string
  email: string
  telephone: string
  photo_profil: string | null
  bio_auth_enabled: boolean
  date_naissance: string | null
  adresse: string | null
  ville: string | null
  code_postal: string | null
  specialite_id: string | null
  centre_medical_id: string | null
  numero_ordre: string | null
  tarif_consultation: number | null
  bio: string | null
  annees_experience: number | null
  langues_parlees: string[] | null
  accepte_nouveaux_patients: boolean
  created_at: string
  updated_at: string
}

export interface RendezVous {
  id: string
  patient_utilisateur_id: string
  medecin_utilisateur_id: string
  centre_medical_id: string | null
  date_heure: string
  duree: number
  statut: AppointmentStatus
  motif_consultation: string | null
  notes_patient: string | null
  notes_medecin: string | null
  montant: number | null
  created_at: string
  updated_at: string
}

export interface Specialite {
  id: string
  nom: string
  description: string | null
  icone: string | null
  created_at: string
}

export interface CentreMedical {
  id: string
  nom: string
  adresse: string
  ville: string
  code_postal: string | null
  telephone: string | null
  email: string | null
  latitude: number | null
  longitude: number | null
  description: string | null
  created_at: string
  updated_at: string
}

export interface Notification {
  id: string
  utilisateur_id: string
  rendez_vous_id: string | null
  type: NotificationType
  titre: string
  message: string
  is_read: boolean
  sent_at: string
  read_at: string | null
}

export interface HistoriqueConsultation {
  id: string
  rendez_vous_id: string
  patient_utilisateur_id: string
  medecin_utilisateur_id: string
  date_consultation: string
  diagnostic: string | null
  traitement: string | null
  ordonnance: string | null
  notes: string | null
  documents_joints: string[] | null
  created_at: string
}

export interface HoraireMedecin {
  id: string
  medecin_utilisateur_id: string
  jour: JourSemaine
  heure_debut: string
  heure_fin: string
  duree_consultation: number
  is_available: boolean
  created_at: string
}

export interface Indisponibilite {
  id: string
  medecin_utilisateur_id: string
  date_debut: string
  date_fin: string
  raison: string | null
  created_at: string
}

export interface Favori {
  id: string
  patient_utilisateur_id: string
  medecin_utilisateur_id: string
  created_at: string
}

