import { createClient } from '@/lib/supabase/server'
import { Utilisateur } from '@/lib/types/database.types'

export async function getUsers(filters?: {
  role?: string
  search?: string
}) {
  const supabase = await createClient()
  let query = supabase.from('utilisateurs').select('*').order('created_at', { ascending: false })

  if (filters?.role) {
    query = query.eq('role', filters.role)
  }

  if (filters?.search) {
    query = query.or(`nom.ilike.%${filters.search}%,prenom.ilike.%${filters.search}%,email.ilike.%${filters.search}%`)
  }

  const { data, error } = await query

  if (error) throw error
  return data as Utilisateur[]
}

export async function getUserById(id: string) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('utilisateurs')
    .select('*')
    .eq('id', id)
    .single()

  if (error) throw error
  return data as Utilisateur
}

export async function createUser(userData: Partial<Utilisateur>) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('utilisateurs')
    .insert(userData)
    .select()
    .single()

  if (error) throw error
  return data as Utilisateur
}

export async function updateUser(id: string, userData: Partial<Utilisateur>) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('utilisateurs')
    .update(userData)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data as Utilisateur
}

export async function deleteUser(id: string) {
  const supabase = await createClient()
  const { error } = await supabase
    .from('utilisateurs')
    .delete()
    .eq('id', id)

  if (error) throw error
}

