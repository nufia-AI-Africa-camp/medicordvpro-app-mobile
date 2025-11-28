import { getDashboardStats } from '@/lib/services/stats-service'
import { DashboardChart } from '@/components/admin/DashboardChart'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export default async function StatistiquesPage() {
  const stats = await getDashboardStats()

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Statistiques Avancées</h1>
        <p className="text-muted-foreground">
          Rapports détaillés et analyses de la plateforme
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Répartition des utilisateurs</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span>Patients</span>
                <span className="font-bold">{stats.totalPatients}</span>
              </div>
              <div className="flex justify-between">
                <span>Médecins</span>
                <span className="font-bold">{stats.totalMedecins}</span>
              </div>
              <div className="flex justify-between">
                <span>Total</span>
                <span className="font-bold">{stats.totalUsers}</span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Statistiques des rendez-vous</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span>Total</span>
                <span className="font-bold">{stats.totalRdv}</span>
              </div>
              <div className="flex justify-between">
                <span>Confirmés</span>
                <span className="font-bold text-green-600">{stats.rdvConfirmes}</span>
              </div>
              <div className="flex justify-between">
                <span>Annulés</span>
                <span className="font-bold text-red-600">{stats.rdvAnnules}</span>
              </div>
              <div className="flex justify-between">
                <span>Taux de confirmation</span>
                <span className="font-bold">
                  {stats.totalRdv > 0
                    ? ((stats.rdvConfirmes / stats.totalRdv) * 100).toFixed(1)
                    : 0}%
                </span>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <DashboardChart
        title="Évolution des rendez-vous (7 derniers jours)"
        data={stats.evolutionData}
      />

      <DashboardChart
        title="Répartition par spécialité"
        data={stats.repartitionSpecialites}
        type="pie"
      />
    </div>
  )
}

