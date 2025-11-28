import { getNotifications } from '@/lib/services/notifications-service'
import { NotificationsTable } from '@/components/admin/NotificationsTable'

export default async function NotificationsPage({
  searchParams,
}: {
  searchParams: Promise<{ type?: string; isRead?: string; userId?: string }>
}) {
  const params = await searchParams
  const notifications = await getNotifications({
    type: params.type,
    isRead: params.isRead === 'true' ? true : params.isRead === 'false' ? false : undefined,
    userId: params.userId,
  })

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Notifications</h1>
        <p className="text-muted-foreground">
          Gérez toutes les notifications de la plateforme
        </p>
      </div>

      <NotificationsTable notifications={notifications} />
    </div>
  )
}

