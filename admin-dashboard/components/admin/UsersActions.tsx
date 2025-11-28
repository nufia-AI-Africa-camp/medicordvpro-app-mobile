'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Pencil, Trash2 } from 'lucide-react'
import { UserForm } from './UserForm'
import { Utilisateur } from '@/lib/types/database.types'

export function UsersActions({ user }: { user: Utilisateur }) {
  const [open, setOpen] = useState(false)
  const [deleting, setDeleting] = useState(false)
  const router = useRouter()
  const supabase = createClient()

  const handleDelete = async () => {
    if (!confirm(`Êtes-vous sûr de vouloir supprimer ${user.prenom} ${user.nom} ?`)) {
      return
    }

    setDeleting(true)
    try {
      await supabase.from('utilisateurs').delete().eq('id', user.id)
      router.refresh()
    } catch (error) {
      console.error('Error deleting user:', error)
      alert('Erreur lors de la suppression')
    } finally {
      setDeleting(false)
    }
  }

  return (
    <>
      <div className="flex items-center gap-2">
        <Button
          variant="ghost"
          size="sm"
          onClick={() => setOpen(true)}
        >
          <Pencil className="h-4 w-4" />
        </Button>
        <Button
          variant="ghost"
          size="sm"
          onClick={handleDelete}
          disabled={deleting}
        >
          <Trash2 className="h-4 w-4 text-destructive" />
        </Button>
      </div>
      <UserForm
        user={user}
        open={open}
        onOpenChange={setOpen}
        onSuccess={() => router.refresh()}
      />
    </>
  )
}

