import { useState, useEffect } from 'react'
import { useParams, useNavigate, Link } from 'react-router-dom'
import { apiFetch } from '../utils/api'
import { useAuth } from '../context/AuthContext'
import { PlacesMap } from '../components/PlacesMap'
import { PlaceForm } from '../components/PlaceForm'
import { StarDisplay, StarInput } from '../components/StarRating'
import { ChevronLeft, Navigation, Edit2, Trash2, Heart, Calendar, MapPin } from 'lucide-react'

function RatingBlock({ place, user, authHeader, onUpdate }) {
  const myR = place.ratings?.find(r => r.user === user?.username) ?? {}
  const [rating, setRating] = useState({
    quality: myR.quality ?? null,
    quantity: myR.quantity ?? null,
    price: myR.price ?? null,
    service: myR.service ?? null,
    cleanliness: myR.cleanliness ?? null,
    beauty: myR.beauty ?? null,
    cost: myR.cost ?? null,
  })
  const [saving, setSaving] = useState(false)
  const [saved, setSaved] = useState(false)

  async function save() {
    setSaving(true)
    try {
      const updated = await apiFetch('/ratings', {
        method: 'POST',
        body: JSON.stringify({ place_id: place.id, ...rating })
      }, authHeader())
      onUpdate(updated)
      setSaved(true); setTimeout(() => setSaved(false), 2000)
    } catch {} finally { setSaving(false) }
  }

  if (!user || user.role !== 'editor') return null

  const label = user.username === 'luchino' ? '🧑 Il tuo voto (Luchino)' : '👩 Il tuo voto (Alix)'

  return (
    <div className="card p-5">
      <h3 className="font-semibold text-sm mb-4">{label}</h3>
      {place.type === 'food' ? (
        <div className="grid grid-cols-2 gap-3">
          <StarInput label="Qualità" value={rating.quality} onChange={v => setRating(r => ({...r, quality: v}))} />
          <StarInput label="Quantità" value={rating.quantity} onChange={v => setRating(r => ({...r, quantity: v}))} />
          <StarInput label="Prezzo" value={rating.price} onChange={v => setRating(r => ({...r, price: v}))} />
          <StarInput label="Servizio" value={rating.service} onChange={v => setRating(r => ({...r, service: v}))} />
          <StarInput label="Pulizia" value={rating.cleanliness} onChange={v => setRating(r => ({...r, cleanliness: v}))} />
        </div>
      ) : (
        <div className="grid grid-cols-2 gap-3">
          <StarInput label="Bellezza" value={rating.beauty} onChange={v => setRating(r => ({...r, beauty: v}))} />
          <StarInput label="Costo" value={rating.cost} onChange={v => setRating(r => ({...r, cost: v}))} />
        </div>
      )}
      <button onClick={save} disabled={saving} className="btn-primary mt-4 w-full">
        {saved ? '✓ Salvato' : saving ? 'Salvataggio…' : 'Salva voto'}
      </button>
    </div>
  )
}

export default function PlaceDetail() {
  const { placeId } = useParams()
  const navigate = useNavigate()
  const { user, authHeader } = useAuth()
  const [place, setPlace] = useState(null)
  const [loading, setLoading] = useState(true)
  const [editing, setEditing] = useState(false)
  const [fav, setFav] = useState(false)

  useEffect(() => {
    apiFetch(`/places/${placeId}`, {}, authHeader())
      .then(p => { setPlace(p); setFav(p.is_favorite) })
      .finally(() => setLoading(false))
  }, [placeId])

  async function handleDelete() {
    if (!confirm('Eliminare questo posto?')) return
    await apiFetch(`/places/${placeId}`, { method: 'DELETE' }, authHeader())
    navigate(-1)
  }

  async function toggleFav() {
    if (!user) return
    if (fav) {
      await apiFetch(`/favorites/${placeId}`, { method: 'DELETE' }, authHeader())
    } else {
      await apiFetch(`/favorites/${placeId}`, { method: 'POST' }, authHeader())
    }
    setFav(!fav)
  }

  if (loading) return <div className="text-center py-20 text-ink/30">Caricamento…</div>
  if (!place) return <div className="text-center py-20">Posto non trovato</div>

  const lRating = place.ratings?.find(r => r.user === 'luchino')
  const aRating = place.ratings?.find(r => r.user === 'alix')

  return (
    <div className="max-w-3xl mx-auto px-4 py-8">
      <Link to={`/city/${place.city_id}`}
        className="inline-flex items-center gap-1 text-sm text-ink/50 hover:text-ink mb-5 transition-colors">
        <ChevronLeft size={14} /> Torna alla città
      </Link>

      {/* Main card */}
      <div className="card overflow-hidden mb-5">
        <div className={`h-2 ${place.type === 'food' ? 'bg-gradient-to-r from-terra to-terra-light' : 'bg-gradient-to-r from-sage to-sage-light'}`} />
        <div className="p-6">
          <div className="flex items-start justify-between gap-4">
            <div className="flex-1">
              <div className="flex flex-wrap gap-2 mb-2">
                {place.category && <span className="tag-pill">{place.category}</span>}
                {place.tag && <span className="tag-pill bg-sky/10 text-sky">{place.tag}</span>}
              </div>
              <h1 className="font-display text-3xl font-semibold leading-tight">{place.name}</h1>
              {place.address && (
                <p className="text-ink/50 flex items-center gap-1.5 mt-1.5 text-sm">
                  <MapPin size={13} /> {place.address}
                </p>
              )}
              {place.date_visited && (
                <p className="text-ink/40 flex items-center gap-1.5 mt-1 text-xs">
                  <Calendar size={11} /> {place.date_visited}
                </p>
              )}
            </div>
            <div className="flex flex-col items-end gap-2 flex-shrink-0">
              {place.avg_score != null && (
                <div className="text-right">
                  <div className="font-display text-4xl font-bold text-terra">{place.avg_score.toFixed(1)}</div>
                  <div className="text-xs text-ink/40">su 5</div>
                </div>
              )}
              <div className="flex gap-1.5 mt-1">
                {user && (
                  <button onClick={toggleFav} title="Preferiti"
                    className={`p-2 rounded-xl border transition-colors ${fav ? 'bg-terra/10 border-terra text-terra' : 'border-ink/15 text-ink/40 hover:text-terra'}`}>
                    <Heart size={16} fill={fav ? 'currentColor' : 'none'} />
                  </button>
                )}
                {place.lat && place.lng && (
                  <a href={`https://www.google.com/maps/dir/?api=1&destination=${place.lat},${place.lng}`}
                    target="_blank" rel="noreferrer"
                    className="p-2 rounded-xl border border-ink/15 text-ink/60 hover:bg-paper transition-colors flex items-center gap-1 text-xs">
                    <Navigation size={14} /> Indicazioni
                  </a>
                )}
                {user?.role === 'editor' && (
                  <>
                    <button onClick={() => setEditing(true)}
                      className="p-2 rounded-xl border border-ink/15 text-ink/60 hover:bg-paper transition-colors">
                      <Edit2 size={14} />
                    </button>
                    <button onClick={handleDelete}
                      className="p-2 rounded-xl border border-ink/15 text-red-400 hover:bg-red-50 transition-colors">
                      <Trash2 size={14} />
                    </button>
                  </>
                )}
              </div>
            </div>
          </div>

          {place.note && (
            <div className="mt-5 pt-5 border-t border-paper-dark">
              <p className="text-ink/70 text-sm leading-relaxed italic">"{place.note}"</p>
            </div>
          )}
        </div>
      </div>

      {/* Ratings */}
      <div className="grid sm:grid-cols-2 gap-4 mb-5">
        {[{ r: lRating, label: '🧑 Luchino' }, { r: aRating, label: '👩 Alix' }].map(({ r, label }) => r && (
          <div key={label} className="card p-5">
            <h3 className="font-semibold text-sm mb-3">{label}</h3>
            {place.type === 'food' ? (
              <div className="space-y-2 text-sm">
                {[['Qualità', r.quality],['Quantità', r.quantity],['Prezzo', r.price],['Servizio', r.service],['Pulizia', r.cleanliness]].map(([k, v]) => (
                  <div key={k} className="flex justify-between items-center">
                    <span className="text-ink/60">{k}</span>
                    <StarDisplay score={v} />
                  </div>
                ))}
                <div className="pt-2 border-t border-paper-dark flex justify-between items-center font-semibold">
                  <span>Media</span>
                  <StarDisplay score={r.avg} size="md" />
                </div>
              </div>
            ) : (
              <div className="space-y-2 text-sm">
                {[['Bellezza', r.beauty],['Costo', r.cost]].map(([k, v]) => (
                  <div key={k} className="flex justify-between items-center">
                    <span className="text-ink/60">{k}</span>
                    <StarDisplay score={v} />
                  </div>
                ))}
                <div className="pt-2 border-t border-paper-dark flex justify-between items-center font-semibold">
                  <span>Media</span>
                  <StarDisplay score={r.avg} size="md" />
                </div>
              </div>
            )}
          </div>
        ))}
      </div>

      <RatingBlock place={place} user={user} authHeader={authHeader} onUpdate={setPlace} />

      {/* Map */}
      {place.lat && place.lng && (
        <div className="mt-5 h-64 rounded-2xl overflow-hidden border border-paper-dark">
          <PlacesMap places={[place]} center={[place.lat, place.lng]} zoom={15} />
        </div>
      )}

      {editing && (
        <PlaceForm
          cityId={place.city_id}
          place={place}
          onSave={updated => { setPlace(updated); setEditing(false) }}
          onClose={() => setEditing(false)}
        />
      )}
    </div>
  )
}
