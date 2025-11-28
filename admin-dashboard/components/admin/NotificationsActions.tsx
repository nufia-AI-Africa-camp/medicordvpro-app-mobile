'use client'

import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Check, Trash2 } from 'lucide-react'

export function NotificationsActions({ notification }: { notification: any }) {
  const router = useRouter()
  const supabase = createClient()

  const handleMarkAsRead = async () => {
    try {
      await supabase
        .from('notifications')
        .update({ is_read: true, read_at: new Date().toISOString() })
        .eq('id', notification.id)
      router.refresh()
    } catch (error) {
      console.error('Error marking as read:', error)
      alert('Erreur lors de la mise à jour')
    }
  }

  const handleDelete = async () => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette notification ?')) {
      return
    }

    try {
      await supabase.from('notifications').delete().eq('id', notification.id)
      router.refresh()
    } catch (error) {
      console.error('Error deleting notification:', error)
      alert('Erreur lors de la suppression')
    }
  }

  return (
    <div className="flex items-center gap-2">
      {!notification.is_read && (
        <Button
          variant="ghost"
          size="sm"
          onClick={handleMarkAsRead}
        >
          <Check className="h-4 w-4" />
        </Button>
      )}
      <Button
        variant="ghost"
        size="sm"
        onClick={handleDelete}
      >
        <Trash2 className="h-4 w-4 text-destructive" />
      </Button>
    </div>
  )
}

