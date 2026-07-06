import { useState, useEffect, useCallback } from 'react'
import { useParams, Link } from 'react-router-dom'
import { apiFetch } from '../utils/api'
import { useAuth } from '../context/AuthContext'
import { PlaceCard } from '../components/PlaceCard'
import { PlacesMap } from '../components/PlacesMap'
import { PlaceForm } from '../components/PlaceForm'
import { Plus, Map, LayoutGrid, ChevronLeft, SlidersHorizontal, X } from 'lucide-react'

export default function CityPage() {
  const { cityId } = useParams()
  const { user, authHeader } = useAuth()
  const [city, setCity] = useState(null)
  const [places, setPlaces] = useState([])
  const [categories, setCategories] = useState([])
  const [loading, setLoading] = useState(true)
  const [view, setView] = useState('grid') // 'grid' | 'map'
  const [showForm, setShowForm] = useState(false)
  const [filters, setFilters] = useState({ type: '', category: '', tag: '' })
  const [showFilters, setShowFilters] = useState(false)

  const FOOD_TAGS = ['Colazione','Brunch','Pranzo','Pranzo veloce','Merenda','Aperitivo','Cena','Dopocena']

  const load = useCallback(() => {
    const q = new URLSearchParams({ city_id: cityId })
    if (filters.type) q.set('type', filters.type)
    if (filters.category) q.set('category', filters.category)
    if (filters.tag) q.set('tag', filters.tag)

    Promise.all([
      apiFetch(`/cities`),
      apiFetch(`/places?${q}`, {}, authHeader()),  // auth → is_favorite corretto
      apiFetch(`/categories?city_id=${cityId}`),
    ]).then(([cities, ps, cats]) => {
      setCity(cities.find(c => c.id === parseInt(cityId)))
      setPlaces(ps)
      setCategories(cats)
    }).finally(() => setLoading(false))
  }, [cityId, filters, authHeader])

  useEffect(() => { load() }, [load])

  const activeFilters = Object.values(filters).filter(Boolean).length

  return (
    <div className="min-h-screen">
      {/* Header */}
      <div className="bg-white border-b border-paper-dark">
        <div className="max-w-6xl mx-auto px-4 py-4">
          <Link to="/" className="inline-flex items-center gap-1 text-sm text-ink/50 hover:text-ink mb-3 transition-colors">
            <ChevronLeft size={14} /> Tutte le città
          </Link>
          <div className="flex items-center justify-between flex-wrap gap-3">
            <div>
              <h1 className="font-display text-3xl font-semibold">{city?.name ?? '…'}</h1>
              {city?.country && <p className="text-ink/40 text-sm">{city.country}</p>}
            </div>
            <div className="flex items-center gap-2">
              {/* View toggle */}
              <div className="flex rounded-xl overflow-hidden border border-ink/15">
                <button onClick={() => setView('grid')}
                  className={`px-3 py-2 text-sm flex items-center gap-1.5 transition-colors ${
                    view === 'grid' ? 'bg-ink text-white' : 'bg-white text-ink/60 hover:bg-paper'}`}>
                  <LayoutGrid size={14} /> Lista
                </button>
                <button onClick={() => setView('map')}
                  className={`px-3 py-2 text-sm flex items-center gap-1.5 transition-colors ${
                    view === 'map' ? 'bg-ink text-white' : 'bg-white text-ink/60 hover:bg-paper'}`}>
                  <Map size={14} /> Mappa
                </button>
              </div>
              <button onClick={() => setShowFilters(!showFilters)}
                className={`btn-ghost flex items-center gap-1.5 relative ${activeFilters ? 'border-terra text-terra' : ''}`}>
                <SlidersHorizontal size={14} /> Filtri
                {activeFilters > 0 && (
                  <span className="absolute -top-1 -right-1 w-4 h-4 bg-terra text-white text-xs rounded-full flex items-center justify-center">
                    {activeFilters}
                  </span>
                )}
              </button>
              {user?.role === 'editor' && (
                <button onClick={() => setShowForm(true)} className="btn-primary flex items-center gap-1.5">
                  <Plus size={15} /> Aggiungi
                </button>
              )}
            </div>
          </div>

          {/* Filters panel */}
          {showFilters && (
            <div className="mt-4 p-4 bg-paper rounded-xl flex flex-wrap gap-3 items-end">
              <div>
                <label className="text-xs font-medium text-ink/60 mb-1 block">Tipo</label>
                <select className="input py-1.5 text-sm w-auto"
                  value={filters.type} onChange={e => setFilters(f => ({...f, type: e.target.value}))}>
                  <option value="">Tutti</option>
                  <option value="food">🍽️ Mangiare & Bere</option>
                  <option value="visit">🗺️ Da Visitare</option>
                </select>
              </div>
              <div>
                <label className="text-xs font-medium text-ink/60 mb-1 block">Categoria</label>
                <select className="input py-1.5 text-sm w-auto"
                  value={filters.category} onChange={e => setFilters(f => ({...f, category: e.target.value}))}>
                  <option value="">Tutte</option>
                  {categories.map(c => <option key={c}>{c}</option>)}
                </select>
              </div>
              <div>
                <label className="text-xs font-medium text-ink/60 mb-1 block">Tag momento</label>
                <select className="input py-1.5 text-sm w-auto"
                  value={filters.tag} onChange={e => setFilters(f => ({...f, tag: e.target.value}))}>
                  <option value="">Tutti</option>
                  {FOOD_TAGS.map(t => <option key={t}>{t}</option>)}
                </select>
              </div>
              {activeFilters > 0 && (
                <button onClick={() => setFilters({ type: '', category: '', tag: '' })}
                  className="flex items-center gap-1 text-sm text-terra hover:text-terra-dark">
                  <X size={13} /> Reset filtri
                </button>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Content */}
      {loading ? (
        <div className="text-center py-16 text-ink/30">Caricamento…</div>
      ) : view === 'map' ? (
        <div className="h-[calc(100vh-160px)]">
          <PlacesMap places={places} />
        </div>
      ) : (
        <div className="max-w-6xl mx-auto px-4 py-8">
          {places.length === 0 ? (
            <div className="text-center py-16">
              <p className="text-ink/40">Nessun posto trovato.</p>
              {user?.role === 'editor' && !activeFilters && (
                <button onClick={() => setShowForm(true)} className="btn-primary mt-4">
                  Aggiungi il primo posto
                </button>
              )}
            </div>
          ) : (
            <>
              <p className="text-sm text-ink/40 mb-5">{places.length} posto{places.length !== 1 ? 'i' : ''}</p>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {places.map(p => (
                  <PlaceCard key={p.id} place={p} onFavToggle={load} />
                ))}
              </div>
            </>
          )}
        </div>
      )}

      {showForm && (
        <PlaceForm
          cityId={parseInt(cityId)}
          onSave={() => { setShowForm(false); load() }}
          onClose={() => setShowForm(false)}
        />
      )}
    </div>
  )
}
