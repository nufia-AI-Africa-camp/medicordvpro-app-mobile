-- =====================================================
-- STRUCTURE COMPLÈTE SUPABASE - VERSION UNIFIÉE
-- Application de Prise de Rendez-vous Médicaux
-- =====================================================

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TYPES ENUM
-- =====================================================
CREATE TYPE user_role AS ENUM ('patient', 'medecin', 'admin');
CREATE TYPE appointment_status AS ENUM ('en_attente', 'confirmé', 'annulé', 'terminé', 'absent');
CREATE TYPE notification_type AS ENUM ('confirmation', 'rappel', 'annulation', 'modification', 'message');
CREATE TYPE jour_semaine AS ENUM ('lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche');

-- =====================================================
-- TABLE: specialites
-- =====================================================
CREATE TABLE specialites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE: centres_medicaux
-- =====================================================
CREATE TABLE centres_medicaux (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom VARCHAR(200) NOT NULL,
    adresse TEXT NOT NULL,
    ville VARCHAR(100) NOT NULL,
    code_postal VARCHAR(10),
    telephone VARCHAR(20),
    email VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE: utilisateurs (unifie patients et medecins)
-- =====================================================
CREATE TABLE utilisateurs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL DEFAULT 'patient',
    
    -- Informations communes
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    photo_profil TEXT,
    bio_auth_enabled BOOLEAN DEFAULT FALSE,
    
    -- Informations patient
    date_naissance DATE,
    adresse TEXT,
    ville VARCHAR(100),
    code_postal VARCHAR(10),
    
    -- Informations médecin
    specialite_id UUID REFERENCES specialites(id) ON DELETE SET NULL,
    centre_medical_id UUID REFERENCES centres_medicaux(id) ON DELETE SET NULL,
    numero_ordre VARCHAR(50),
    tarif_consultation DECIMAL(10, 2),
    bio TEXT,
    annees_experience INTEGER,
    langues_parlees TEXT[],
    accepte_nouveaux_patients BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Contraintes de validation
    CONSTRAINT check_patient_has_birthdate CHECK (
        role != 'patient' OR date_naissance IS NOT NULL
    ),
    CONSTRAINT check_medecin_has_specialite CHECK (
        role != 'medecin' OR specialite_id IS NOT NULL
    )
);

-- =====================================================
-- TABLE: horaires_medecins
-- =====================================================
CREATE TABLE horaires_medecins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    medecin_utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,
    jour jour_semaine NOT NULL,
    heure_debut TIME NOT NULL,
    heure_fin TIME NOT NULL,
    duree_consultation INTEGER DEFAULT 30, -- en minutes
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(medecin_utilisateur_id, jour, heure_debut)
);

-- =====================================================
-- TABLE: indisponibilites
-- =====================================================
CREATE TABLE indisponibilites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    medecin_utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,
    date_debut TIMESTAMP WITH TIME ZONE NOT NULL,
    date_fin TIMESTAMP WITH TIME ZONE NOT NULL,
    raison TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE: rendez_vous
-- =====================================================
CREATE TABLE rendez_vous (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,
    medecin_utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,
    centre_medical_id UUID REFERENCES centres_medicaux(id) ON DELETE SET NULL,
    date_heure TIMESTAMP WITH TIME ZONE NOT NULL,
    duree INTEGER DEFAULT 30, -- en minutes
    statut appointment_status DEFAULT 'en_attente',
    motif_consultation TEXT,
    notes_patient TEXT,
    notes_medecin TEXT,
    montant DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE: notifications
-- =====================================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,
    rendez_vous_id UUID REFERENCES rendez_vous(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    titre VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read_at TIMESTAMP WITH TIME ZONE
);

-- =====================================================
-- TABLE: historique_consultations
-- =====================================================
CREATE TABLE historique_consultations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rendez_vous_id UUID REFERENCES rendez_vous(id) ON DELETE CASCADE,
    patient_utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,
    medecin_utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,
    date_consultation TIMESTAMP WITH TIME ZONE NOT NULL,
    diagnostic TEXT,
    traitement TEXT,
    ordonnance TEXT,
    notes TEXT,
    documents_joints TEXT[], -- URLs des documents
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE: favoris
-- =====================================================
CREATE TABLE favoris (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,
    medecin_utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(patient_utilisateur_id, medecin_utilisateur_id)
);

-- =====================================================
-- INDEXES POUR PERFORMANCE
-- =====================================================
CREATE INDEX idx_utilisateurs_email ON utilisateurs(email);
CREATE INDEX idx_utilisateurs_user_id ON utilisateurs(user_id);
CREATE INDEX idx_utilisateurs_role ON utilisateurs(role);
CREATE INDEX idx_utilisateurs_specialite ON utilisateurs(specialite_id);
CREATE INDEX idx_utilisateurs_centre ON utilisateurs(centre_medical_id);
CREATE INDEX idx_rendez_vous_patient ON rendez_vous(patient_utilisateur_id);
CREATE INDEX idx_rendez_vous_medecin ON rendez_vous(medecin_utilisateur_id);
CREATE INDEX idx_rendez_vous_date ON rendez_vous(date_heure);
CREATE INDEX idx_rendez_vous_statut ON rendez_vous(statut);
CREATE INDEX idx_notifications_utilisateur ON notifications(utilisateur_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_horaires_medecin ON horaires_medecins(medecin_utilisateur_id);
CREATE INDEX idx_centres_medicaux_ville ON centres_medicaux(ville);

-- =====================================================
-- FONCTIONS TRIGGERS POUR UPDATE TIMESTAMP
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Appliquer les triggers
CREATE TRIGGER update_utilisateurs_updated_at 
    BEFORE UPDATE ON utilisateurs
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_centres_medicaux_updated_at 
    BEFORE UPDATE ON centres_medicaux
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rendez_vous_updated_at 
    BEFORE UPDATE ON rendez_vous
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- FONCTION POUR CRÉER DES NOTIFICATIONS AUTOMATIQUES
-- =====================================================
CREATE OR REPLACE FUNCTION create_appointment_notification()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO notifications (utilisateur_id, rendez_vous_id, type, titre, message)
        VALUES (
            NEW.patient_utilisateur_id,
            NEW.id,
            'confirmation',
            'Rendez-vous confirmé',
            'Votre rendez-vous a été confirmé pour le ' || TO_CHAR(NEW.date_heure, 'DD/MM/YYYY à HH24:MI')
        );
    ELSIF (TG_OP = 'UPDATE' AND OLD.statut != NEW.statut) THEN
        IF NEW.statut = 'annulé' THEN
            INSERT INTO notifications (utilisateur_id, rendez_vous_id, type, titre, message)
            VALUES (
                NEW.patient_utilisateur_id,
                NEW.id,
                'annulation',
                'Rendez-vous annulé',
                'Votre rendez-vous du ' || TO_CHAR(NEW.date_heure, 'DD/MM/YYYY à HH24:MI') || ' a été annulé'
            );
        ELSIF OLD.date_heure != NEW.date_heure THEN
            INSERT INTO notifications (utilisateur_id, rendez_vous_id, type, titre, message)
            VALUES (
                NEW.patient_utilisateur_id,
                NEW.id,
                'modification',
                'Rendez-vous modifié',
                'Votre rendez-vous a été modifié pour le ' || TO_CHAR(NEW.date_heure, 'DD/MM/YYYY à HH24:MI')
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER appointment_notification_trigger
    AFTER INSERT OR UPDATE ON rendez_vous
    FOR EACH ROW 
    EXECUTE FUNCTION create_appointment_notification();

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Activer RLS sur toutes les tables
ALTER TABLE utilisateurs ENABLE ROW LEVEL SECURITY;
ALTER TABLE rendez_vous ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE historique_consultations ENABLE ROW LEVEL SECURITY;
ALTER TABLE favoris ENABLE ROW LEVEL SECURITY;
ALTER TABLE horaires_medecins ENABLE ROW LEVEL SECURITY;
ALTER TABLE specialites ENABLE ROW LEVEL SECURITY;
ALTER TABLE centres_medicaux ENABLE ROW LEVEL SECURITY;

-- Policies pour utilisateurs
CREATE POLICY "Utilisateurs peuvent voir leur propre profil"
    ON utilisateurs FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Utilisateurs peuvent mettre à jour leur propre profil"
    ON utilisateurs FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Tout le monde peut voir les médecins"
    ON utilisateurs FOR SELECT
    TO authenticated
    USING (role = 'medecin');

CREATE POLICY "Les utilisateurs peuvent s'inscrire"
    ON utilisateurs FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Policies pour rendez_vous
CREATE POLICY "Utilisateurs peuvent voir leurs rendez-vous"
    ON rendez_vous FOR SELECT
    TO authenticated
    USING (
        patient_utilisateur_id IN (SELECT id FROM utilisateurs WHERE user_id = auth.uid())
        OR medecin_utilisateur_id IN (SELECT id FROM utilisateurs WHERE user_id = auth.uid())
    );

CREATE POLICY "Patients peuvent créer des rendez-vous"
    ON rendez_vous FOR INSERT
    TO authenticated
    WITH CHECK (
        patient_utilisateur_id IN (
            SELECT id FROM utilisateurs WHERE user_id = auth.uid() AND role = 'patient'
        )
    );

CREATE POLICY "Utilisateurs peuvent modifier leurs rendez-vous"
    ON rendez_vous FOR UPDATE
    TO authenticated
    USING (
        patient_utilisateur_id IN (SELECT id FROM utilisateurs WHERE user_id = auth.uid())
        OR medecin_utilisateur_id IN (SELECT id FROM utilisateurs WHERE user_id = auth.uid())
    );

-- Policies pour notifications
CREATE POLICY "Utilisateurs peuvent voir leurs notifications"
    ON notifications FOR SELECT
    TO authenticated
    USING (
        utilisateur_id IN (SELECT id FROM utilisateurs WHERE user_id = auth.uid())
    );

CREATE POLICY "Utilisateurs peuvent mettre à jour leurs notifications"
    ON notifications FOR UPDATE
    TO authenticated
    USING (
        utilisateur_id IN (SELECT id FROM utilisateurs WHERE user_id = auth.uid())
    );

-- Policies pour historique
CREATE POLICY "Utilisateurs peuvent voir leur historique"
    ON historique_consultations FOR SELECT
    TO authenticated
    USING (
        patient_utilisateur_id IN (SELECT id FROM utilisateurs WHERE user_id = auth.uid())
        OR medecin_utilisateur_id IN (SELECT id FROM utilisateurs WHERE user_id = auth.uid())
    );

-- Policies pour favoris
CREATE POLICY "Patients peuvent gérer leurs favoris"
    ON favoris FOR ALL
    TO authenticated
    USING (
        patient_utilisateur_id IN (
            SELECT id FROM utilisateurs WHERE user_id = auth.uid() AND role = 'patient'
        )
    );

-- Policies pour horaires_medecins
CREATE POLICY "Médecins peuvent gérer leurs horaires"
    ON horaires_medecins FOR ALL
    TO authenticated
    USING (
        medecin_utilisateur_id IN (
            SELECT id FROM utilisateurs WHERE user_id = auth.uid() AND role = 'medecin'
        )
    );

CREATE POLICY "Tout le monde peut voir les horaires"
    ON horaires_medecins FOR SELECT
    TO authenticated
    USING (true);

-- Lecture publique pour spécialités et centres médicaux
CREATE POLICY "Lecture publique spécialités"
    ON specialites FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Lecture publique centres médicaux"
    ON centres_medicaux FOR SELECT
    TO authenticated
    USING (true);

-- =====================================================
-- VUES POUR FACILITER LES REQUÊTES
-- =====================================================

-- Vue pour les patients uniquement
CREATE OR REPLACE VIEW v_patients AS
SELECT 
    id,
    user_id,
    nom,
    prenom,
    email,
    telephone,
    photo_profil,
    date_naissance,
    adresse,
    ville,
    code_postal,
    bio_auth_enabled,
    created_at,
    updated_at
FROM utilisateurs
WHERE role = 'patient';

-- Vue pour les médecins avec leurs informations complètes
CREATE OR REPLACE VIEW v_medecins AS
SELECT 
    u.id,
    u.user_id,
    u.nom,
    u.prenom,
    u.email,
    u.telephone,
    u.photo_profil,
    u.specialite_id,
    s.nom as specialite_nom,
    s.description as specialite_description,
    u.centre_medical_id,
    cm.nom as centre_medical_nom,
    cm.adresse as centre_medical_adresse,
    cm.ville as centre_medical_ville,
    cm.telephone as centre_medical_telephone,
    u.numero_ordre,
    u.tarif_consultation,
    u.bio,
    u.annees_experience,
    u.langues_parlees,
    u.accepte_nouveaux_patients,
    u.created_at,
    u.updated_at
FROM utilisateurs u
LEFT JOIN specialites s ON u.specialite_id = s.id
LEFT JOIN centres_medicaux cm ON u.centre_medical_id = cm.id
WHERE u.role = 'medecin';

-- =====================================================
-- DONNÉES DE TEST
-- =====================================================

-- Insertion de spécialités
INSERT INTO specialites (nom, description, icone) VALUES
('Médecine Générale', 'Consultation générale et suivi médical', '🩺'),
('Cardiologie', 'Spécialiste des maladies cardiovasculaires', '❤️'),
('Dermatologie', 'Spécialiste des maladies de la peau', '🔬'),
('Pédiatrie', 'Médecin pour enfants', '👶'),
('Gynécologie', 'Santé de la femme', '👩‍⚕️'),
('Ophtalmologie', 'Spécialiste des yeux', '👁️'),
('Dentiste', 'Soins dentaires', '🦷'),
('Orthopédie', 'Spécialiste des os et articulations', '🦴'),
('Psychiatrie', 'Santé mentale', '🧠'),
('ORL', 'Oto-rhino-laryngologie', '👂');

-- Insertion de centres médicaux
INSERT INTO centres_medicaux (nom, adresse, ville, code_postal, telephone, email) VALUES
('Centre Médical Central', '123 Avenue de la République', 'Paris', '75001', '0123456789', 'contact@centre-central.fr'),
('Clinique du Nord', '45 Rue du Commerce', 'Lyon', '69001', '0423456789', 'info@clinique-nord.fr'),
('Cabinet Médical Sud', '78 Boulevard des Oliviers', 'Marseille', '13001', '0491234567', 'contact@cabinet-sud.fr'),
('Centre de Santé Ouest', '12 Place de la Mairie', 'Nantes', '44000', '0240123456', 'contact@sante-ouest.fr');

-- =====================================================
-- FIN DE LA STRUCTURE
-- =====================================================

SELECT 'Structure créée avec succès!' as message;

