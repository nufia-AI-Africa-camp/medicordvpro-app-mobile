import { createClient } from '@/lib/supabase/server'

export async function checkAdminAccess() {
  const supabase = await createClient()
  
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    return { isAdmin: false, user: null }
  }

  const { data: utilisateur } = await supabase
    .from('utilisateurs')
    .select('*')
    .eq('user_id', user.id)
    .single()

  return {
    isAdmin: utilisateur?.role === 'admin',
    user: utilisateur,
  }
}

export async function logout() {
  const supabase = await createClient()
  await supabase.auth.signOut()
}

