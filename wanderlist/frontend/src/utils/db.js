import Dexie from 'dexie'

export const db = new Dexie('wanderlist')

db.version(1).stores({
  cities:    '++id, name',
  places:    '++id, city_id, type, category, tag',
  ratings:   '++id, [place_id+user], place_id',
  favorites: '++id, [user+place_id], user, place_id',
})

db.version(2).stores({
  cities:    '++id, name',
  places:    '++id, city_id, type, category, tag',
  ratings:   '++id, [place_id+user], place_id',
  favorites: '++id, [user+place_id], user, place_id',
  users:     '++id, &username',
})
