-- =====================================================
-- SCRIPT SIMPLE : Transformer un utilisateur en admin
-- Utilise la table utilisateurs existante (pas besoin de table admins)
-- =====================================================

-- ÉTAPE 1 : Vérifier les utilisateurs existants
SELECT id, email, role, nom, prenom 
FROM utilisateurs 
ORDER BY created_at DESC 
LIMIT 10;

-- ÉTAPE 2 : Transformer un utilisateur existant en admin
-- Remplacez 'votre_email@example.com' par l'email de l'utilisateur que vous voulez transformer
UPDATE utilisateurs
SET role = 'admin'
WHERE email = 'votre_email@example.com'
RETURNING id, email, role, nom, prenom;

-- ÉTAPE 3 : Vérifier que l'utilisateur est maintenant admin
SELECT id, email, role, nom, prenom, user_id
FROM utilisateurs 
WHERE role = 'admin';

-- =====================================================
-- Si vous voulez créer un NOUVEL utilisateur admin :
-- =====================================================

-- Option A : Via l'interface Supabase (RECOMMANDÉ)
-- 1. Allez dans Authentication > Add user
-- 2. Créez l'utilisateur avec email et mot de passe
-- 3. Notez l'UUID de l'utilisateur créé
-- 4. Exécutez ensuite :

-- INSERT INTO utilisateurs (
--     user_id,
--     role,
--     nom,
--     prenom,
--     email,
--     telephone
-- )
-- VALUES (
--     'UUID_DE_L_UTILISATEUR_AUTH', -- Remplacez par l'UUID de auth.users
--     'admin',
--     'Admin',
--     'Super',
--     'admin@medicord.com',
--     '+33123456789'
-- );

