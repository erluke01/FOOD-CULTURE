import { useState } from 'react'
import { StarInput } from './StarRating'
import { apiFetch } from '../utils/api'
import { useAuth } from '../context/AuthContext'
import { X } from 'lucide-react'

const FOOD_TAGS = ['Colazione','Brunch','Pranzo','Pranzo veloce','Merenda','Aperitivo','Cena','Dopocena']
const VISIT_CATS = ['Musei','Chiese','Monumenti','Spiagge','Piscine','Eventi','Borgo']

export function PlaceForm({ cityId, place, onSave, onClose }) {
  const { authHeader, user } = useAuth()
  const editing = !!place

  const [form, setForm] = useState({
    type: place?.type ?? 'food',
    name: place?.name ?? '',
    address: place?.address ?? '',
    category: place?.category ?? '',
    tag: place?.tag ?? '',
    lat: place?.lat ?? '',
    lng: place?.lng ?? '',
    date_visited: place?.date_visited ?? '',
    note: place?.note ?? '',
  })

  const myRating = place?.ratings?.find(r => r.user === user?.username)
  const [rating, setRating] = useState({
    quality: myRating?.quality ?? null,
    quantity: myRating?.quantity ?? null,
    price: myRating?.price ?? null,
    service: myRating?.service ?? null,
    cleanliness: myRating?.cleanliness ?? null,
    beauty: myRating?.beauty ?? null,
    cost: myRating?.cost ?? null,
  })

  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }))

  async function handleSubmit(e) {
    e.preventDefault()
    setSaving(true); setError(null)
    try {
      let saved
      const body = { ...form, city_id: cityId,
        lat: form.lat ? parseFloat(form.lat) : null,
        lng: form.lng ? parseFloat(form.lng) : null,
      }
      if (editing) {
        saved = await apiFetch(`/places/${place.id}`, { method: 'PUT', body: JSON.stringify(body) }, authHeader())
      } else {
        saved = await apiFetch('/places', { method: 'POST', body: JSON.stringify(body) }, authHeader())
      }
      // upsert rating
      const hasRating = Object.values(rating).some(v => v != null)
      if (hasRating) {
        saved = await apiFetch('/ratings', {
          method: 'POST',
          body: JSON.stringify({ place_id: saved.id, ...rating })
        }, authHeader())
      }
      onSave(saved)
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="fixed inset-0 z-50 bg-black/40 flex items-end sm:items-center justify-center p-0 sm:p-4">
      <div className="bg-white w-full sm:max-w-lg rounded-t-2xl sm:rounded-2xl max-h-[90vh] overflow-y-auto shadow-xl">
        <div className="sticky top-0 bg-white border-b border-paper-dark px-5 py-4 flex items-center justify-between">
          <h2 className="font-display font-semibold text-lg">
            {editing ? 'Modifica posto' : 'Aggiungi posto'}
          </h2>
          <button onClick={onClose} className="text-ink/40 hover:text-ink"><X size={20} /></button>
        </div>

        <form onSubmit={handleSubmit} className="p-5 space-y-4">
          {/* Type toggle */}
          <div className="flex rounded-xl overflow-hidden border border-ink/15">
            {[['food','🍽️ Mangiare & Bere'],['visit','🗺️ Da Visitare']].map(([v,l]) => (
              <button key={v} type="button"
                onClick={() => set('type', v)}
                className={`flex-1 py-2 text-sm font-medium transition-colors ${
                  form.type === v ? 'bg-terra text-white' : 'bg-white text-ink/60 hover:bg-paper'
                }`}>{l}</button>
            ))}
          </div>

          <div>
            <label className="text-xs font-medium text-ink/60 mb-1 block">Nome *</label>
            <input className="input" required value={form.name}
              onChange={e => set('name', e.target.value)} placeholder="es. Pizzeria da Mario" />
          </div>

          <div>
            <label className="text-xs font-medium text-ink/60 mb-1 block">Indirizzo</label>
            <input className="input" value={form.address}
              onChange={e => set('address', e.target.value)} placeholder="Via Roma 1" />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="text-xs font-medium text-ink/60 mb-1 block">Latitudine</label>
              <input className="input" type="number" step="any" value={form.lat}
                onChange={e => set('lat', e.target.value)} placeholder="45.4654" />
            </div>
            <div>
              <label className="text-xs font-medium text-ink/60 mb-1 block">Longitudine</label>
              <input className="input" type="number" step="any" value={form.lng}
                onChange={e => set('lng', e.target.value)} placeholder="9.1859" />
            </div>
          </div>

          {form.type === 'food' ? (
            <>
              <div>
                <label className="text-xs font-medium text-ink/60 mb-1 block">Categoria (libera)</label>
                <input className="input" value={form.category}
                  onChange={e => set('category', e.target.value)} placeholder="es. Pizzeria, Wine Bar…" />
              </div>
              <div>
                <label className="text-xs font-medium text-ink/60 mb-1 block">Tag momento</label>
                <select className="input" value={form.tag} onChange={e => set('tag', e.target.value)}>
                  <option value="">— Seleziona —</option>
                  {FOOD_TAGS.map(t => <option key={t}>{t}</option>)}
                </select>
              </div>
            </>
          ) : (
            <div>
              <label className="text-xs font-medium text-ink/60 mb-1 block">Categoria</label>
              <select className="input" value={form.category} onChange={e => set('category', e.target.value)}>
                <option value="">— Seleziona —</option>
                {VISIT_CATS.map(c => <option key={c}>{c}</option>)}
              </select>
            </div>
          )}

          <div>
            <label className="text-xs font-medium text-ink/60 mb-1 block">Data visita</label>
            <input className="input" type="date" value={form.date_visited}
              onChange={e => set('date_visited', e.target.value)} />
          </div>

          <div>
            <label className="text-xs font-medium text-ink/60 mb-1 block">Note</label>
            <textarea className="input resize-none" rows={3} value={form.note}
              onChange={e => set('note', e.target.value)} placeholder="Commenti, impressioni…" />
          </div>

          {/* My ratings */}
          <div className="bg-paper rounded-xl p-4">
            <h3 className="text-sm font-semibold mb-3">
              Il tuo voto {user?.username === 'luchino' ? '🧑' : '👩'}
            </h3>
            {form.type === 'food' ? (
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
          </div>

          {error && <p className="text-red-500 text-sm">{error}</p>}

          <div className="flex gap-2 pt-1">
            <button type="button" onClick={onClose} className="btn-ghost flex-1">Annulla</button>
            <button type="submit" disabled={saving} className="btn-primary flex-1">
              {saving ? 'Salvataggio…' : editing ? 'Salva modifiche' : 'Aggiungi posto'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
