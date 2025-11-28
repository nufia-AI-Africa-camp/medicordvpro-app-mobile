# Configuration des variables d'environnement

## Erreur : "Your project's URL and Key are required"

Cette erreur signifie que les variables d'environnement Supabase ne sont pas configurées correctement.

## Solution

1. **Vérifiez que le fichier `.env.local` existe** dans le dossier `admin-dashboard/`

2. **Vérifiez que le fichier contient** (remplacez par vos vraies valeurs) :

```env
NEXT_PUBLIC_SUPABASE_URL=https://jyawxsitqwfeolgnanvj.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sb_publishable_YX5CMRZ5-ia0jirUCHWktg_tml9YMb5
```

3. **Si le fichier n'existe pas ou est vide**, créez-le avec le contenu ci-dessus

4. **Redémarrez le serveur de développement** :
   ```bash
   # Arrêtez le serveur (Ctrl+C)
   # Puis relancez
   npm run dev
   ```

## Où trouver vos credentials Supabase ?

1. Allez sur https://supabase.com/dashboard
2. Sélectionnez votre projet
3. Allez dans **Settings** > **API**
4. Copiez :
   - **Project URL** → `NEXT_PUBLIC_SUPABASE_URL`
   - **anon public** key → `NEXT_PUBLIC_SUPABASE_ANON_KEY`

## Vérification rapide

Le fichier `.env.local` doit être dans :
```
admin-dashboard/
  └── .env.local  ← Ici
```

Et doit contenir exactement :
```
NEXT_PUBLIC_SUPABASE_URL=votre_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=votre_cle
```

**Pas d'espaces** autour du `=` et **pas de guillemets** autour des valeurs.

