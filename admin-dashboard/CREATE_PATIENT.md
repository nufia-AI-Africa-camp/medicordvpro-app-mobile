# Guide de Création d'un Compte Patient

Ce guide vous explique comment créer un compte patient avec des identifiants de connexion dans Supabase.

## 🎯 Vue d'ensemble

Pour créer un patient, vous devez :
1. Créer l'utilisateur dans **Supabase Authentication**
2. Créer l'entrée correspondante dans la table **utilisateurs**

---

## ✅ Méthode 1 : Via l'interface Supabase (RECOMMANDÉ)

### Étape 1 : Créer l'utilisateur dans Authentication

1. Allez dans votre projet Supabase
2. Ouvrez l'onglet **Authentication**
3. Cliquez sur **Add user** ou **Create user**
4. Remplissez le formulaire :
   - **Email** : `patient@example.com` (ou l'email de votre choix)
   - **Password** : Choisissez un mot de passe fort
   - **Auto Confirm User** : ✅ **Cochez cette case** (important !)
5. Cliquez sur **Create user**
6. **Notez l'UUID** de l'utilisateur créé (visible dans la liste des utilisateurs)

### Étape 2 : Créer ou mettre à jour l'entrée dans la table utilisateurs

**IMPORTANT** : Si l'email existe déjà, utilisez `UPDATE` au lieu de `INSERT`.

#### Option A : L'email n'existe pas encore (INSERT)

Allez dans l'onglet **SQL Editor** de Supabase et exécutez cette requête :

```sql
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
    'UUID_DE_L_UTILISATEUR', -- ⚠️ Remplacez par l'UUID noté à l'étape 1
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
```

#### Option B : L'email existe déjà (UPDATE) ⚠️

Si vous obtenez l'erreur `duplicate key value violates unique constraint`, utilisez cette requête à la place :

```sql
UPDATE utilisateurs
SET 
    user_id = 'UUID_DE_L_UTILISATEUR',  -- ⚠️ Remplacez par l'UUID noté à l'étape 1
    role = 'patient',
    nom = 'Dupont',
    prenom = 'Jean',
    telephone = '+33612345678',
    date_naissance = '1990-05-15',
    adresse = '123 Rue de la Santé',
    ville = 'Paris',
    code_postal = '75001',
    updated_at = NOW()
WHERE email = 'patient@example.com';  -- ⚠️ Même email que dans auth.users
```

**Important** : 
- Remplacez `UUID_DE_L_UTILISATEUR` par l'UUID réel de l'utilisateur créé
- Utilisez le même email que celui utilisé dans Authentication

---

## 🚀 Méthode 2 : Patient de test rapide

Pour créer rapidement un patient de test :

### Identifiants de test suggérés :
- **Email** : `patient@test.com`
- **Mot de passe** : `patient123`

### Étapes :

1. Créez l'utilisateur dans **Authentication** avec ces identifiants
2. Notez l'UUID
3. Exécutez cette requête SQL :

```sql
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
    'UUID_DE_L_UTILISATEUR', -- ⚠️ Remplacez par l'UUID
    'patient',
    'Test',
    'Patient',
    'patient@test.com',
    '+33612345678',
    '1990-01-01',
    '1 Rue Test',
    'Paris',
    '75001'
);
```

---

## 🔍 Vérifier que le patient est créé

Exécutez cette requête pour voir tous les patients :

```sql
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
WHERE role = 'patient'
ORDER BY created_at DESC;
```

---

## 📱 Utiliser les identifiants

Une fois le patient créé, il peut se connecter via l'application mobile avec :
- **Email** : L'email utilisé lors de la création
- **Mot de passe** : Le mot de passe défini dans Supabase Authentication

---

## ⚠️ Dépannage

### Erreur : "duplicate key value violates unique constraint"

Cela signifie qu'un utilisateur avec cet email existe déjà. **Solution** : Utilisez `UPDATE` au lieu de `INSERT`.

1. Vérifiez d'abord ce qui existe :
```sql
SELECT email, role, user_id FROM utilisateurs WHERE email = 'patient@example.com';
```

2. Mettez à jour au lieu d'insérer :
```sql
UPDATE utilisateurs
SET 
    user_id = 'VOTRE_UUID_ICI',
    role = 'patient',
    nom = 'Dubois',
    prenom = 'Marie',
    telephone = '+33612345678',
    date_naissance = '1990-05-15',
    adresse = '123 Rue de la Santé',
    ville = 'Paris',
    code_postal = '75001',
    updated_at = NOW()
WHERE email = 'patient@example.com';
```

### L'utilisateur ne peut pas se connecter

1. Vérifiez que l'utilisateur existe dans `auth.users` :
   - Allez dans **Authentication** > **Users**
   - Cherchez l'email

2. Vérifiez que l'entrée existe dans `utilisateurs` :
   ```sql
   SELECT * FROM utilisateurs WHERE email = 'patient@example.com';
   ```

3. Vérifiez que le rôle est bien `patient` :
   ```sql
   SELECT email, role FROM utilisateurs WHERE email = 'patient@example.com';
   ```

### L'UUID ne correspond pas

Assurez-vous d'utiliser l'UUID de `auth.users`, pas celui de `utilisateurs`. Pour trouver l'UUID :

1. Allez dans **Authentication** > **Users**
2. Cliquez sur l'utilisateur
3. L'UUID est visible en haut de la page (format : `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

---

## 📝 Exemple complet

Voici un exemple complet pour créer un patient nommé "Marie Dubois" :

### 1. Dans Authentication :
- Email : `marie.dubois@example.com`
- Password : `Marie123!`
- Auto Confirm : ✅

### 2. UUID noté : `a1b2c3d4-e5f6-7890-abcd-ef1234567890`

### 3. Requête SQL :

```sql
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
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'patient',
    'Dubois',
    'Marie',
    'marie.dubois@example.com',
    '+33698765432',
    '1992-03-20',
    '45 Avenue des Fleurs',
    'Lyon',
    '69001'
);
```

### 4. Identifiants de connexion :
- Email : `marie.dubois@example.com`
- Mot de passe : `Marie123!`

---

## 🎉 C'est fait !

Le patient peut maintenant se connecter à l'application mobile avec ses identifiants.

