# 💳 Guide d'Implémentation - Système de Paiement

## 🎯 Vue d'ensemble

Ce guide explique comment implémenter techniquement les modèles de monétisation pour MediCordVPro.

---

## 📦 1. INTÉGRATION STRIPE

### Installation

Ajoutez Stripe à votre `pubspec.yaml` :

```yaml
dependencies:
  flutter_stripe: ^11.0.0
  http: ^1.1.0
```

### Configuration Stripe

Créez un fichier `lib/core/config/stripe_config.dart` :

```dart
class StripeConfig {
  // Test keys (remplacez par vos clés réelles)
  static const String publishableKey = 'pk_test_...';
  static const String secretKey = 'sk_test_...'; // À stocker côté serveur uniquement
  
  // Production keys
  static const String publishableKeyProd = 'pk_live_...';
  
  // Webhook secret (pour valider les webhooks)
  static const String webhookSecret = 'whsec_...';
}
```

### Initialisation

Dans `main.dart` ou votre fichier d'initialisation :

```dart
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Supabase
  await Supabase.initialize(...);
  
  // Initialiser Stripe
  Stripe.publishableKey = StripeConfig.publishableKey;
  await Stripe.instance.applySettings();
  
  runApp(MyApp());
}
```

---

## 🗄️ 2. STRUCTURE BASE DE DONNÉES

### Tables SQL à créer dans Supabase

```sql
-- =====================================================
-- TABLE: abonnements_medecins
-- =====================================================
CREATE TABLE abonnements_medecins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    medecin_utilisateur_id UUID REFERENCES utilisateurs(id) ON DELETE CASCADE,
    plan_id VARCHAR(50) NOT NULL, -- 'free', 'essentiel', 'professionnel', 'premium'
    stripe_subscription_id VARCHAR(255), -- ID de l'abonnement Stripe
    stripe_customer_id VARCHAR(255), -- ID du client Stripe
    prix_mensuel DECIMAL(10, 2) NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE,
    prochaine_echeance DATE,
    statut VARCHAR(20) DEFAULT 'actif', -- 'actif', 'annule', 'expire', 'en_attente'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(medecin_utilisateur_id)
);

-- =====================================================
-- TABLE: transactions
-- =====================================================
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rendez_vous_id UUID REFERENCES rendez_vous(id),
    utilisateur_id UUID REFERENCES utilisateurs(id), -- Patient qui paie
    medecin_utilisateur_id UUID REFERENCES utilisateurs(id), -- Médecin qui reçoit
    
    -- Montants
    montant_total DECIMAL(10, 2) NOT NULL, -- Montant payé par le patient
    commission_plateforme DECIMAL(10, 2) NOT NULL, -- Notre commission
    montant_medecin DECIMAL(10, 2) NOT NULL, -- Montant reversé au médecin
    
    -- Stripe
    stripe_payment_intent_id VARCHAR(255),
    stripe_charge_id VARCHAR(255),
    
    -- Statut
    statut VARCHAR(20) DEFAULT 'en_attente', -- 'en_attente', 'paye', 'rembourse', 'echoue'
    
    -- Dates
    date_paiement TIMESTAMP WITH TIME ZONE,
    date_remboursement TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE: reversements_medecins
-- =====================================================
CREATE TABLE reversements_medecins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    medecin_utilisateur_id UUID REFERENCES utilisateurs(id),
    transaction_id UUID REFERENCES transactions(id),
    montant DECIMAL(10, 2) NOT NULL,
    stripe_transfer_id VARCHAR(255), -- ID du transfert Stripe
    statut VARCHAR(20) DEFAULT 'en_attente', -- 'en_attente', 'transfere', 'erreur'
    date_transfert TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE: fonctionnalites_plan
-- =====================================================
CREATE TABLE fonctionnalites_plan (
    plan_id VARCHAR(50) PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prix_mensuel DECIMAL(10, 2) NOT NULL,
    rdv_illimites BOOLEAN DEFAULT FALSE,
    rdv_max INTEGER, -- NULL = illimité
    statistiques_avancees BOOLEAN DEFAULT FALSE,
    rappels_auto BOOLEAN DEFAULT FALSE,
    multi_centres BOOLEAN DEFAULT FALSE,
    support_prioritaire BOOLEAN DEFAULT FALSE,
    pas_de_publicite BOOLEAN DEFAULT FALSE,
    export_donnees BOOLEAN DEFAULT FALSE,
    api_access BOOLEAN DEFAULT FALSE
);

-- Insérer les plans
INSERT INTO fonctionnalites_plan (plan_id, nom, prix_mensuel, rdv_max, statistiques_avancees, rappels_auto, pas_de_publicite) VALUES
('free', 'Gratuit', 0.00, 10, false, false, false),
('essentiel', 'Essentiel', 29.00, NULL, false, true, true),
('professionnel', 'Professionnel', 79.00, NULL, true, true, true),
('premium', 'Premium', 149.00, NULL, true, true, true);

-- =====================================================
-- RLS Policies
-- =====================================================

-- Médecins peuvent voir leur abonnement
ALTER TABLE abonnements_medecins ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Médecins peuvent voir leur abonnement"
    ON abonnements_medecins
    FOR SELECT
    USING (medecin_utilisateur_id = auth.uid()::text);

-- Médecins peuvent voir leurs transactions
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Médecins peuvent voir leurs transactions"
    ON transactions
    FOR SELECT
    USING (medecin_utilisateur_id::text = (SELECT id::text FROM utilisateurs WHERE user_id = auth.uid()));
```

---

## 🔧 3. SERVICES DART

### Service d'Abonnement

Créez `lib/core/services/subscription_service.dart` :

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionService {
  final SupabaseClient _client = Supabase.instance.client;
  
  // Récupérer l'abonnement d'un médecin
  Future<Map<String, dynamic>?> getDoctorSubscription(String medecinId) async {
    final response = await _client
        .from('abonnements_medecins')
        .select()
        .eq('medecin_utilisateur_id', medecinId)
        .maybeSingle();
    
    return response;
  }
  
  // Vérifier si un médecin peut créer un RDV (limitation du plan)
  Future<bool> canCreateAppointment(String medecinId) async {
    final subscription = await getDoctorSubscription(medecinId);
    
    if (subscription == null) {
      // Pas d'abonnement = plan gratuit
      return await checkFreePlanLimits(medecinId);
    }
    
    final planId = subscription['plan_id'] as String;
    
    // Plans payants = illimités
    if (planId != 'free') {
      return true;
    }
    
    return await checkFreePlanLimits(medecinId);
  }
  
  // Vérifier les limites du plan gratuit
  Future<bool> checkFreePlanLimits(String medecinId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final count = await _client
        .from('rendez_vous')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('medecin_utilisateur_id', medecinId)
        .gte('date_heure', startOfMonth.toIso8601String())
        .lt('date_heure', DateTime(now.year, now.month + 1, 1).toIso8601String());
    
    final rdvCount = count.count ?? 0;
    return rdvCount < 10; // Limite plan gratuit = 10 RDV/mois
  }
  
  // Vérifier si une fonctionnalité est disponible
  Future<bool> hasFeature(String medecinId, String feature) async {
    final subscription = await getDoctorSubscription(medecinId);
    
    if (subscription == null) {
      return false; // Plan gratuit = pas de fonctionnalités premium
    }
    
    final planId = subscription['plan_id'] as String;
    
    final plan = await _client
        .from('fonctionnalites_plan')
        .select()
        .eq('plan_id', planId)
        .single();
    
    return plan[feature] == true;
  }
  
  // Créer un abonnement (appelé après paiement Stripe)
  Future<void> createSubscription({
    required String medecinId,
    required String planId,
    required String stripeSubscriptionId,
    required String stripeCustomerId,
    required double prixMensuel,
  }) async {
    await _client.from('abonnements_medecins').upsert({
      'medecin_utilisateur_id': medecinId,
      'plan_id': planId,
      'stripe_subscription_id': stripeSubscriptionId,
      'stripe_customer_id': stripeCustomerId,
      'prix_mensuel': prixMensuel,
      'date_debut': DateTime.now().toIso8601String(),
      'statut': 'actif',
    });
  }
}
```

### Service de Paiement

Créez `lib/core/services/payment_service.dart` :

```dart
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final SupabaseClient _client = Supabase.instance.client;
  
  // Calculer la commission
  double calculateCommission(double montantTotal) {
    // Option 1: Pourcentage (12%)
    final commissionPercentage = 0.12;
    
    // Option 2: Minimum fixe (3€)
    final minimumCommission = 3.0;
    
    final commissionCalculated = montantTotal * commissionPercentage;
    return commissionCalculated > minimumCommission 
        ? commissionCalculated 
        : minimumCommission;
  }
  
  // Payer un rendez-vous
  Future<Map<String, dynamic>> payAppointment({
    required String rendezVousId,
    required double montantTotal,
    required String patientId,
  }) async {
    try {
      // 1. Calculer les montants
      final commission = calculateCommission(montantTotal);
      final montantMedecin = montantTotal - commission;
      
      // 2. Créer le PaymentIntent côté serveur (Supabase Edge Function)
      // Pour l'instant, on simule avec une création directe
      final paymentIntent = await createPaymentIntent(
        amount: (montantTotal * 100).toInt(), // Stripe utilise les centimes
        currency: 'eur',
      );
      
      // 3. Confirmer le paiement côté client
      await Stripe.instance.confirmPayment(
        paymentIntent['client_secret'],
        PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      
      // 4. Enregistrer la transaction
      final transaction = await _client
          .from('transactions')
          .insert({
            'rendez_vous_id': rendezVousId,
            'utilisateur_id': patientId,
            'montant_total': montantTotal,
            'commission_plateforme': commission,
            'montant_medecin': montantMedecin,
            'stripe_payment_intent_id': paymentIntent['id'],
            'statut': 'paye',
            'date_paiement': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      // 5. Mettre à jour le rendez-vous
      await _client
          .from('rendez_vous')
          .update({
            'montant': montantTotal,
            'paiement_statut': 'paye',
          })
          .eq('id', rendezVousId);
      
      return {
        'success': true,
        'transaction': transaction,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Créer un PaymentIntent (doit être fait côté serveur en production)
  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
  }) async {
    // ⚠️ ATTENTION: En production, cette fonction doit être appelée
    // via une Supabase Edge Function ou votre backend sécurisé
    // pour ne pas exposer votre clé secrète Stripe
    
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer ${StripeConfig.secretKey}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': amount.toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      },
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur création PaymentIntent: ${response.body}');
    }
  }
  
  // S'abonner à un plan (médecin)
  Future<Map<String, dynamic>> subscribeToPlan({
    required String medecinId,
    required String planId,
    required String paymentMethodId,
  }) async {
    try {
      // 1. Récupérer les infos du plan
      final plan = await _client
          .from('fonctionnalites_plan')
          .select()
          .eq('plan_id', planId)
          .single();
      
      final prixMensuel = (plan['prix_mensuel'] as num).toDouble();
      
      // 2. Créer un customer Stripe (côté serveur recommandé)
      // 3. Créer un abonnement Stripe (côté serveur recommandé)
      
      // 4. Enregistrer l'abonnement dans la base
      await _client.from('abonnements_medecins').upsert({
        'medecin_utilisateur_id': medecinId,
        'plan_id': planId,
        'prix_mensuel': prixMensuel,
        'date_debut': DateTime.now().toIso8601String(),
        'statut': 'actif',
      });
      
      return {
        'success': true,
        'plan': plan,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
```

---

## 🎨 4. INTERFACE UTILISATEUR

### Écran de Gestion d'Abonnement

Créez `lib/subscription/presentation/subscription_screen.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/subscription_service.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionService = SubscriptionService();
    final medecinId = ref.read(currentUserIdProvider); // À adapter
    
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Abonnement')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: subscriptionService.getDoctorSubscription(medecinId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final subscription = snapshot.data;
          
          if (subscription == null) {
            return _buildFreePlan(context);
          }
          
          return _buildCurrentPlan(context, subscription);
        },
      ),
    );
  }
  
  Widget _buildFreePlan(BuildContext context) {
    return Column(
      children: [
        _buildPlanCard(
          context,
          title: 'Plan Gratuit',
          price: '0€',
          features: [
            'Jusqu\'à 10 RDV/mois',
            'Fonctionnalités de base',
            'Publicité sur le profil',
          ],
          isCurrent: true,
        ),
        _buildPlanCard(
          context,
          title: 'Plan Essentiel',
          price: '29€/mois',
          features: [
            'RDV illimités',
            'Rappels automatiques',
            'Statistiques de base',
            'Sans publicité',
          ],
          onTap: () => _showUpgradeDialog(context, 'essentiel'),
        ),
        // ... autres plans
      ],
    );
  }
  
  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    bool isCurrent = false,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...features.map((f) => Text('• $f')),
            if (isCurrent)
              const Chip(label: Text('Plan actuel'), backgroundColor: Colors.green),
          ],
        ),
        trailing: isCurrent ? null : ElevatedButton(
          onPressed: onTap,
          child: const Text('S\'abonner'),
        ),
      ),
    );
  }
  
  void _showUpgradeDialog(BuildContext context, String planId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Passer au plan supérieur'),
        content: const Text('Vous allez être redirigé vers le paiement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Naviguer vers l'écran de paiement
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔔 5. WEBHOOKS STRIPE (Supabase Edge Function)

Créez une Edge Function pour gérer les webhooks Stripe.

Fichier: `supabase/functions/stripe-webhook/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const stripe = require('https://esm.sh/stripe@14.21.0')(Deno.env.get('STRIPE_SECRET_KEY'))
const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')

serve(async (req) => {
  try {
    const signature = req.headers.get('stripe-signature')
    const body = await req.text()
    
    // Vérifier la signature
    const event = stripe.webhooks.constructEvent(body, signature, webhookSecret)
    
    // Traiter l'événement
    switch (event.type) {
      case 'payment_intent.succeeded':
        await handlePaymentSuccess(event.data.object)
        break
      
      case 'customer.subscription.created':
      case 'customer.subscription.updated':
        await handleSubscriptionUpdate(event.data.object)
        break
      
      case 'customer.subscription.deleted':
        await handleSubscriptionCancelled(event.data.object)
        break
    }
    
    return new Response(JSON.stringify({ received: true }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})

async function handlePaymentSuccess(paymentIntent: any) {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  // Mettre à jour la transaction
  await supabase
    .from('transactions')
    .update({ statut: 'paye', date_paiement: new Date().toISOString() })
    .eq('stripe_payment_intent_id', paymentIntent.id)
}

async function handleSubscriptionUpdate(subscription: any) {
  // Mettre à jour l'abonnement dans la base
  // ...
}
```

---

## 📊 6. TABLEAU DE BORD FINANCIER

### Widget de Statistiques Revenus

```dart
class RevenueStatsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          Text('Revenus du mois'),
          Text('1,250€', style: TextStyle(fontSize: 32)),
          Text('+15% vs mois dernier'),
          
          Row(
            children: [
              Expanded(child: _buildStatCard('Abonnements', '450€')),
              Expanded(child: _buildStatCard('Commissions', '800€')),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## ✅ CHECKLIST D'IMPLÉMENTATION

- [ ] Installer et configurer Stripe
- [ ] Créer les tables SQL dans Supabase
- [ ] Implémenter SubscriptionService
- [ ] Implémenter PaymentService
- [ ] Créer l'écran de gestion d'abonnement
- [ ] Créer l'écran de paiement
- [ ] Configurer les webhooks Stripe
- [ ] Créer le tableau de bord financier
- [ ] Tester le flux complet
- [ ] Mettre en place les notifications de paiement

---

**Note importante :** Pour la sécurité, les clés secrètes Stripe doivent être stockées côté serveur uniquement. Utilisez Supabase Edge Functions pour les opérations sensibles.


