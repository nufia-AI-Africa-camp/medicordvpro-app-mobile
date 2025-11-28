-- =====================================================
-- RLS POLICIES POUR ADMIN
-- Dashboard Admin Next.js - MediCordVPro
-- =====================================================

-- Fonction helper pour vérifier si l'utilisateur est admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM utilisateurs
    WHERE user_id = auth.uid()
    AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- POLICIES POUR UTILISATEURS
-- =====================================================

-- Admin peut voir tous les utilisateurs
CREATE POLICY "Admin peut voir tous les utilisateurs"
  ON utilisateurs FOR SELECT
  TO authenticated
  USING (is_admin());

-- Admin peut créer des utilisateurs
CREATE POLICY "Admin peut créer des utilisateurs"
  ON utilisateurs FOR INSERT
  TO authenticated
  WITH CHECK (is_admin());

-- Admin peut modifier tous les utilisateurs
CREATE POLICY "Admin peut modifier tous les utilisateurs"
  ON utilisateurs FOR UPDATE
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Admin peut supprimer des utilisateurs
CREATE POLICY "Admin peut supprimer des utilisateurs"
  ON utilisateurs FOR DELETE
  TO authenticated
  USING (is_admin());

-- =====================================================
-- POLICIES POUR RENDEZ-VOUS
-- =====================================================

-- Admin peut voir tous les rendez-vous
CREATE POLICY "Admin peut voir tous les rendez-vous"
  ON rendez_vous FOR SELECT
  TO authenticated
  USING (is_admin());

-- Admin peut créer des rendez-vous
CREATE POLICY "Admin peut créer des rendez-vous"
  ON rendez_vous FOR INSERT
  TO authenticated
  WITH CHECK (is_admin());

-- Admin peut modifier tous les rendez-vous
CREATE POLICY "Admin peut modifier tous les rendez-vous"
  ON rendez_vous FOR UPDATE
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Admin peut supprimer des rendez-vous
CREATE POLICY "Admin peut supprimer des rendez-vous"
  ON rendez_vous FOR DELETE
  TO authenticated
  USING (is_admin());

-- =====================================================
-- POLICIES POUR NOTIFICATIONS
-- =====================================================

-- Admin peut voir toutes les notifications
CREATE POLICY "Admin peut voir toutes les notifications"
  ON notifications FOR SELECT
  TO authenticated
  USING (is_admin());

-- Admin peut créer des notifications
CREATE POLICY "Admin peut créer des notifications"
  ON notifications FOR INSERT
  TO authenticated
  WITH CHECK (is_admin());

-- Admin peut modifier toutes les notifications
CREATE POLICY "Admin peut modifier toutes les notifications"
  ON notifications FOR UPDATE
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Admin peut supprimer des notifications
CREATE POLICY "Admin peut supprimer des notifications"
  ON notifications FOR DELETE
  TO authenticated
  USING (is_admin());

-- =====================================================
-- POLICIES POUR HISTORIQUE CONSULTATIONS
-- =====================================================

-- Admin peut voir tout l'historique
CREATE POLICY "Admin peut voir tout l'historique"
  ON historique_consultations FOR SELECT
  TO authenticated
  USING (is_admin());

-- Admin peut créer des entrées d'historique
CREATE POLICY "Admin peut créer des entrées d'historique"
  ON historique_consultations FOR INSERT
  TO authenticated
  WITH CHECK (is_admin());

-- Admin peut modifier l'historique
CREATE POLICY "Admin peut modifier l'historique"
  ON historique_consultations FOR UPDATE
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Admin peut supprimer l'historique
CREATE POLICY "Admin peut supprimer l'historique"
  ON historique_consultations FOR DELETE
  TO authenticated
  USING (is_admin());

-- =====================================================
-- POLICIES POUR SPÉCIALITÉS
-- =====================================================

-- Admin peut gérer toutes les spécialités
CREATE POLICY "Admin peut gérer les spécialités"
  ON specialites FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- =====================================================
-- POLICIES POUR CENTRES MÉDICAUX
-- =====================================================

-- Admin peut gérer tous les centres médicaux
CREATE POLICY "Admin peut gérer les centres médicaux"
  ON centres_medicaux FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- =====================================================
-- POLICIES POUR HORAIRES MÉDECINS
-- =====================================================

-- Admin peut voir tous les horaires
CREATE POLICY "Admin peut voir tous les horaires"
  ON horaires_medecins FOR SELECT
  TO authenticated
  USING (is_admin());

-- Admin peut gérer tous les horaires
CREATE POLICY "Admin peut gérer tous les horaires"
  ON horaires_medecins FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- =====================================================
-- POLICIES POUR INDISPONIBILITÉS
-- =====================================================

-- Admin peut voir toutes les indisponibilités
CREATE POLICY "Admin peut voir toutes les indisponibilités"
  ON indisponibilites FOR SELECT
  TO authenticated
  USING (is_admin());

-- Admin peut gérer toutes les indisponibilités
CREATE POLICY "Admin peut gérer toutes les indisponibilités"
  ON indisponibilites FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- =====================================================
-- POLICIES POUR FAVORIS
-- =====================================================

-- Admin peut voir tous les favoris
CREATE POLICY "Admin peut voir tous les favoris"
  ON favoris FOR SELECT
  TO authenticated
  USING (is_admin());

-- Admin peut gérer tous les favoris
CREATE POLICY "Admin peut gérer tous les favoris"
  ON favoris FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

