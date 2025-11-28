-- =====================================================
-- Script pour créer ou transformer un utilisateur en admin
-- =====================================================

-- OPTION 1 : Transformer un utilisateur existant en admin
-- Remplacez 'votre_email@example.com' par l'email de l'utilisateur existant
UPDATE utilisateurs
SET role = 'admin'
WHERE email = 'votre_email@example.com'
RETURNING id, email, role, nom, prenom;

-- Vérifier le résultat
SELECT id, email, role, nom, prenom 
FROM utilisateurs 
WHERE email = 'votre_email@example.com';

-- =====================================================
-- OPTION 2 : Créer un nouvel utilisateur admin
-- (Utilisez seulement si l'utilisateur n'existe pas)
-- =====================================================

-- Étape 1 : Vérifier si l'utilisateur existe déjà
DO $$
DECLARE
  existing_user_id UUID;
  new_user_id UUID;
BEGIN
  -- Vérifier si un utilisateur avec cet email existe déjà
  SELECT id INTO existing_user_id
  FROM utilisateurs
  WHERE email = 'admin@example.com'; -- ⚠️ Changez cet email

  IF existing_user_id IS NOT NULL THEN
    -- L'utilisateur existe, le transformer en admin
    UPDATE utilisateurs
    SET role = 'admin'
    WHERE id = existing_user_id;
    
    RAISE NOTICE 'Utilisateur existant transformé en admin: %', existing_user_id;
  ELSE
    -- L'utilisateur n'existe pas, créer un nouvel utilisateur
    -- Note: Cette partie nécessite des permissions spéciales pour créer dans auth.users
    -- Il est recommandé d'utiliser l'interface Supabase ou l'API pour créer l'utilisateur auth
    
    RAISE NOTICE 'Utilisateur non trouvé. Utilisez l''interface Supabase pour créer l''utilisateur auth, puis exécutez:';
    RAISE NOTICE 'UPDATE utilisateurs SET role = ''admin'' WHERE email = ''admin@example.com'';';
  END IF;
END $$;

