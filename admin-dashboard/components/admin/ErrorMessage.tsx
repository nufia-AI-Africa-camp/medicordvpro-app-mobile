import { AlertCircle } from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'

interface ErrorMessageProps {
  message: string
  onRetry?: () => void
}

export function ErrorMessage({ message, onRetry }: ErrorMessageProps) {
  return (
    <Card className="border-destructive">
      <CardContent className="pt-6">
        <div className="flex items-center gap-2 text-destructive">
          <AlertCircle className="h-5 w-5" />
          <p>{message}</p>
        </div>
        {onRetry && (
          <button
            onClick={onRetry}
            className="mt-4 text-sm text-primary hover:underline"
          >
            Réessayer
          </button>
        )}
      </CardContent>
    </Card>
  )
}

