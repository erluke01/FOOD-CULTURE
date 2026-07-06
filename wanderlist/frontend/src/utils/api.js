import { db } from './db'

// ── helpers ────────────────────────────────────────────────────────────────
function avgOf(...vals) {
  const v = vals.filter(x => x != null && !isNaN(x))
  return v.length ? Math.round((v.reduce((a, b) => a + b, 0) / v.length) * 100) / 100 : null
}

function ratingAvg(r, type) {
  if (type === 'food') return avgOf(r.quality, r.quantity, r.price, r.service, r.cleanliness)
  return avgOf(r.beauty, r.cost)
}

async function placeWithRatings(place, currentUser = null) {
  if (!place) return null
  const ratings = await db.ratings.where('place_id').equals(place.id).toArray()
  for (const r of ratings) r.avg = ratingAvg(r, place.type)

  const scores = ratings.map(r => r.avg).filter(s => s != null)
  const avg_score = scores.length
    ? Math.round((scores.reduce((a, b) => a + b, 0) / scores.length) * 100) / 100
    : null

  let is_favorite = false
  if (currentUser) {
    const fav = await db.favorites
      .where('[user+place_id]').equals([currentUser, place.id]).first()
    is_favorite = !!fav
  }

  return { ...place, ratings, avg_score, is_favorite }
}

function parseAuth(authHeader) {
  const auth = authHeader?.Authorization
  if (!auth || !auth.startsWith('Basic ')) return null
  try {
    const decoded = atob(auth.slice(6))
    return decoded.split(':')[0] || null
  } catch { return null }
}

function parseQuery(rawQuery) {
  const q = {}
  if (!rawQuery) return q
  rawQuery.split('&').forEach(part => {
    const [k, v] = part.split('=')
    if (k) q[k] = decodeURIComponent(v ?? '')
  })
  return q
}

// ── main router ────────────────────────────────────────────────────────────
export async function apiFetch(path, options = {}, authHeader = {}) {
  const method = (options.method || 'GET').toUpperCase()
  const body   = options.body ? JSON.parse(options.body) : null
  const currentUser = parseAuth(authHeader)

  const [rawPath, rawQuery] = path.split('?')
  const query    = parseQuery(rawQuery)
  const segments = rawPath.replace(/^\//, '').split('/')
  const resource = segments[0]
  const id       = segments[1] ? parseInt(segments[1]) : null

  // ── /cities ──────────────────────────────────────────────────────────────
  if (resource === 'cities') {
    if (method === 'GET' && !id) {
      return db.cities.orderBy('name').toArray()
    }
    if (method === 'POST') {
      // check duplicate
      const exists = await db.cities.where('name').equalsIgnoreCase(body.name).first()
      if (exists) throw new Error('Città già esistente')
      const cityId = await db.cities.add({ ...body, created_at: new Date().toISOString() })
      return db.cities.get(cityId)
    }
    if (method === 'DELETE' && id) {
      const places = await db.places.where('city_id').equals(id).toArray()
      for (const p of places) {
        await db.ratings.where('place_id').equals(p.id).delete()
        await db.favorites.where('place_id').equals(p.id).delete()
      }
      await db.places.where('city_id').equals(id).delete()
      await db.cities.delete(id)
      return { ok: true }
    }
  }

  // ── /places ───────────────────────────────────────────────────────────────
  if (resource === 'places') {
    if (method === 'GET' && !id) {
      let places = await db.places.toArray()
      if (query.city_id) places = places.filter(p => p.city_id === parseInt(query.city_id))
      if (query.type)    places = places.filter(p => p.type === query.type)
      if (query.category) places = places.filter(p => p.category === query.category)
      if (query.tag)     places = places.filter(p => p.tag === query.tag)

      const enriched = await Promise.all(places.map(p => placeWithRatings(p, currentUser)))
      enriched.sort((a, b) => {
        const ca = (a.category || 'zzz').toLowerCase()
        const cb = (b.category || 'zzz').toLowerCase()
        if (ca !== cb) return ca.localeCompare(cb)
        return (b.avg_score ?? -1) - (a.avg_score ?? -1)
      })
      return enriched
    }
    if (method === 'GET' && id) {
      const place = await db.places.get(id)
      if (!place) throw new Error('Posto non trovato')
      return placeWithRatings(place, currentUser)
    }
    if (method === 'POST') {
      const placeId = await db.places.add({
        ...body,
        created_at: new Date().toISOString(),
        created_by: currentUser,
      })
      const saved = await db.places.get(placeId)
      return placeWithRatings(saved, currentUser)
    }
    if (method === 'PUT' && id) {
      const { city_id, ...rest } = body // don't overwrite city_id
      await db.places.update(id, rest)
      const saved = await db.places.get(id)
      return placeWithRatings(saved, currentUser)
    }
    if (method === 'DELETE' && id) {
      await db.ratings.where('place_id').equals(id).delete()
      await db.favorites.where('place_id').equals(id).delete()
      await db.places.delete(id)
      return { ok: true }
    }
  }

  // ── /ratings ──────────────────────────────────────────────────────────────
  if (resource === 'ratings' && method === 'POST') {
    const { place_id, ...ratingData } = body
    const user = currentUser
    const existing = await db.ratings
      .where('[place_id+user]').equals([place_id, user]).first()
    if (existing) {
      await db.ratings.update(existing.id, { ...ratingData, place_id, user })
    } else {
      await db.ratings.add({ ...ratingData, place_id, user, created_at: new Date().toISOString() })
    }
    const place = await db.places.get(place_id)
    return placeWithRatings(place, user)
  }

  // ── /favorites ────────────────────────────────────────────────────────────
  if (resource === 'favorites') {
    const user = currentUser
    if (method === 'GET') {
      const favs = await db.favorites.where('user').equals(user).toArray()
      const results = await Promise.all(
        favs.map(async f => {
          const place = await db.places.get(f.place_id)
          return placeWithRatings(place, user)
        })
      )
      return results.filter(Boolean)
    }
    if (method === 'POST' && id) {
      const exists = await db.favorites
        .where('[user+place_id]').equals([user, id]).first()
      if (!exists) {
        await db.favorites.add({ user, place_id: id, created_at: new Date().toISOString() })
      }
      return { ok: true }
    }
    if (method === 'DELETE' && id) {
      await db.favorites.where('[user+place_id]').equals([user, id]).delete()
      return { ok: true }
    }
  }

  // ── /categories ───────────────────────────────────────────────────────────
  if (resource === 'categories' && method === 'GET') {
    let places = await db.places.toArray()
    if (query.city_id) places = places.filter(p => p.city_id === parseInt(query.city_id))
    if (query.type)    places = places.filter(p => p.type === query.type)
    const cats = [...new Set(places.map(p => p.category).filter(Boolean))].sort()
    return cats
  }

  throw new Error(`Route non trovata: ${method} ${path}`)
}
