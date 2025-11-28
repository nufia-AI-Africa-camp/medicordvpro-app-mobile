# Dashboard Admin - MediCordVPro

Dashboard d'administration complet pour la gestion de la plateforme MediCordVPro.

## 🚀 Fonctionnalités

- **Authentification Admin** : Connexion sécurisée avec vérification du rôle admin
- **Dashboard** : Vue d'ensemble avec statistiques et graphiques
- **Gestion des Utilisateurs** : CRUD complet pour patients et médecins
- **Gestion des Rendez-vous** : Visualisation et gestion de tous les rendez-vous
- **Gestion des Spécialités** : CRUD pour les spécialités médicales
- **Gestion des Centres Médicaux** : CRUD pour les centres médicaux
- **Notifications** : Gestion de toutes les notifications
- **Statistiques** : Rapports détaillés et analyses

## 📋 Prérequis

- Node.js 18+ 
- npm ou yarn
- Compte Supabase avec la base de données configurée

## 🛠️ Installation

1. Installer les dépendances :
```bash
npm install
```

2. Configurer les variables d'environnement :
Créer un fichier `.env.local` à la racine du projet :
```env
NEXT_PUBLIC_SUPABASE_URL=votre_url_supabase
NEXT_PUBLIC_SUPABASE_ANON_KEY=votre_cle_anon_supabase
```

3. Appliquer les migrations Supabase :
Exécuter le fichier `supabase/migrations/admin-rls-policies.sql` dans votre base Supabase pour configurer les RLS policies pour les admins.

## 🚀 Démarrage

```bash
# Mode développement
npm run dev

# Build de production
npm run build

# Démarrer en production
npm start
```

Le dashboard sera accessible sur `http://localhost:3000`

## 🔐 Authentification

1. Créer un utilisateur admin dans Supabase :
   - Créer un utilisateur dans `auth.users`
   - Créer une entrée correspondante dans `utilisateurs` avec `role = 'admin'`

2. Se connecter avec les identifiants de l'utilisateur admin

## 📁 Structure du projet

```
admin-dashboard/
├── app/
│   ├── (auth)/          # Routes d'authentification
│   ├── (dashboard)/      # Routes du dashboard (protégées)
│   └── layout.tsx        # Layout principal
├── components/
│   ├── admin/            # Composants admin
│   ├── layout/           # Composants de layout
│   └── ui/               # Composants UI (shadcn/ui)
├── lib/
│   ├── services/         # Services pour les appels API
│   ├── supabase/         # Configuration Supabase
│   └── types/            # Types TypeScript
└── supabase/
    └── migrations/       # Migrations SQL
```

## 🎨 Technologies utilisées

- **Next.js 14+** : Framework React avec App Router
- **TypeScript** : Typage statique
- **Tailwind CSS** : Styling
- **shadcn/ui** : Composants UI
- **Supabase** : Backend et authentification
- **TanStack Table** : Tableaux de données
- **Recharts** : Graphiques
- **date-fns** : Manipulation de dates

## 🔒 Sécurité

- Vérification du rôle admin à chaque requête
- RLS policies dans Supabase
- Middleware Next.js pour protéger les routes
- Validation des données côté client et serveur

## 📝 Notes

- Assurez-vous que les RLS policies sont correctement configurées dans Supabase
- Le middleware vérifie automatiquement le rôle admin sur toutes les routes protégées
- Les données sont rafraîchies automatiquement après chaque action CRUD
