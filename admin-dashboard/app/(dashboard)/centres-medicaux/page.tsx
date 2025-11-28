import { getCentres } from '@/lib/services/centres-service'
import { CentreFormButton } from '@/components/admin/CentreFormButton'
import { CentresTable } from '@/components/admin/CentresTable'

export default async function CentresMedicauxPage() {
  const centres = await getCentres()

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Centres médicaux</h1>
          <p className="text-muted-foreground">
            Gérez les centres médicaux
          </p>
        </div>
        <CentreFormButton />
      </div>

      <CentresTable centres={centres} />
    </div>
  )
}

