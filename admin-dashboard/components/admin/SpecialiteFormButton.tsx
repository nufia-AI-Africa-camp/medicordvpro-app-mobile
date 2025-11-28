'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'
import { SpecialiteForm } from './SpecialiteForm'

export function SpecialiteFormButton() {
  const [open, setOpen] = useState(false)

  return (
    <>
      <Button onClick={() => setOpen(true)}>
        <Plus className="h-4 w-4 mr-2" />
        Créer une spécialité
      </Button>
      <SpecialiteForm
        specialite={null}
        open={open}
        onOpenChange={setOpen}
        onSuccess={() => {}}
      />
    </>
  )
}

