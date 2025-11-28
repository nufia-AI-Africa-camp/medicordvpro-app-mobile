import { getSpecialites } from '@/lib/services/specialites-service'
import { SpecialiteFormButton } from '@/components/admin/SpecialiteFormButton'
import { SpecialitesTable } from '@/components/admin/SpecialitesTable'

export default async function SpecialitesPage() {
  const specialites = await getSpecialites()

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Spécialités</h1>
          <p className="text-muted-foreground">
            Gérez les spécialités médicales
          </p>
        </div>
        <SpecialiteFormButton />
      </div>

      <SpecialitesTable specialites={specialites} />
    </div>
  )
}

