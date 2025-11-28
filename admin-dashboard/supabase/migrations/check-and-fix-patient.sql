-- =====================================================
-- Vérifier et corriger le patient existant
-- =====================================================

-- 1. Vérifier si le patient existe déjà
SELECT 
    id,
    user_id,
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
-- OPTION 1 : Mettre à jour le patient existant
-- =====================================================
-- Si le patient existe mais avec un user_id différent ou NULL,
-- vous pouvez le mettre à jour :

UPDATE utilisateurs
SET 
    user_id = '8ea2b706-54c6-42ef-9913-04e5d7cae79d',
    role = 'patient',
    nom = 'Dubois',
    prenom = 'Marie',
    telephone = '+33612345678',
    date_naissance = '1990-05-15',
    adresse = '123 Rue de la Santé',
    ville = 'Paris',
    code_postal = '75001',
    updated_at = NOW()
WHERE email = 'patient@test.com';

-- =====================================================
-- OPTION 2 : Utiliser un autre email
-- =====================================================
-- Si vous voulez créer un nouveau patient avec un email différent :

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
--     '8ea2b706-54c6-42ef-9913-04e5d7cae79d',
--     'patient',
--     'Dubois',
--     'Marie',
--     'marie.dubois@test.com',  -- Nouvel email
--     '+33612345678',
--     '1990-05-15',
--     '123 Rue de la Santé',
--     'Paris',
--     '75001'
-- );

-- =====================================================
-- OPTION 3 : Supprimer l'ancien patient et en créer un nouveau
-- =====================================================
-- ⚠️ ATTENTION : Cela supprimera l'ancien patient !

-- DELETE FROM utilisateurs WHERE email = 'patient@test.com';
-- 
-- Puis exécutez votre INSERT original

-- =====================================================
-- Vérification finale
-- =====================================================

SELECT 
    id,
    user_id,
    email,
    role,
    nom,
    prenom,
    telephone,
    date_naissance,
    ville
FROM utilisateurs 
WHERE email = 'patient@test.com' OR user_id = '8ea2b706-54c6-42ef-9913-04e5d7cae79d';

