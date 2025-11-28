'use client'

import { DataTable } from '@/components/admin/DataTable'
import { ColumnDef } from '@tanstack/react-table'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'

interface Appointment {
  id: string
  patient_utilisateur_id: string
  medecin_utilisateur_id: string
  date_heure: string
  statut: string
  patient?: { nom: string; prenom: string }
  medecin?: { nom: string; prenom: string }
  centre?: { nom: string; ville: string }
}

interface AppointmentsTableProps {
  appointments: Appointment[]
}

export function AppointmentsTable({ appointments }: AppointmentsTableProps) {
  const columns: ColumnDef<Appointment>[] = [
    {
      accessorKey: 'patient',
      header: 'Patient',
      cell: ({ row }) => {
        const patient = row.original.patient
        return patient ? `${patient.prenom} ${patient.nom}` : '-'
      },
    },
    {
      accessorKey: 'medecin',
      header: 'Médecin',
      cell: ({ row }) => {
        const medecin = row.original.medecin
        return medecin ? `Dr. ${medecin.prenom} ${medecin.nom}` : '-'
      },
    },
    {
      accessorKey: 'date_heure',
      header: 'Date et heure',
      cell: ({ row }) => {
        const date = new Date(row.original.date_heure)
        return format(date, 'PPpp', { locale: fr })
      },
    },
    {
      accessorKey: 'statut',
      header: 'Statut',
      cell: ({ row }) => {
        const statut = row.original.statut
        const colors: Record<string, string> = {
          en_attente: 'bg-yellow-100 text-yellow-800',
          confirmé: 'bg-green-100 text-green-800',
          annulé: 'bg-red-100 text-red-800',
          terminé: 'bg-blue-100 text-blue-800',
          absent: 'bg-gray-100 text-gray-800',
        }
        return (
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${colors[statut] || ''}`}>
            {statut}
          </span>
        )
      },
    },
    {
      accessorKey: 'centre',
      header: 'Centre',
      cell: ({ row }) => {
        const centre = row.original.centre
        return centre ? `${centre.nom} - ${centre.ville}` : '-'
      },
    },
  ]

  return <DataTable columns={columns} data={appointments} />
}

