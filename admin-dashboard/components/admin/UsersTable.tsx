'use client'

import { DataTable } from '@/components/admin/DataTable'
import { ColumnDef } from '@tanstack/react-table'
import { Utilisateur } from '@/lib/types/database.types'
import { UsersActions } from '@/components/admin/UsersActions'

interface UsersTableProps {
  users: Utilisateur[]
}

export function UsersTable({ users }: UsersTableProps) {
  const columns: ColumnDef<Utilisateur>[] = [
    {
      accessorKey: 'nom',
      header: 'Nom',
      cell: ({ row }) => `${row.original.prenom} ${row.original.nom}`,
    },
    {
      accessorKey: 'email',
      header: 'Email',
    },
    {
      accessorKey: 'telephone',
      header: 'Téléphone',
    },
    {
      accessorKey: 'role',
      header: 'Rôle',
      cell: ({ row }) => {
        const role = row.original.role
        const colors: Record<string, string> = {
          patient: 'bg-blue-100 text-blue-800',
          medecin: 'bg-green-100 text-green-800',
          admin: 'bg-purple-100 text-purple-800',
        }
        return (
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${colors[role] || ''}`}>
            {role}
          </span>
        )
      },
    },
    {
      accessorKey: 'created_at',
      header: 'Date de création',
      cell: ({ row }) => {
        const date = new Date(row.original.created_at)
        return date.toLocaleDateString('fr-FR')
      },
    },
    {
      id: 'actions',
      header: 'Actions',
      cell: ({ row }) => <UsersActions user={row.original} />,
    },
  ]

  return <DataTable columns={columns} data={users} searchKey="email" />
}

