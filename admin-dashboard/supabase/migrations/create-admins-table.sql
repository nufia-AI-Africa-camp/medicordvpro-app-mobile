-- =====================================================
-- TABLE: admins (Super Administrateurs pour le Dashboard)
-- Séparé de l'authentification mobile (patients/médecins)
-- =====================================================

CREATE TABLE IF NOT EXISTS admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL, -- Hash bcrypt du mot de passe
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    telephone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour les recherches rapides
CREATE INDEX IF NOT EXISTS idx_admins_email ON admins(email);
CREATE INDEX IF NOT EXISTS idx_admins_active ON admins(is_active);

-- Trigger pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_admins_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_admins_updated_at_trigger
    BEFORE UPDATE ON admins
    FOR EACH ROW
    EXECUTE FUNCTION update_admins_updated_at();

-- RLS Policies pour admins
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- Les admins peuvent voir tous les admins (pour la gestion)
CREATE POLICY "Admins peuvent voir tous les admins"
    ON admins FOR SELECT
    USING (true); -- On vérifiera l'authentification dans l'application

-- Seuls les admins peuvent modifier les admins
CREATE POLICY "Admins peuvent modifier les admins"
    ON admins FOR ALL
    USING (true)
    WITH CHECK (true); -- On vérifiera l'authentification dans l'application

-- =====================================================
-- Fonction helper pour vérifier si un email admin existe
-- =====================================================
CREATE OR REPLACE FUNCTION admin_exists(email_to_check VARCHAR)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM admins
    WHERE email = email_to_check
    AND is_active = TRUE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- Fonction pour obtenir un admin par email
-- =====================================================
CREATE OR REPLACE FUNCTION get_admin_by_email(email_to_check VARCHAR)
RETURNS TABLE (
    id UUID,
    email VARCHAR,
    nom VARCHAR,
    prenom VARCHAR,
    telephone VARCHAR,
    is_active BOOLEAN,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    a.email,
    a.nom,
    a.prenom,
    a.telephone,
    a.is_active,
    a.last_login,
    a.created_at
  FROM admins a
  WHERE a.email = email_to_check
  AND a.is_active = TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- Fonction pour mettre à jour la dernière connexion
-- =====================================================
CREATE OR REPLACE FUNCTION update_admin_last_login(admin_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE admins
  SET last_login = NOW()
  WHERE id = admin_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

