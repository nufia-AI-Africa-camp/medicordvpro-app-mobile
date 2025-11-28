import { getDashboardStats } from '@/lib/services/stats-service'
import { StatsCard } from '@/components/admin/StatsCard'
import { Users, UserCheck, Calendar, CalendarCheck, CalendarX, TrendingUp } from 'lucide-react'
import { DashboardChart } from '@/components/admin/DashboardChart'

export default async function DashboardPage() {
  const stats = await getDashboardStats()

  const tauxConfirmation = stats.totalRdv > 0
    ? ((stats.rdvConfirmes / stats.totalRdv) * 100).toFixed(1)
    : '0'

  const tauxAnnulation = stats.totalRdv > 0
    ? ((stats.rdvAnnules / stats.totalRdv) * 100).toFixed(1)
    : '0'

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="text-muted-foreground">
          Vue d'ensemble de l'activité de la plateforme
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <StatsCard
          title="Total Utilisateurs"
          value={stats.totalUsers}
          description={`${stats.totalPatients} patients, ${stats.totalMedecins} médecins`}
          icon={Users}
        />
        <StatsCard
          title="Rendez-vous Aujourd'hui"
          value={stats.rdvToday}
          description={`${stats.rdvWeek} cette semaine`}
          icon={Calendar}
        />
        <StatsCard
          title="Taux de Confirmation"
          value={`${tauxConfirmation}%`}
          description={`${stats.rdvConfirmes} confirmés sur ${stats.totalRdv}`}
          icon={CalendarCheck}
        />
        <StatsCard
          title="Taux d'Annulation"
          value={`${tauxAnnulation}%`}
          description={`${stats.rdvAnnules} annulés`}
          icon={CalendarX}
        />
      </div>

      <div className="grid gap-4 md:grid-cols-2">
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

      <div className="grid gap-4 md:grid-cols-3">
        <StatsCard
          title="Rendez-vous cette semaine"
          value={stats.rdvWeek}
          icon={TrendingUp}
        />
        <StatsCard
          title="Rendez-vous ce mois"
          value={stats.rdvMonth}
          icon={Calendar}
        />
        <StatsCard
          title="Total Rendez-vous"
          value={stats.totalRdv}
          icon={UserCheck}
        />
      </div>
    </div>
  )
}

