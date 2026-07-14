import { Link } from 'react-router-dom'
import { Heart, MapPin, Calendar, UtensilsCrossed, Landmark } from 'lucide-react'
import { StarDisplay } from './StarRating'
import { useAuth } from '../context/AuthContext'
import { apiFetch } from '../utils/api'
import { useState } from 'react'

export function PlaceCardSkeleton() {
  return (
    <div className="card overflow-hidden">
      <div className="h-1.5 skeleton rounded-none" />
      <div className="p-4 space-y-2">
        <div className="skeleton h-4 w-1/3" />
        <div className="skeleton h-5 w-2/3" />
        <div className="skeleton h-3 w-1/2" />
      </div>
    </div>
  )
}

export function PlaceCard({ place, onFavToggle }) {
  const { user, authHeader } = useAuth()
  const [fav, setFav] = useState(place.is_favorite)

  async function toggleFav(e) {
    e.preventDefault(); e.stopPropagation()
    if (!user) return
    try {
      if (fav) {
        await apiFetch(`/favorites/${place.id}`, { method: 'DELETE' }, authHeader())
      } else {
        await apiFetch(`/favorites/${place.id}`, { method: 'POST' }, authHeader())
      }
      setFav(!fav)
      onFavToggle?.()
    } catch {}
  }

  const lRating = place.ratings?.find(r => r.user === 'luchino')
  const aRating = place.ratings?.find(r => r.user === 'alix')

  return (
    <Link to={`/places/${place.id}`} className="card card-interactive block overflow-hidden group">
      <div className={`h-1.5 ${place.type === 'food' ? 'bg-terra' : 'bg-sage'}`} />
      <div className="p-4">
        <div className="flex items-start justify-between gap-2">
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1">
              {place.type === 'food'
                ? <UtensilsCrossed size={13} className="text-terra flex-shrink-0" />
                : <Landmark size={13} className="text-sage flex-shrink-0" />
              }
              {place.category && (
                <span className="tag-pill">{place.category}</span>
              )}
              {place.tags?.map(t => (
                <span key={t} className="tag-pill bg-sky/10 text-sky">{t}</span>
              ))}
            </div>
            <h3 className="font-display font-semibold text-base leading-tight truncate group-hover:text-terra transition-colors">
              {place.name}
            </h3>
            {place.address && (
              <p className="text-xs text-ink/50 flex items-center gap-1 mt-0.5 truncate">
                <MapPin size={10} /> {place.address}
              </p>
            )}
          </div>
          <div className="flex flex-col items-end gap-1 flex-shrink-0">
            {user && (
              <button onClick={toggleFav} className="text-terra/40 hover:text-terra transition-colors">
                <Heart size={16} fill={fav ? 'currentColor' : 'none'} />
              </button>
            )}
            {place.avg_score != null && (
              <div className="text-right">
                <div className="font-display text-lg font-bold text-terra leading-none">{place.avg_score.toFixed(1)}</div>
                <div className="text-xs text-ink/40">media</div>
              </div>
            )}
          </div>
        </div>

        {(lRating || aRating) && (
          <div className="mt-3 pt-3 border-t border-paper-dark flex gap-3 text-xs">
            {lRating?.avg != null && (
              <div className="flex items-center gap-1 text-sky">
                <span>🧑</span>
                <StarDisplay score={lRating.avg} type={place.type} />
              </div>
            )}
            {aRating?.avg != null && (
              <div className="flex items-center gap-1 text-terra-light">
                <span>👩</span>
                <StarDisplay score={aRating.avg} type={place.type} />
              </div>
            )}
          </div>
        )}

        {place.date_visited && (
          <div className="mt-2 flex items-center gap-1 text-xs text-ink/40">
            <Calendar size={10} /> {place.date_visited}
          </div>
        )}
      </div>
    </Link>
  )
}
