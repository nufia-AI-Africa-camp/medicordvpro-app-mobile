'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Pencil, Trash2 } from 'lucide-react'
import { SpecialiteForm } from './SpecialiteForm'
import { Specialite } from '@/lib/types/database.types'

export function SpecialitesActions({ specialite }: { specialite: Specialite }) {
  const [open, setOpen] = useState(false)
  const [deleting, setDeleting] = useState(false)
  const router = useRouter()
  const supabase = createClient()

  const handleDelete = async () => {
    if (!confirm(`Êtes-vous sûr de vouloir supprimer la spécialité ${specialite.nom} ?`)) {
      return
    }

    setDeleting(true)
    try {
      await supabase.from('specialites').delete().eq('id', specialite.id)
      router.refresh()
    } catch (error) {
      console.error('Error deleting specialite:', error)
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
      <SpecialiteForm
        specialite={specialite}
        open={open}
        onOpenChange={setOpen}
        onSuccess={() => router.refresh()}
      />
    </>
  )
}

