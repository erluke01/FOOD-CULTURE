import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet'
import L from 'leaflet'
import { Link } from 'react-router-dom'
import { StarDisplay } from './StarRating'
import { Navigation } from 'lucide-react'

function makeIcon(type) {
  return L.divIcon({
    className: '',
    html: `<div class="custom-marker ${type === 'visit' ? 'visit' : ''}">
             <div class="custom-marker-inner">${type === 'food' ? '🍽' : '🗺'}</div>
           </div>`,
    iconSize: [36, 36],
    iconAnchor: [18, 36],
    popupAnchor: [0, -38],
  })
}

function FitBounds({ places }) {
  const map = useMap()
  if (places.length > 0) {
    const coords = places.filter(p => p.lat && p.lng).map(p => [p.lat, p.lng])
    if (coords.length > 0) {
      try { map.fitBounds(coords, { padding: [40, 40], maxZoom: 14 }) } catch {}
    }
  }
  return null
}

export function PlacesMap({ places, center = [45.4654, 9.1859], zoom = 12 }) {
  const withCoords = places.filter(p => p.lat && p.lng)

  return (
    <MapContainer center={center} zoom={zoom}
      className="w-full h-full rounded-2xl z-0"
      scrollWheelZoom={true}>
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
      />
      <FitBounds places={withCoords} />
      {withCoords.map(place => (
        <Marker key={place.id} position={[place.lat, place.lng]} icon={makeIcon(place.type)}>
          <Popup maxWidth={260} className="wanderlist-popup">
            <div className="font-sans p-1">
              <div className="font-semibold text-sm text-ink mb-0.5">{place.name}</div>
              <div className="flex flex-wrap gap-1 mb-1">
                {place.category && (
                  <span className="inline-block text-xs bg-paper-dark px-2 py-0.5 rounded-full">{place.category}</span>
                )}
                {place.tag && (
                  <span className="inline-block text-xs bg-sky/10 text-sky px-2 py-0.5 rounded-full">{place.tag}</span>
                )}
              </div>
              {place.avg_score != null && (
                <div className="mb-1"><StarDisplay score={place.avg_score} /></div>
              )}
              {place.address && (
                <p className="text-xs text-ink/50 mb-1.5">{place.address}</p>
              )}
              {(() => {
                const lRating = place.ratings?.find(r => r.user === 'luchino')
                const aRating = place.ratings?.find(r => r.user === 'alix')
                if (!lRating && !aRating) return null
                return (
                  <div className="flex gap-3 text-xs mb-1.5 pb-1.5 border-b border-paper-dark">
                    {lRating?.avg != null && (
                      <div className="flex items-center gap-1 text-sky">🧑 <StarDisplay score={lRating.avg} /></div>
                    )}
                    {aRating?.avg != null && (
                      <div className="flex items-center gap-1 text-terra-light">👩 <StarDisplay score={aRating.avg} /></div>
                    )}
                  </div>
                )
              })()}
              {place.note && (
                <p className="text-xs text-ink/60 italic mb-2 line-clamp-2">"{place.note}"</p>
              )}
              <div className="flex gap-2">
                <Link to={`/places/${place.id}`}
                  className="text-xs bg-terra text-white px-3 py-1.5 rounded-lg hover:bg-terra-dark transition-colors">
                  Vedi recensione
                </Link>
                {place.lat && place.lng && (
                  <a href={`https://www.google.com/maps/dir/?api=1&destination=${place.lat},${place.lng}`}
                    target="_blank" rel="noreferrer"
                    className="text-xs border border-ink/20 px-2 py-1.5 rounded-lg hover:bg-paper transition-colors flex items-center gap-1">
                    <Navigation size={11} /> Maps
                  </a>
                )}
              </div>
            </div>
          </Popup>
        </Marker>
      ))}
    </MapContainer>
  )
}
