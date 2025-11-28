'use client'

import { DataTable } from '@/components/admin/DataTable'
import { ColumnDef } from '@tanstack/react-table'
import { Specialite } from '@/lib/types/database.types'
import { SpecialitesActions } from '@/components/admin/SpecialitesActions'

interface SpecialitesTableProps {
  specialites: Specialite[]
}

export function SpecialitesTable({ specialites }: SpecialitesTableProps) {
  const columns: ColumnDef<Specialite>[] = [
    {
      accessorKey: 'nom',
      header: 'Nom',
    },
    {
      accessorKey: 'description',
      header: 'Description',
    },
    {
      accessorKey: 'icone',
      header: 'Icône',
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
      cell: ({ row }) => <SpecialitesActions specialite={row.original} />,
    },
  ]

  return <DataTable columns={columns} data={specialites} searchKey="nom" />
}

