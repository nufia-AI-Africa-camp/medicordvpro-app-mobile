import { createClient } from '@/lib/supabase/server'

export async function getDashboardStats() {
  const supabase = await createClient()

  // Nombre total d'utilisateurs
  const { count: totalUsers } = await supabase
    .from('utilisateurs')
    .select('*', { count: 'exact', head: true })

  // Nombre de patients
  const { count: totalPatients } = await supabase
    .from('utilisateurs')
    .select('*', { count: 'exact', head: true })
    .eq('role', 'patient')

  // Nombre de médecins
  const { count: totalMedecins } = await supabase
    .from('utilisateurs')
    .select('*', { count: 'exact', head: true })
    .eq('role', 'medecin')

  // Rendez-vous du jour
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const tomorrow = new Date(today)
  tomorrow.setDate(tomorrow.getDate() + 1)

  const { count: rdvToday } = await supabase
    .from('rendez_vous')
    .select('*', { count: 'exact', head: true })
    .gte('date_heure', today.toISOString())
    .lt('date_heure', tomorrow.toISOString())

  // Rendez-vous de la semaine
  const weekStart = new Date(today)
  weekStart.setDate(weekStart.getDate() - weekStart.getDay())
  const weekEnd = new Date(weekStart)
  weekEnd.setDate(weekEnd.getDate() + 7)

  const { count: rdvWeek } = await supabase
    .from('rendez_vous')
    .select('*', { count: 'exact', head: true })
    .gte('date_heure', weekStart.toISOString())
    .lt('date_heure', weekEnd.toISOString())

  // Rendez-vous du mois
  const monthStart = new Date(today.getFullYear(), today.getMonth(), 1)
  const monthEnd = new Date(today.getFullYear(), today.getMonth() + 1, 1)

  const { count: rdvMonth } = await supabase
    .from('rendez_vous')
    .select('*', { count: 'exact', head: true })
    .gte('date_heure', monthStart.toISOString())
    .lt('date_heure', monthEnd.toISOString())

  // Total de rendez-vous
  const { count: totalRdv } = await supabase
    .from('rendez_vous')
    .select('*', { count: 'exact', head: true })

  // Rendez-vous confirmés
  const { count: rdvConfirmes } = await supabase
    .from('rendez_vous')
    .select('*', { count: 'exact', head: true })
    .eq('statut', 'confirmé')

  // Rendez-vous annulés
  const { count: rdvAnnules } = await supabase
    .from('rendez_vous')
    .select('*', { count: 'exact', head: true })
    .eq('statut', 'annulé')

  // Évolution des rendez-vous (7 derniers jours)
  const evolutionData = []
  for (let i = 6; i >= 0; i--) {
    const date = new Date(today)
    date.setDate(date.getDate() - i)
    const dayStart = new Date(date)
    dayStart.setHours(0, 0, 0, 0)
    const dayEnd = new Date(date)
    dayEnd.setHours(23, 59, 59, 999)

    const { count } = await supabase
      .from('rendez_vous')
      .select('*', { count: 'exact', head: true })
      .gte('date_heure', dayStart.toISOString())
      .lte('date_heure', dayEnd.toISOString())

    evolutionData.push({
      date: date.toISOString().split('T')[0],
      count: count || 0,
    })
  }

  // Répartition par spécialité
  const { data: specialitesData } = await supabase
    .from('utilisateurs')
    .select('specialite_id, specialites(nom)')
    .eq('role', 'medecin')
    .not('specialite_id', 'is', null)

  const specialitesCount: Record<string, number> = {}
  specialitesData?.forEach((item: any) => {
    const nom = item.specialites?.nom || 'Non spécifié'
    specialitesCount[nom] = (specialitesCount[nom] || 0) + 1
  })

  const repartitionSpecialites = Object.entries(specialitesCount).map(([nom, count]) => ({
    nom,
    count,
  }))

  return {
    totalUsers: totalUsers || 0,
    totalPatients: totalPatients || 0,
    totalMedecins: totalMedecins || 0,
    rdvToday: rdvToday || 0,
    rdvWeek: rdvWeek || 0,
    rdvMonth: rdvMonth || 0,
    totalRdv: totalRdv || 0,
    rdvConfirmes: rdvConfirmes || 0,
    rdvAnnules: rdvAnnules || 0,
    evolutionData,
    repartitionSpecialites,
  }
}

