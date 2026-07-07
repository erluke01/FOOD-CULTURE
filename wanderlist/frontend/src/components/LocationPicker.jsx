import { useState, useRef, useEffect } from 'react'
import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet'
import L from 'leaflet'
import { Search, Crosshair, MapPin } from 'lucide-react'

const pinIcon = L.divIcon({
  className: '',
  html: `<div class="custom-marker"><div class="custom-marker-inner">📍</div></div>`,
  iconSize: [36, 36],
  iconAnchor: [18, 36],
})

function ClickHandler({ onPick }) {
  useMapEvents({
    click(e) { onPick(e.latlng.lat, e.latlng.lng) },
  })
  return null
}

const FALLBACK_CENTER = [45.4654, 9.1859]

export function LocationPicker({ lat, lng, onChange, defaultCenter, cityName }) {
  const [query, setQuery] = useState('')
  const [searching, setSearching] = useState(false)
  const [searchError, setSearchError] = useState(null)
  const mapRef = useRef(null)

  const position = (lat && lng) ? [parseFloat(lat), parseFloat(lng)] : null

  // Nessun posto già mappato in questa città: centra la mappa sulla città stessa
  useEffect(() => {
    if (position || defaultCenter || !cityName) return
    let cancelled = false
    fetch(`https://nominatim.openstreetmap.org/search?format=json&limit=1&q=${encodeURIComponent(cityName)}`)
      .then(r => r.json())
      .then(results => {
        if (cancelled || !results.length || !mapRef.current) return
        mapRef.current.setView([parseFloat(results[0].lat), parseFloat(results[0].lon)], 13)
      })
      .catch(() => {})
    return () => { cancelled = true }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cityName])

  function pick(la, ln) {
    onChange(la, ln)
    mapRef.current?.flyTo([la, ln], Math.max(mapRef.current.getZoom(), 15), { duration: 0.6 })
  }

  async function handleSearch() {
    if (!query.trim()) return
    setSearching(true); setSearchError(null)
    try {
      const res = await fetch(`https://nominatim.openstreetmap.org/search?format=json&limit=1&q=${encodeURIComponent(query)}`)
      const results = await res.json()
      if (!results.length) { setSearchError('Nessun risultato'); return }
      pick(parseFloat(results[0].lat), parseFloat(results[0].lon))
    } catch {
      setSearchError('Ricerca non riuscita')
    } finally {
      setSearching(false)
    }
  }

  function useMyLocation() {
    if (!navigator.geolocation) return
    navigator.geolocation.getCurrentPosition(
      pos => pick(pos.coords.latitude, pos.coords.longitude),
      () => setSearchError('Posizione non disponibile'),
    )
  }

  return (
    <div>
      <label className="text-xs font-medium text-ink/60 mb-1 block">Posizione sulla mappa</label>

      <div className="flex gap-2 mb-2">
        <input
          className="input flex-1"
          value={query}
          onChange={e => setQuery(e.target.value)}
          onKeyDown={e => { if (e.key === 'Enter') { e.preventDefault(); handleSearch() } }}
          placeholder="Cerca un indirizzo…"
        />
        <button type="button" onClick={handleSearch} disabled={searching} className="btn-ghost px-3" title="Cerca">
          <Search size={15} />
        </button>
        <button type="button" onClick={useMyLocation} className="btn-ghost px-3" title="Usa la mia posizione">
          <Crosshair size={15} />
        </button>
      </div>
      {searchError && <p className="text-red-500 text-xs mb-2">{searchError}</p>}

      <div className="h-48 rounded-xl overflow-hidden border border-ink/15 relative z-0">
        <MapContainer
          center={position ?? defaultCenter ?? FALLBACK_CENTER}
          zoom={position ? 15 : 12}
          className="w-full h-full"
          scrollWheelZoom={true}
          ref={mapRef}
        >
          <TileLayer
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            attribution='&copy; OpenStreetMap'
          />
          <ClickHandler onPick={pick} />
          {position && <Marker position={position} icon={pinIcon} />}
        </MapContainer>
      </div>
      <p className="text-xs text-ink/40 mt-1.5 flex items-center gap-1">
        <MapPin size={11} /> {position ? `${position[0].toFixed(5)}, ${position[1].toFixed(5)}` : 'Tocca la mappa per posizionare il pin'}
      </p>
    </div>
  )
}
