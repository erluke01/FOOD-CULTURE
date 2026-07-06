const BASE = '/api'

export function apiFetch(path, options = {}, authHeader = {}) {
  return fetch(BASE + path, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...authHeader,
      ...options.headers,
    },
  }).then(async r => {
    if (!r.ok) {
      const err = await r.json().catch(() => ({ detail: 'Errore sconosciuto' }))
      throw new Error(err.detail || 'Errore')
    }
    return r.json()
  })
}
