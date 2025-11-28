import { createClient } from '@/lib/supabase/server'
import { RendezVous } from '@/lib/types/database.types'

export async function getAppointments(filters?: {
  status?: string
  dateFrom?: string
  dateTo?: string
}) {
  const supabase = await createClient()
  let query = supabase
    .from('rendez_vous')
    .select(`
      *,
      patient:utilisateurs!rendez_vous_patient_utilisateur_id_fkey(nom, prenom, email),
      medecin:utilisateurs!rendez_vous_medecin_utilisateur_id_fkey(nom, prenom, email),
      centre:centres_medicaux(nom, ville)
    `)
    .order('date_heure', { ascending: false })

  if (filters?.status) {
    query = query.eq('statut', filters.status)
  }

  if (filters?.dateFrom) {
    query = query.gte('date_heure', filters.dateFrom)
  }

  if (filters?.dateTo) {
    query = query.lte('date_heure', filters.dateTo)
  }

  const { data, error } = await query

  if (error) throw error
  return data as any[]
}

export async function getAppointmentById(id: string) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('rendez_vous')
    .select(`
      *,
      patient:utilisateurs!rendez_vous_patient_utilisateur_id_fkey(*),
      medecin:utilisateurs!rendez_vous_medecin_utilisateur_id_fkey(*),
      centre:centres_medicaux(*)
    `)
    .eq('id', id)
    .single()

  if (error) throw error
  return data
}

export async function createAppointment(appointmentData: Partial<RendezVous>) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('rendez_vous')
    .insert(appointmentData)
    .select()
    .single()

  if (error) throw error
  return data as RendezVous
}

export async function updateAppointment(id: string, appointmentData: Partial<RendezVous>) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('rendez_vous')
    .update(appointmentData)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data as RendezVous
}

export async function deleteAppointment(id: string) {
  const supabase = await createClient()
  const { error } = await supabase
    .from('rendez_vous')
    .delete()
    .eq('id', id)

  if (error) throw error
}

