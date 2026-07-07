import { createContext, useContext, useState, useEffect } from 'react'
import { db } from '../utils/db'

const AuthCtx = createContext(null)

// Account "master" fissi — possono inserire/modificare posti e recensioni.
const MASTER_USERS = {
  luchino: { password: 'luchino123' },
  alix:    { password: 'alix123' },
}

function normalize(username) {
  return username.trim().toLowerCase()
}

async function resolveUser(username, password) {
  const u = normalize(username)
  const master = MASTER_USERS[u]
  if (master && master.password === password) {
    return { username: u, role: 'master' }
  }
  const viewer = await db.users.where('username').equals(u).first()
  if (viewer && viewer.password === password) {
    return { username: u, role: 'viewer' }
  }
  return null
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [creds, setCreds] = useState(() => {
    try {
      const s = localStorage.getItem('wl_creds')
      return s ? JSON.parse(s) : null
    } catch { return null }
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let cancelled = false
    if (!creds) { setLoading(false); return }
    resolveUser(creds.username, creds.password).then(found => {
      if (cancelled) return
      if (found) {
        setUser(found)
      } else {
        // credenziali non valide → logout automatico
        setCreds(null)
        localStorage.removeItem('wl_creds')
      }
      setLoading(false)
    })
    return () => { cancelled = true }
  }, [creds])

  function authHeader(c = creds) {
    if (!c) return {}
    return { Authorization: 'Basic ' + btoa(`${c.username}:${c.password}`) }
  }

  async function login(username, password) {
    const found = await resolveUser(username, password)
    if (!found) throw new Error('Credenziali non valide')
    const c = { username: found.username, password }
    setCreds(c)
    setUser(found)
    localStorage.setItem('wl_creds', JSON.stringify(c))
  }

  async function register(username, password) {
    const u = normalize(username)
    if (!u || u.length < 3) throw new Error('Lo username deve avere almeno 3 caratteri')
    if (!password || password.length < 4) throw new Error('La password deve avere almeno 4 caratteri')
    if (MASTER_USERS[u]) throw new Error('Username non disponibile')
    const existing = await db.users.where('username').equals(u).first()
    if (existing) throw new Error('Username già in uso')

    await db.users.add({ username: u, password, role: 'viewer', created_at: new Date().toISOString() })
    const c = { username: u, password }
    setCreds(c)
    setUser({ username: u, role: 'viewer' })
    localStorage.setItem('wl_creds', JSON.stringify(c))
  }

  function logout() {
    setCreds(null)
    setUser(null)
    localStorage.removeItem('wl_creds')
  }

  return (
    <AuthCtx.Provider value={{ user, creds, loading, login, register, logout, authHeader }}>
      {children}
    </AuthCtx.Provider>
  )
}

export const useAuth = () => useContext(AuthCtx)
