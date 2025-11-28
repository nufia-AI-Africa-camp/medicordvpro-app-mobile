import { getUsers } from '@/lib/services/users-service'
import { UserFormButton } from '@/components/admin/UserFormButton'
import { UsersTable } from '@/components/admin/UsersTable'

export default async function UtilisateursPage({
  searchParams,
}: {
  searchParams: Promise<{ role?: string; search?: string }>
}) {
  const params = await searchParams
  const users = await getUsers({
    role: params.role,
    search: params.search,
  })

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Utilisateurs</h1>
          <p className="text-muted-foreground">
            Gérez tous les utilisateurs de la plateforme
          </p>
        </div>
        <UserFormButton />
      </div>

      <UsersTable users={users} />
    </div>
  )
}

