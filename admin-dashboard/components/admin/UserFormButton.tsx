'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'
import { UserForm } from './UserForm'

export function UserFormButton() {
  const [open, setOpen] = useState(false)

  return (
    <>
      <Button onClick={() => setOpen(true)}>
        <Plus className="h-4 w-4 mr-2" />
        Créer un utilisateur
      </Button>
      <UserForm
        user={null}
        open={open}
        onOpenChange={setOpen}
        onSuccess={() => {}}
      />
    </>
  )
}

