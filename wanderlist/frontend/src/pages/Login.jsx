import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { LogIn, MapPin } from 'lucide-react'

export default function Login() {
  const { login } = useAuth()
  const navigate = useNavigate()
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState(null)
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e) {
    e.preventDefault()
    setLoading(true); setError(null)
    try {
      await login(username, password)
      navigate('/')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-[calc(100vh-56px)] flex items-center justify-center px-4">
      <div className="w-full max-w-sm">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-12 h-12 rounded-2xl bg-terra/10 text-terra mb-3">
            <MapPin size={22} />
          </div>
          <h1 className="font-display text-2xl font-semibold">Bentornati</h1>
          <p className="text-ink/40 text-sm mt-1">Accedi per aggiungere recensioni</p>
        </div>

        <form onSubmit={handleSubmit} className="card p-6 space-y-4">
          <div>
            <label className="text-xs font-medium text-ink/60 mb-1 block">Nome utente</label>
            <input className="input" value={username} onChange={e => setUsername(e.target.value)}
              placeholder="luchino o alix" autoFocus />
          </div>
          <div>
            <label className="text-xs font-medium text-ink/60 mb-1 block">Password</label>
            <input className="input" type="password" value={password} onChange={e => setPassword(e.target.value)} />
          </div>
          {error && <p className="text-red-500 text-sm">{error}</p>}
          <button type="submit" disabled={loading} className="btn-primary w-full flex items-center justify-center gap-2">
            <LogIn size={15} /> {loading ? 'Accesso…' : 'Accedi'}
          </button>
        </form>

        <p className="text-center text-xs text-ink/30 mt-5">
          <Link to="/" className="hover:text-ink/60 transition-colors">Continua come ospite →</Link>
        </p>
      </div>
    </div>
  )
}
