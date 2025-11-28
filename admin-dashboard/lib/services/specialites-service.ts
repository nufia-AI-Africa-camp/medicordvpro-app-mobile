import { createClient } from '@/lib/supabase/server'
import { Specialite } from '@/lib/types/database.types'

export async function getSpecialites() {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('specialites')
    .select('*')
    .order('nom', { ascending: true })

  if (error) throw error
  return data as Specialite[]
}

export async function getSpecialiteById(id: string) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('specialites')
    .select('*')
    .eq('id', id)
    .single()

  if (error) throw error
  return data as Specialite
}

export async function createSpecialite(specialiteData: Partial<Specialite>) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('specialites')
    .insert(specialiteData)
    .select()
    .single()

  if (error) throw error
  return data as Specialite
}

export async function updateSpecialite(id: string, specialiteData: Partial<Specialite>) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('specialites')
    .update(specialiteData)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data as Specialite
}

export async function deleteSpecialite(id: string) {
  const supabase = await createClient()
  const { error } = await supabase
    .from('specialites')
    .delete()
    .eq('id', id)

  if (error) throw error
}

