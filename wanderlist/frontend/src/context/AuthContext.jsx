import { createContext, useContext, useState, useEffect } from 'react'

const AuthCtx = createContext(null)

// Credenziali locali (stesse password del backend)
const LOCAL_USERS = {
  luchino: { password: 'luchino123', role: 'editor' },
  alix:    { password: 'alix123',    role: 'editor' },
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
    if (!creds) { setLoading(false); return }
    const found = LOCAL_USERS[creds.username]
    if (found && found.password === creds.password) {
      setUser({ username: creds.username, role: found.role })
    } else {
      // credenziali non valide → logout automatico
      setCreds(null)
      localStorage.removeItem('wl_creds')
    }
    setLoading(false)
  }, [creds])

  function authHeader(c = creds) {
    if (!c) return {}
    return { Authorization: 'Basic ' + btoa(`${c.username}:${c.password}`) }
  }

  async function login(username, password) {
    const found = LOCAL_USERS[username]
    if (!found || found.password !== password) {
      throw new Error('Credenziali non valide')
    }
    const c = { username, password }
    setCreds(c)
    setUser({ username, role: found.role })
    localStorage.setItem('wl_creds', JSON.stringify(c))
  }

  function logout() {
    setCreds(null)
    setUser(null)
    localStorage.removeItem('wl_creds')
  }

  return (
    <AuthCtx.Provider value={{ user, creds, loading, login, logout, authHeader }}>
      {children}
    </AuthCtx.Provider>
  )
}

export const useAuth = () => useContext(AuthCtx)
