import { createClient } from '@/lib/supabase/server'
import { CentreMedical } from '@/lib/types/database.types'

export async function getCentres() {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('centres_medicaux')
    .select('*')
    .order('nom', { ascending: true })

  if (error) throw error
  return data as CentreMedical[]
}

export async function getCentreById(id: string) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('centres_medicaux')
    .select('*')
    .eq('id', id)
    .single()

  if (error) throw error
  return data as CentreMedical
}

export async function createCentre(centreData: Partial<CentreMedical>) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('centres_medicaux')
    .insert(centreData)
    .select()
    .single()

  if (error) throw error
  return data as CentreMedical
}

export async function updateCentre(id: string, centreData: Partial<CentreMedical>) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('centres_medicaux')
    .update(centreData)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data as CentreMedical
}

export async function deleteCentre(id: string) {
  const supabase = await createClient()
  const { error } = await supabase
    .from('centres_medicaux')
    .delete()
    .eq('id', id)

  if (error) throw error
}

