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
import { CentreMedical } from '@/lib/types/database.types'

interface CentreFormProps {
  centre?: CentreMedical | null
  open: boolean
  onOpenChange: (open: boolean) => void
  onSuccess: () => void
}

export function CentreForm({ centre, open, onOpenChange, onSuccess }: CentreFormProps) {
  const router = useRouter()
  const supabase = createClient()
  const [loading, setLoading] = useState(false)

  const [formData, setFormData] = useState({
    nom: '',
    adresse: '',
    ville: '',
    code_postal: '',
    telephone: '',
    email: '',
    latitude: '',
    longitude: '',
    description: '',
  })

  useEffect(() => {
    if (centre) {
      setFormData({
        nom: centre.nom || '',
        adresse: centre.adresse || '',
        ville: centre.ville || '',
        code_postal: centre.code_postal || '',
        telephone: centre.telephone || '',
        email: centre.email || '',
        latitude: centre.latitude?.toString() || '',
        longitude: centre.longitude?.toString() || '',
        description: centre.description || '',
      })
    } else {
      setFormData({
        nom: '',
        adresse: '',
        ville: '',
        code_postal: '',
        telephone: '',
        email: '',
        latitude: '',
        longitude: '',
        description: '',
      })
    }
  }, [centre, open])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      const payload: any = {
        nom: formData.nom,
        adresse: formData.adresse,
        ville: formData.ville,
        code_postal: formData.code_postal || null,
        telephone: formData.telephone || null,
        email: formData.email || null,
        latitude: formData.latitude ? parseFloat(formData.latitude) : null,
        longitude: formData.longitude ? parseFloat(formData.longitude) : null,
        description: formData.description || null,
      }

      if (centre) {
        await supabase
          .from('centres_medicaux')
          .update(payload)
          .eq('id', centre.id)
      } else {
        await supabase
          .from('centres_medicaux')
          .insert(payload)
      }

      onSuccess()
      onOpenChange(false)
      router.refresh()
    } catch (error) {
      console.error('Error saving centre:', error)
      alert('Erreur lors de la sauvegarde')
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{centre ? 'Modifier le centre' : 'Créer un centre'}</DialogTitle>
          <DialogDescription>
            {centre ? 'Modifiez les informations du centre médical' : 'Remplissez les informations pour créer un nouveau centre médical'}
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
            <Label htmlFor="adresse">Adresse *</Label>
            <Input
              id="adresse"
              value={formData.adresse}
              onChange={(e) => setFormData({ ...formData, adresse: e.target.value })}
              required
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="ville">Ville *</Label>
              <Input
                id="ville"
                value={formData.ville}
                onChange={(e) => setFormData({ ...formData, ville: e.target.value })}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="code_postal">Code postal</Label>
              <Input
                id="code_postal"
                value={formData.code_postal}
                onChange={(e) => setFormData({ ...formData, code_postal: e.target.value })}
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="telephone">Téléphone</Label>
              <Input
                id="telephone"
                value={formData.telephone}
                onChange={(e) => setFormData({ ...formData, telephone: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="latitude">Latitude</Label>
              <Input
                id="latitude"
                type="number"
                step="any"
                value={formData.latitude}
                onChange={(e) => setFormData({ ...formData, latitude: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="longitude">Longitude</Label>
              <Input
                id="longitude"
                type="number"
                step="any"
                value={formData.longitude}
                onChange={(e) => setFormData({ ...formData, longitude: e.target.value })}
              />
            </div>
          </div>
          <div className="space-y-2">
            <Label htmlFor="description">Description</Label>
            <Textarea
              id="description"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            />
          </div>
          <DialogFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Annuler
            </Button>
            <Button type="submit" disabled={loading}>
              {loading ? 'Enregistrement...' : centre ? 'Modifier' : 'Créer'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}

