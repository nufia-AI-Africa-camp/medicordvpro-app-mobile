'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select } from '@/components/ui/select'
import { Textarea } from '@/components/ui/textarea'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Utilisateur, Specialite, CentreMedical } from '@/lib/types/database.types'

interface UserFormProps {
  user?: Utilisateur | null
  open: boolean
  onOpenChange: (open: boolean) => void
  onSuccess: () => void
}

export function UserForm({ user, open, onOpenChange, onSuccess }: UserFormProps) {
  const router = useRouter()
  const supabase = createClient()
  const [loading, setLoading] = useState(false)
  const [specialites, setSpecialites] = useState<Specialite[]>([])
  const [centres, setCentres] = useState<CentreMedical[]>([])

  const [formData, setFormData] = useState({
    nom: '',
    prenom: '',
    email: '',
    telephone: '',
    role: 'patient' as 'patient' | 'medecin' | 'admin',
    date_naissance: '',
    adresse: '',
    ville: '',
    code_postal: '',
    specialite_id: '',
    centre_medical_id: '',
    numero_ordre: '',
    tarif_consultation: '',
    bio: '',
    annees_experience: '',
    langues_parlees: '',
    accepte_nouveaux_patients: true,
  })

  useEffect(() => {
    if (user) {
      setFormData({
        nom: user.nom || '',
        prenom: user.prenom || '',
        email: user.email || '',
        telephone: user.telephone || '',
        role: user.role,
        date_naissance: user.date_naissance || '',
        adresse: user.adresse || '',
        ville: user.ville || '',
        code_postal: user.code_postal || '',
        specialite_id: user.specialite_id || '',
        centre_medical_id: user.centre_medical_id || '',
        numero_ordre: user.numero_ordre || '',
        tarif_consultation: user.tarif_consultation?.toString() || '',
        bio: user.bio || '',
        annees_experience: user.annees_experience?.toString() || '',
        langues_parlees: user.langues_parlees?.join(', ') || '',
        accepte_nouveaux_patients: user.accepte_nouveaux_patients,
      })
    } else {
      setFormData({
        nom: '',
        prenom: '',
        email: '',
        telephone: '',
        role: 'patient',
        date_naissance: '',
        adresse: '',
        ville: '',
        code_postal: '',
        specialite_id: '',
        centre_medical_id: '',
        numero_ordre: '',
        tarif_consultation: '',
        bio: '',
        annees_experience: '',
        langues_parlees: '',
        accepte_nouveaux_patients: true,
      })
    }
  }, [user, open])

  useEffect(() => {
    async function loadData() {
      const [specsRes, centresRes] = await Promise.all([
        supabase.from('specialites').select('*'),
        supabase.from('centres_medicaux').select('*'),
      ])
      if (specsRes.data) setSpecialites(specsRes.data)
      if (centresRes.data) setCentres(centresRes.data)
    }
    if (open) loadData()
  }, [open, supabase])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      const payload: any = {
        nom: formData.nom,
        prenom: formData.prenom,
        email: formData.email,
        telephone: formData.telephone,
        role: formData.role,
      }

      if (formData.role === 'patient') {
        payload.date_naissance = formData.date_naissance || null
        payload.adresse = formData.adresse || null
        payload.ville = formData.ville || null
        payload.code_postal = formData.code_postal || null
      }

      if (formData.role === 'medecin') {
        payload.specialite_id = formData.specialite_id || null
        payload.centre_medical_id = formData.centre_medical_id || null
        payload.numero_ordre = formData.numero_ordre || null
        payload.tarif_consultation = formData.tarif_consultation ? parseFloat(formData.tarif_consultation) : null
        payload.bio = formData.bio || null
        payload.annees_experience = formData.annees_experience ? parseInt(formData.annees_experience) : null
        payload.langues_parlees = formData.langues_parlees ? formData.langues_parlees.split(',').map(l => l.trim()) : null
        payload.accepte_nouveaux_patients = formData.accepte_nouveaux_patients
      }

      if (user) {
        await supabase
          .from('utilisateurs')
          .update(payload)
          .eq('id', user.id)
      } else {
        await supabase
          .from('utilisateurs')
          .insert(payload)
      }

      onSuccess()
      onOpenChange(false)
      router.refresh()
    } catch (error) {
      console.error('Error saving user:', error)
      alert('Erreur lors de la sauvegarde')
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{user ? 'Modifier l\'utilisateur' : 'Créer un utilisateur'}</DialogTitle>
          <DialogDescription>
            {user ? 'Modifiez les informations de l\'utilisateur' : 'Remplissez les informations pour créer un nouvel utilisateur'}
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
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
              <Label htmlFor="prenom">Prénom *</Label>
              <Input
                id="prenom"
                value={formData.prenom}
                onChange={(e) => setFormData({ ...formData, prenom: e.target.value })}
                required
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="email">Email *</Label>
              <Input
                id="email"
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="telephone">Téléphone *</Label>
              <Input
                id="telephone"
                value={formData.telephone}
                onChange={(e) => setFormData({ ...formData, telephone: e.target.value })}
                required
              />
            </div>
          </div>
          <div className="space-y-2">
            <Label htmlFor="role">Rôle *</Label>
            <Select
              id="role"
              value={formData.role}
              onChange={(e) => setFormData({ ...formData, role: e.target.value as any })}
              required
            >
              <option value="patient">Patient</option>
              <option value="medecin">Médecin</option>
              <option value="admin">Admin</option>
            </Select>
          </div>

          {formData.role === 'patient' && (
            <>
              <div className="space-y-2">
                <Label htmlFor="date_naissance">Date de naissance</Label>
                <Input
                  id="date_naissance"
                  type="date"
                  value={formData.date_naissance}
                  onChange={(e) => setFormData({ ...formData, date_naissance: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="adresse">Adresse</Label>
                <Input
                  id="adresse"
                  value={formData.adresse}
                  onChange={(e) => setFormData({ ...formData, adresse: e.target.value })}
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="ville">Ville</Label>
                  <Input
                    id="ville"
                    value={formData.ville}
                    onChange={(e) => setFormData({ ...formData, ville: e.target.value })}
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
            </>
          )}

          {formData.role === 'medecin' && (
            <>
              <div className="space-y-2">
                <Label htmlFor="specialite_id">Spécialité</Label>
                <Select
                  id="specialite_id"
                  value={formData.specialite_id}
                  onChange={(e) => setFormData({ ...formData, specialite_id: e.target.value })}
                >
                  <option value="">Sélectionner une spécialité</option>
                  {specialites.map((spec) => (
                    <option key={spec.id} value={spec.id}>
                      {spec.nom}
                    </option>
                  ))}
                </Select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="centre_medical_id">Centre médical</Label>
                <Select
                  id="centre_medical_id"
                  value={formData.centre_medical_id}
                  onChange={(e) => setFormData({ ...formData, centre_medical_id: e.target.value })}
                >
                  <option value="">Sélectionner un centre</option>
                  {centres.map((centre) => (
                    <option key={centre.id} value={centre.id}>
                      {centre.nom}
                    </option>
                  ))}
                </Select>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="numero_ordre">Numéro d'ordre</Label>
                  <Input
                    id="numero_ordre"
                    value={formData.numero_ordre}
                    onChange={(e) => setFormData({ ...formData, numero_ordre: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="tarif_consultation">Tarif consultation (€)</Label>
                  <Input
                    id="tarif_consultation"
                    type="number"
                    step="0.01"
                    value={formData.tarif_consultation}
                    onChange={(e) => setFormData({ ...formData, tarif_consultation: e.target.value })}
                  />
                </div>
              </div>
              <div className="space-y-2">
                <Label htmlFor="bio">Bio</Label>
                <Textarea
                  id="bio"
                  value={formData.bio}
                  onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="annees_experience">Années d'expérience</Label>
                  <Input
                    id="annees_experience"
                    type="number"
                    value={formData.annees_experience}
                    onChange={(e) => setFormData({ ...formData, annees_experience: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="langues_parlees">Langues parlées (séparées par des virgules)</Label>
                  <Input
                    id="langues_parlees"
                    value={formData.langues_parlees}
                    onChange={(e) => setFormData({ ...formData, langues_parlees: e.target.value })}
                    placeholder="Français, Anglais, Espagnol"
                  />
                </div>
              </div>
              <div className="flex items-center gap-2 pt-2">
                <input
                  id="accepte_nouveaux_patients"
                  type="checkbox"
                  checked={formData.accepte_nouveaux_patients}
                  onChange={(e) => setFormData({ ...formData, accepte_nouveaux_patients: e.target.checked })}
                  className="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                />
                <Label htmlFor="accepte_nouveaux_patients" className="!mb-0 cursor-pointer">
                  Accepte de nouveaux patients
                </Label>
              </div>
            </>
          )}

          <DialogFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Annuler
            </Button>
            <Button type="submit" disabled={loading}>
              {loading ? 'Enregistrement...' : user ? 'Modifier' : 'Créer'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}

