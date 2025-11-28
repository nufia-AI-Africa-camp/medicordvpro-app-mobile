# Guide de Configuration Admin - Solution Simple

## 🎯 Explication de l'erreur

L'erreur `relation "admins" does not exist` signifie que vous essayez d'exécuter un script qui référence une table `admins` qui n'existe pas.

**Bonne nouvelle** : Vous n'avez **PAS BESOIN** de créer la table `admins` ! Le dashboard utilise la table `utilisateurs` existante avec le rôle `admin`.

## ✅ Solution Simple (2 étapes)

### Étape 1 : Trouver un utilisateur existant

Exécutez cette requête pour voir vos utilisateurs :

```sql
SELECT id, email, role, nom, prenom 
FROM utilisateurs 
ORDER BY created_at DESC 
LIMIT 10;
```

### Étape 2 : Transformer l'utilisateur en admin

Remplacez `'votre_email@example.com'` par l'email de l'utilisateur que vous voulez transformer :

```sql
UPDATE utilisateurs
SET role = 'admin'
WHERE email = 'votre_email@example.com';
```

**C'est tout !** Vous pouvez maintenant vous connecter au dashboard avec cet utilisateur.

---

## 🚀 Créer un nouvel utilisateur admin

### Méthode 1 : Via l'interface Supabase (RECOMMANDÉ)

1. Allez dans l'onglet **Authentication** de Supabase
2. Cliquez sur **Add user** ou **Create user**
3. Remplissez :
   - Email : `admin@medicord.com`
   - Password : (choisissez un mot de passe fort)
   - Auto Confirm User : ✅ (cocher)
4. Cliquez sur **Create user**
5. **Notez l'UUID** de l'utilisateur créé (visible dans la liste)

6. Exécutez ensuite cette requête SQL (remplacez `UUID_DE_L_UTILISATEUR` par l'UUID noté) :

```sql
INSERT INTO utilisateurs (
    user_id,
    role,
    nom,
    prenom,
    email,
    telephone
)
VALUES (
    'UUID_DE_L_UTILISATEUR', -- ⚠️ Remplacez par l'UUID de auth.users
    'admin',
    'Admin',
    'Super',
    'admin@medicord.com', -- ⚠️ Même email que dans auth.users
    '+33123456789'
);
```

### Méthode 2 : Transformer un utilisateur existant

Si vous avez déjà un utilisateur (patient ou médecin), transformez-le simplement :

```sql
UPDATE utilisateurs
SET role = 'admin'
WHERE email = 'email_existant@example.com';
```

---

## 🔍 Vérifier les admins

```sql
SELECT 
    id,
    email,
    role,
    nom,
    prenom,
    user_id,
    created_at
FROM utilisateurs 
WHERE role = 'admin';
```

---

## 🔐 Se connecter au dashboard

1. Allez sur `http://localhost:3000/login`
2. Entrez l'email et le mot de passe de l'utilisateur admin
3. Vous serez redirigé vers le dashboard

---

## ⚠️ Important

- **Pas besoin de table `admins`** : Le système utilise la table `utilisateurs` avec `role = 'admin'`
- **L'authentification** se fait via Supabase Auth (même système que pour patients/médecins)
- **Le middleware** vérifie automatiquement que l'utilisateur a le rôle `admin` dans la table `utilisateurs`

---

## 🔧 Dépannage

### Erreur "Accès refusé" après connexion

Vérifiez que l'utilisateur a bien le rôle admin :

```sql
SELECT email, role FROM utilisateurs WHERE email = 'votre_email@example.com';
```

Si le rôle n'est pas `admin`, exécutez :

```sql
UPDATE utilisateurs SET role = 'admin' WHERE email = 'votre_email@example.com';
```

### L'utilisateur n'existe pas dans `utilisateurs`

Si vous avez créé l'utilisateur dans `auth.users` mais pas dans `utilisateurs`, créez l'entrée :

```sql
INSERT INTO utilisateurs (
    user_id,
    role,
    nom,
    prenom,
    email,
    telephone
)
VALUES (
    'UUID_DE_L_UTILISATEUR', -- UUID de auth.users
    'admin',
    'Admin',
    'Super',
    'admin@medicord.com',
    '+33123456789'
);
```

---

## 📝 Résumé

1. ✅ Utilisez la table `utilisateurs` existante
2. ✅ Mettez `role = 'admin'` pour un utilisateur
3. ✅ Connectez-vous avec cet utilisateur
4. ❌ **N'essayez PAS** de créer une table `admins` - ce n'est pas nécessaire !
