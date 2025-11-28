'use client'

import { DataTable } from '@/components/admin/DataTable'
import { ColumnDef } from '@tanstack/react-table'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'
import { NotificationsActions } from '@/components/admin/NotificationsActions'

interface Notification {
  id: string
  utilisateur_id: string
  type: string
  titre: string
  message: string
  is_read: boolean
  sent_at: string
  utilisateur?: { nom: string; prenom: string }
}

interface NotificationsTableProps {
  notifications: Notification[]
}

export function NotificationsTable({ notifications }: NotificationsTableProps) {
  const columns: ColumnDef<Notification>[] = [
    {
      accessorKey: 'utilisateur',
      header: 'Utilisateur',
      cell: ({ row }) => {
        const user = row.original.utilisateur
        return user ? `${user.prenom} ${user.nom}` : '-'
      },
    },
    {
      accessorKey: 'type',
      header: 'Type',
      cell: ({ row }) => {
        const type = row.original.type
        const colors: Record<string, string> = {
          confirmation: 'bg-green-100 text-green-800',
          rappel: 'bg-blue-100 text-blue-800',
          annulation: 'bg-red-100 text-red-800',
          modification: 'bg-yellow-100 text-yellow-800',
          message: 'bg-gray-100 text-gray-800',
        }
        return (
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${colors[type] || ''}`}>
            {type}
          </span>
        )
      },
    },
    {
      accessorKey: 'titre',
      header: 'Titre',
    },
    {
      accessorKey: 'message',
      header: 'Message',
      cell: ({ row }) => {
        const message = row.original.message
        return message && message.length > 50 ? `${message.substring(0, 50)}...` : message
      },
    },
    {
      accessorKey: 'is_read',
      header: 'Statut',
      cell: ({ row }) => {
        const isRead = row.original.is_read
        return (
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${isRead ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}`}>
            {isRead ? 'Lu' : 'Non lu'}
          </span>
        )
      },
    },
    {
      accessorKey: 'sent_at',
      header: 'Date d\'envoi',
      cell: ({ row }) => {
        const date = new Date(row.original.sent_at)
        return format(date, 'PPpp', { locale: fr })
      },
    },
    {
      id: 'actions',
      header: 'Actions',
      cell: ({ row }) => <NotificationsActions notification={row.original} />,
    },
  ]

  return <DataTable columns={columns} data={notifications} />
}

