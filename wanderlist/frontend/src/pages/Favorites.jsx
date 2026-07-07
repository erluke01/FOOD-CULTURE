import { useState, useEffect } from 'react'
import { Link, Navigate } from 'react-router-dom'
import { apiFetch } from '../utils/api'
import { useAuth } from '../context/AuthContext'
import { PlaceCard, PlaceCardSkeleton } from '../components/PlaceCard'
import { ChevronLeft, Heart } from 'lucide-react'

export default function Favorites() {
  const { user, authHeader } = useAuth()
  const [places, setPlaces] = useState([])
  const [loading, setLoading] = useState(true)

  function load() {
    apiFetch('/favorites', {}, authHeader()).then(setPlaces).finally(() => setLoading(false))
  }

  useEffect(() => { if (user) load() }, [user])

  if (!user) return <Navigate to="/login" replace />

  return (
    <div className="max-w-6xl mx-auto px-4 py-8">
      <Link to="/" className="inline-flex items-center gap-1 text-sm text-ink/50 hover:text-ink mb-5 transition-colors">
        <ChevronLeft size={14} /> Home
      </Link>
      <div className="flex items-center gap-2 mb-6">
        <Heart size={20} className="text-terra" fill="currentColor" />
        <h1 className="font-display text-2xl font-semibold">I tuoi preferiti</h1>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 3 }).map((_, i) => <PlaceCardSkeleton key={i} />)}
        </div>
      ) : places.length === 0 ? (
        <div className="text-center py-16">
          <Heart size={36} className="mx-auto text-ink/15 mb-3" />
          <p className="text-ink/40">Nessun preferito ancora. Esplora le città e salva i posti che ti interessano!</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {places.map(p => <PlaceCard key={p.id} place={p} onFavToggle={load} />)}
        </div>
      )}
    </div>
  )
}
