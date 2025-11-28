import { getAppointments } from '@/lib/services/appointments-service'
import { AppointmentsTable } from '@/components/admin/AppointmentsTable'

export default async function RendezVousPage({
  searchParams,
}: {
  searchParams: Promise<{ status?: string; dateFrom?: string; dateTo?: string }>
}) {
  const params = await searchParams
  const appointments = await getAppointments({
    status: params.status,
    dateFrom: params.dateFrom,
    dateTo: params.dateTo,
  })

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Rendez-vous</h1>
        <p className="text-muted-foreground">
          Gérez tous les rendez-vous de la plateforme
        </p>
      </div>

      <AppointmentsTable appointments={appointments} />
    </div>
  )
}

