'use client'

import { DataTable } from '@/components/admin/DataTable'
import { ColumnDef } from '@tanstack/react-table'
import { CentreMedical } from '@/lib/types/database.types'
import { CentresActions } from '@/components/admin/CentresActions'

interface CentresTableProps {
  centres: CentreMedical[]
}

export function CentresTable({ centres }: CentresTableProps) {
  const columns: ColumnDef<CentreMedical>[] = [
    {
      accessorKey: 'nom',
      header: 'Nom',
    },
    {
      accessorKey: 'adresse',
      header: 'Adresse',
    },
    {
      accessorKey: 'ville',
      header: 'Ville',
    },
    {
      accessorKey: 'code_postal',
      header: 'Code postal',
    },
    {
      accessorKey: 'telephone',
      header: 'Téléphone',
    },
    {
      accessorKey: 'email',
      header: 'Email',
    },
    {
      id: 'actions',
      header: 'Actions',
      cell: ({ row }) => <CentresActions centre={row.original} />,
    },
  ]

  return <DataTable columns={columns} data={centres} searchKey="nom" />
}

