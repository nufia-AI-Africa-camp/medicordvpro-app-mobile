import { createClient } from '@/lib/supabase/server'
import { Notification } from '@/lib/types/database.types'

export async function getNotifications(filters?: {
  type?: string
  isRead?: boolean
  userId?: string
}) {
  const supabase = await createClient()
  let query = supabase
    .from('notifications')
    .select(`
      *,
      utilisateur:utilisateurs(nom, prenom, email)
    `)
    .order('sent_at', { ascending: false })

  if (filters?.type) {
    query = query.eq('type', filters.type)
  }

  if (filters?.isRead !== undefined) {
    query = query.eq('is_read', filters.isRead)
  }

  if (filters?.userId) {
    query = query.eq('utilisateur_id', filters.userId)
  }

  const { data, error } = await query

  if (error) throw error
  return data as any[]
}

export async function markAsRead(id: string) {
  const supabase = await createClient()
  const { error } = await supabase
    .from('notifications')
    .update({ is_read: true, read_at: new Date().toISOString() })
    .eq('id', id)

  if (error) throw error
}

export async function deleteNotification(id: string) {
  const supabase = await createClient()
  const { error } = await supabase
    .from('notifications')
    .delete()
    .eq('id', id)

  if (error) throw error
}

