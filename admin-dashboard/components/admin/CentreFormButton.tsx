'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'
import { CentreForm } from './CentreForm'

export function CentreFormButton() {
  const [open, setOpen] = useState(false)

  return (
    <>
      <Button onClick={() => setOpen(true)}>
        <Plus className="h-4 w-4 mr-2" />
        Créer un centre
      </Button>
      <CentreForm
        centre={null}
        open={open}
        onOpenChange={setOpen}
        onSuccess={() => {}}
      />
    </>
  )
}

