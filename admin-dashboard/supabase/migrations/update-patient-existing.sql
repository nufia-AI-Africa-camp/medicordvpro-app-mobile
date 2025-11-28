-- =====================================================
-- SOLUTION : Mettre à jour le patient existant
-- =====================================================
-- 
-- Au lieu d'utiliser INSERT, utilisez UPDATE pour modifier
-- le patient existant avec le nouveau user_id
-- =====================================================

-- 1. D'abord, vérifiez ce qui existe actuellement
SELECT 
    id,
    user_id,
    email,
    role,
    nom,
    prenom,
    telephone
FROM utilisateurs 
WHERE email = 'patient@testvrai.com';

-- =====================================================
-- 2. Mettre à jour le patient existant
-- =====================================================
-- Cette requête met à jour le patient existant avec le nouveau user_id
-- et toutes les informations

UPDATE utilisateurs
SET 
    user_id = 'd60bcdb3-cc05-4781-a125-6549d7303f69',  -- Nouveau user_id
    role = 'patient',
    nom = 'Dubois',
    prenom = 'Marie',
    telephone = '+33612345678',
    date_naissance = '1990-05-15',
    adresse = '123 Rue de la Santé',
    ville = 'Paris',
    code_postal = '75001',
    updated_at = NOW()
WHERE email = 'patient@testvrai.com';

-- =====================================================
-- 3. Vérifier que la mise à jour a fonctionné
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
    ville,
    updated_at
FROM utilisateurs 
WHERE email = 'patient@testvrai.com';

-- =====================================================
-- ALTERNATIVE : Si vous voulez vraiment supprimer et recréer
-- =====================================================
-- ⚠️ ATTENTION : Cela supprimera complètement l'ancien patient
-- 
-- DELETE FROM utilisateurs WHERE email = 'patient@testvrai.com';
-- 
-- Puis exécutez votre INSERT original

