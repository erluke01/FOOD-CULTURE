import { createContext, useContext, useState, useEffect } from 'react'

const AuthCtx = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [creds, setCreds] = useState(() => {
    const s = localStorage.getItem('wl_creds')
    return s ? JSON.parse(s) : null
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!creds) { setLoading(false); return }
    fetch('/api/me', { headers: authHeader(creds) })
      .then(r => r.json())
      .then(d => { if (d.user) setUser({ username: d.user, role: d.role }) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [creds])

  function authHeader(c = creds) {
    if (!c) return {}
    return { Authorization: 'Basic ' + btoa(`${c.username}:${c.password}`) }
  }

  async function login(username, password) {
    const r = await fetch('/api/me', {
      headers: { Authorization: 'Basic ' + btoa(`${username}:${password}`) }
    })
    const d = await r.json()
    if (!d.user) throw new Error('Credenziali non valide')
    const c = { username, password }
    setCreds(c)
    setUser({ username: d.user, role: d.role })
    localStorage.setItem('wl_creds', JSON.stringify(c))
  }

  function logout() {
    setCreds(null); setUser(null)
    localStorage.removeItem('wl_creds')
  }

  return (
    <AuthCtx.Provider value={{ user, creds, loading, login, logout, authHeader }}>
      {children}
    </AuthCtx.Provider>
  )
}

export const useAuth = () => useContext(AuthCtx)
