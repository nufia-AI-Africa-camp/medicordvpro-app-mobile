-- =====================================================
-- TABLE: medecin_rappels_settings
-- Stocke les préférences de rappels automatiques des médecins
-- =====================================================
CREATE TABLE IF NOT EXISTS medecin_rappels_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    medecin_utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE UNIQUE NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    sms_enabled BOOLEAN DEFAULT TRUE,
    email_enabled BOOLEAN DEFAULT TRUE,
    reminder_hours_before INTEGER DEFAULT 24, -- Nombre d'heures avant le RDV
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_medecin_rappels_settings_medecin 
    ON medecin_rappels_settings(medecin_utilisateur_id);

-- Trigger pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_medecin_rappels_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_medecin_rappels_settings_updated_at_trigger
    BEFORE UPDATE ON medecin_rappels_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_medecin_rappels_settings_updated_at();

-- RLS (Row Level Security)
ALTER TABLE medecin_rappels_settings ENABLE ROW LEVEL SECURITY;

-- Policy: Les médecins peuvent voir et modifier leurs propres paramètres
CREATE POLICY "Médecins peuvent gérer leurs paramètres de rappels"
    ON medecin_rappels_settings FOR ALL
    TO authenticated
    USING (
        medecin_utilisateur_id IN (
            SELECT id FROM utilisateurs WHERE user_id = auth.uid() AND role = 'medecin'
        )
    );

