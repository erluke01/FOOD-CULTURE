import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { apiFetch } from '../utils/api'
import { useAuth } from '../context/AuthContext'
import { MapPin, Plus, Trash2, Globe } from 'lucide-react'

export default function Home() {
  const [cities, setCities] = useState([])
  const [loading, setLoading] = useState(true)
  const [showAdd, setShowAdd] = useState(false)
  const [newCity, setNewCity] = useState({ name: '', country: '' })
  const [saving, setSaving] = useState(false)
  const { user, authHeader } = useAuth()
  const navigate = useNavigate()

  useEffect(() => {
    apiFetch('/cities').then(setCities).finally(() => setLoading(false))
  }, [])

  async function addCity(e) {
    e.preventDefault()
    setSaving(true)
    try {
      const c = await apiFetch('/cities', {
        method: 'POST', body: JSON.stringify(newCity)
      }, authHeader())
      setCities(prev => [...prev, c].sort((a, b) => a.name.localeCompare(b.name)))
      setNewCity({ name: '', country: '' })
      setShowAdd(false)
    } catch {}
    setSaving(false)
  }

  async function deleteCity(id) {
    if (!confirm('Eliminare questa città e tutti i suoi posti?')) return
    await apiFetch(`/cities/${id}`, { method: 'DELETE' }, authHeader())
    setCities(prev => prev.filter(c => c.id !== id))
  }

  return (
    <div className="min-h-screen">
      {/* Hero */}
      <div className="relative bg-ink overflow-hidden">
        <div className="absolute inset-0 opacity-10"
          style={{ backgroundImage: 'radial-gradient(circle at 30% 50%, #C45C26 0%, transparent 60%), radial-gradient(circle at 75% 20%, #5C7A5C 0%, transparent 50%)' }} />
        <div className="relative max-w-4xl mx-auto px-6 py-20 text-center">
          <div className="inline-flex items-center gap-2 text-terra text-sm font-medium tracking-widest uppercase mb-4">
            <Globe size={14} /> Il nostro diario di viaggio
          </div>
          <h1 className="font-display text-5xl sm:text-6xl text-white mb-4 leading-tight">
            Wanderlist
          </h1>
          <p className="text-white/50 text-lg max-w-md mx-auto">
            Posti mangiati, posti visti, posti da non dimenticare.
          </p>
        </div>
      </div>

      {/* Cities */}
      <div className="max-w-4xl mx-auto px-6 py-12">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h2 className="font-display text-2xl font-semibold">Scegli la città</h2>
            <p className="text-ink/50 text-sm mt-0.5">
              {cities.length === 0 ? 'Nessuna città ancora' : `${cities.length} citt${cities.length === 1 ? 'à' : 'à'} nel diario`}
            </p>
          </div>
          {user?.role === 'editor' && (
            <button onClick={() => setShowAdd(true)} className="btn-primary flex items-center gap-1.5">
              <Plus size={15} /> Nuova città
            </button>
          )}
        </div>

        {loading ? (
          <div className="text-center py-16 text-ink/30">Caricamento…</div>
        ) : cities.length === 0 ? (
          <div className="text-center py-16">
            <MapPin size={40} className="mx-auto text-ink/20 mb-3" />
            <p className="text-ink/40">Ancora nessuna città nel diario.</p>
            {user?.role === 'editor' && (
              <button onClick={() => setShowAdd(true)} className="btn-primary mt-4">Aggiungi la prima città</button>
            )}
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {cities.map(city => (
              <div key={city.id} className="card group relative overflow-hidden cursor-pointer"
                onClick={() => navigate(`/city/${city.id}`)}>
                <div className="h-1 bg-gradient-to-r from-terra to-terra-light" />
                <div className="p-5">
                  <div className="flex items-start justify-between">
                    <div>
                      <h3 className="font-display text-xl font-semibold group-hover:text-terra transition-colors">
                        {city.name}
                      </h3>
                      {city.country && (
                        <p className="text-sm text-ink/40 mt-0.5">{city.country}</p>
                      )}
                    </div>
                    <MapPin size={18} className="text-ink/20 group-hover:text-terra transition-colors mt-0.5" />
                  </div>
                  {user?.role === 'editor' && (
                    <button
                      onClick={e => { e.stopPropagation(); deleteCity(city.id) }}
                      className="absolute bottom-3 right-3 text-ink/20 hover:text-red-400 transition-colors opacity-0 group-hover:opacity-100">
                      <Trash2 size={14} />
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Add city modal */}
      {showAdd && (
        <div className="fixed inset-0 z-50 bg-black/40 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl p-6 w-full max-w-sm shadow-xl">
            <h3 className="font-display text-lg font-semibold mb-4">Nuova città</h3>
            <form onSubmit={addCity} className="space-y-3">
              <div>
                <label className="text-xs font-medium text-ink/60 mb-1 block">Nome città *</label>
                <input className="input" required value={newCity.name}
                  onChange={e => setNewCity(n => ({...n, name: e.target.value}))}
                  placeholder="es. Milano" />
              </div>
              <div>
                <label className="text-xs font-medium text-ink/60 mb-1 block">Paese</label>
                <input className="input" value={newCity.country}
                  onChange={e => setNewCity(n => ({...n, country: e.target.value}))}
                  placeholder="es. Italia" />
              </div>
              <div className="flex gap-2 pt-2">
                <button type="button" onClick={() => setShowAdd(false)} className="btn-ghost flex-1">Annulla</button>
                <button type="submit" disabled={saving} className="btn-primary flex-1">
                  {saving ? '…' : 'Aggiungi'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
