-- =====================================================
-- Script pour créer un utilisateur PATIENT
-- =====================================================
-- 
-- Ce script vous aide à créer un compte patient dans Supabase
-- avec des identifiants de connexion.
--
-- IMPORTANT : Vous devez d'abord créer l'utilisateur dans 
-- l'interface Supabase Authentication, puis exécuter ce script.
-- =====================================================

-- =====================================================
-- MÉTHODE 1 : Créer un patient via l'interface Supabase (RECOMMANDÉ)
-- =====================================================
--
-- 1. Allez dans l'onglet "Authentication" de Supabase
-- 2. Cliquez sur "Add user" ou "Create user"
-- 3. Remplissez :
--    - Email : patient@example.com (ou l'email de votre choix)
--    - Password : (choisissez un mot de passe)
--    - Auto Confirm User : ✅ (cocher cette case)
-- 4. Cliquez sur "Create user"
-- 5. Notez l'UUID de l'utilisateur créé (visible dans la liste)
--
-- 6. Exécutez ensuite cette requête SQL (remplacez les valeurs) :
-- =====================================================

-- Exemple : Créer un patient
-- Remplacez 'UUID_DE_L_UTILISATEUR' par l'UUID de auth.users
-- Remplacez 'patient@example.com' par l'email utilisé dans auth.users

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
    'UUID_DE_L_UTILISATEUR', -- ⚠️ Remplacez par l'UUID de auth.users
    'patient',
    'Dupont',                -- Nom du patient
    'Jean',                  -- Prénom du patient
    'patient@example.com',   -- ⚠️ Même email que dans auth.users
    '+33612345678',          -- Téléphone
    '1990-05-15',            -- Date de naissance (format YYYY-MM-DD)
    '123 Rue de la Santé',   -- Adresse
    'Paris',                 -- Ville
    '75001'                  -- Code postal
);

-- =====================================================
-- MÉTHODE 2 : Créer un patient de test simple
-- =====================================================
-- 
-- Si vous voulez créer un patient de test rapidement :
-- 
-- Email : patient@test.com
-- Mot de passe : patient123
-- 
-- Exécutez d'abord dans l'interface Supabase Authentication,
-- puis exécutez cette requête (en remplaçant l'UUID) :
-- =====================================================

-- Exemple patient de test
-- INSERT INTO utilisateurs (
--     user_id,
--     role,
--     nom,
--     prenom,
--     email,
--     telephone,
--     date_naissance,
--     adresse,
--     ville,
--     code_postal
-- )
-- VALUES (
--     'UUID_DE_L_UTILISATEUR', -- ⚠️ Remplacez par l'UUID de auth.users
--     'patient',
--     'Test',
--     'Patient',
--     'patient@test.com',
--     '+33612345678',
--     '1990-01-01',
--     '1 Rue Test',
--     'Paris',
--     '75001'
-- );

-- =====================================================
-- VÉRIFIER LE PATIENT CRÉÉ
-- =====================================================

-- Voir tous les patients
SELECT 
    id,
    email,
    role,
    nom,
    prenom,
    telephone,
    date_naissance,
    ville,
    user_id,
    created_at
FROM utilisateurs 
WHERE role = 'patient'
ORDER BY created_at DESC;

-- Voir un patient spécifique
-- SELECT * FROM utilisateurs WHERE email = 'patient@example.com';

-- =====================================================
-- INFORMATIONS DE CONNEXION
-- =====================================================
-- 
-- Une fois le patient créé, vous pouvez vous connecter avec :
-- - Email : l'email utilisé lors de la création
-- - Mot de passe : le mot de passe défini dans Supabase Authentication
-- 
-- Le patient pourra se connecter via l'application mobile.
-- =====================================================

