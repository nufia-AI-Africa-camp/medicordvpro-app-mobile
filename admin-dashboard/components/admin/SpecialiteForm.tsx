'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Specialite } from '@/lib/types/database.types'

interface SpecialiteFormProps {
  specialite?: Specialite | null
  open: boolean
  onOpenChange: (open: boolean) => void
  onSuccess: () => void
}

export function SpecialiteForm({ specialite, open, onOpenChange, onSuccess }: SpecialiteFormProps) {
  const router = useRouter()
  const supabase = createClient()
  const [loading, setLoading] = useState(false)

  const [formData, setFormData] = useState({
    nom: '',
    description: '',
    icone: '',
  })

  useEffect(() => {
    if (specialite) {
      setFormData({
        nom: specialite.nom || '',
        description: specialite.description || '',
        icone: specialite.icone || '',
      })
    } else {
      setFormData({
        nom: '',
        description: '',
        icone: '',
      })
    }
  }, [specialite, open])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      if (specialite) {
        await supabase
          .from('specialites')
          .update(formData)
          .eq('id', specialite.id)
      } else {
        await supabase
          .from('specialites')
          .insert(formData)
      }

      onSuccess()
      onOpenChange(false)
      router.refresh()
    } catch (error) {
      console.error('Error saving specialite:', error)
      alert('Erreur lors de la sauvegarde')
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{specialite ? 'Modifier la spécialité' : 'Créer une spécialité'}</DialogTitle>
          <DialogDescription>
            {specialite ? 'Modifiez les informations de la spécialité' : 'Remplissez les informations pour créer une nouvelle spécialité'}
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="nom">Nom *</Label>
            <Input
              id="nom"
              value={formData.nom}
              onChange={(e) => setFormData({ ...formData, nom: e.target.value })}
              required
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="description">Description</Label>
            <Textarea
              id="description"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="icone">Icône (emoji ou texte)</Label>
            <Input
              id="icone"
              value={formData.icone}
              onChange={(e) => setFormData({ ...formData, icone: e.target.value })}
              placeholder="🩺"
            />
          </div>
          <DialogFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Annuler
            </Button>
            <Button type="submit" disabled={loading}>
              {loading ? 'Enregistrement...' : specialite ? 'Modifier' : 'Créer'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}

