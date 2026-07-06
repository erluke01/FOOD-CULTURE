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
          <Popup maxWidth={240} className="wanderlist-popup">
            <div className="font-sans p-1">
              <div className="font-semibold text-sm text-ink mb-0.5">{place.name}</div>
              {place.category && (
                <span className="inline-block text-xs bg-paper-dark px-2 py-0.5 rounded-full mb-1">{place.category}</span>
              )}
              {place.avg_score != null && (
                <div className="mb-1"><StarDisplay score={place.avg_score} /></div>
              )}
              {place.address && (
                <p className="text-xs text-ink/50 mb-2">{place.address}</p>
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
