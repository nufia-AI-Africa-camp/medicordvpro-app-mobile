-- =====================================================
-- EXEMPLE : Créer un patient avec identifiants
-- =====================================================
-- 
-- INSTRUCTIONS :
-- 1. Créez d'abord l'utilisateur dans Supabase Authentication
--    - Email : patient@test.com
--    - Password : patient123
--    - Auto Confirm : ✅
-- 2. Notez l'UUID de l'utilisateur créé
-- 3. Remplacez 'VOTRE_UUID_ICI' ci-dessous par l'UUID réel
-- 4. Exécutez ce script
-- =====================================================

-- ⚠️ REMPLACEZ 'VOTRE_UUID_ICI' PAR L'UUID DE L'UTILISATEUR CRÉÉ DANS AUTH.USERS
-- Pour trouver l'UUID : Authentication > Users > Cliquez sur l'utilisateur

INSERT INTO utilisateurs (
    user_id,
    role,
    nom,
    prenom,
    email,
    telephone,
    date_naissance,
    adresse,
    ville,
    code_postal
)
VALUES (
    'VOTRE_UUID_ICI',        -- ⚠️ UUID de auth.users (remplacez-le !)
    'patient',                -- Rôle : patient
    'Dubois',                 -- Nom
    'Marie',                  -- Prénom
    'patient@test.com',       -- Email (doit correspondre à auth.users)
    '+33612345678',           -- Téléphone
    '1990-05-15',             -- Date de naissance (YYYY-MM-DD)
    '123 Rue de la Santé',    -- Adresse
    'Paris',                  -- Ville
    '75001'                   -- Code postal
);

-- =====================================================
-- VÉRIFICATION
-- =====================================================

-- Vérifier que le patient a été créé
SELECT 
    id,
    email,
    role,
    nom,
    prenom,
    telephone,
    date_naissance,
    ville,
    created_at
FROM utilisateurs 
WHERE email = 'patient@test.com';

-- =====================================================
-- IDENTIFIANTS DE CONNEXION
-- =====================================================
-- Email : patient@test.com
-- Mot de passe : patient123
-- =====================================================

