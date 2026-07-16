import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { LogIn, LogOut, UserPlus, ShieldCheck, Heart } from 'lucide-react'
import { Logo } from '../components/Logo'

function Profile() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  return (
    <div className="min-h-[calc(100vh-56px)] flex items-center justify-center px-4">
      <div className="w-full max-w-sm text-center">
        <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-terra/10 text-terra text-3xl font-display font-semibold mb-4">
          {user.username[0].toUpperCase()}
        </div>
        <h1 className="font-display text-2xl font-semibold capitalize">{user.username}</h1>
        <span className={`inline-flex items-center gap-1 mt-2 text-xs font-medium px-2.5 py-1 rounded-full ${
          user.role === 'master' ? 'bg-terra/10 text-terra' : 'bg-sage/10 text-sage'}`}>
          {user.role === 'master' && <ShieldCheck size={11} />}
          {user.role === 'master' ? 'Account Master' : 'Visitatore'}
        </span>
        <p className="text-ink/40 text-sm mt-3 leading-relaxed">
          {user.role === 'master'
            ? 'Puoi aggiungere città, posti e voti.'
            : 'Puoi esplorare città, mappa, recensioni e salvare i preferiti.'}
        </p>

        <div className="mt-8 space-y-2">
          <Link to="/favorites" className="btn-ghost w-full flex items-center justify-center gap-2">
            <Heart size={15} /> I tuoi preferiti
          </Link>
          <button onClick={() => { logout(); navigate('/') }} className="btn-ghost w-full flex items-center justify-center gap-2 text-red-500 border-red-200 hover:bg-red-50">
            <LogOut size={15} /> Esci
          </button>
        </div>
      </div>
    </div>
  )
}

export default function Login() {
  const { user, login, register } = useAuth()
  const navigate = useNavigate()
  const [mode, setMode] = useState('login') // 'login' | 'register'
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState(null)
  const [loading, setLoading] = useState(false)

  if (user) return <Profile />

  async function handleSubmit(e) {
    e.preventDefault()
    setLoading(true); setError(null)
    try {
      if (mode === 'login') await login(username, password)
      else await register(username, password)
      navigate('/')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  function switchMode(m) {
    setMode(m); setError(null)
  }

  return (
    <div className="min-h-[calc(100vh-56px)] flex items-center justify-center px-4">
      <div className="w-full max-w-sm">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-14 h-14 mb-3">
            <Logo size={48} />
          </div>
          <h1 className="font-display text-2xl font-semibold">
            {mode === 'login' ? 'Bentornati' : 'Crea un account'}
          </h1>
          <p className="text-ink/40 text-sm mt-1">
            {mode === 'login' ? 'Accedi per continuare' : 'Esplora, recensisci, salva i tuoi posti preferiti'}
          </p>
        </div>

        <div className="flex rounded-xl overflow-hidden border border-ink/15 mb-5">
          <button type="button" onClick={() => switchMode('login')}
            className={`flex-1 py-2.5 text-sm font-medium transition-colors ${
              mode === 'login' ? 'bg-terra text-white' : 'bg-white text-ink/60 hover:bg-paper'}`}>
            Accedi
          </button>
          <button type="button" onClick={() => switchMode('register')}
            className={`flex-1 py-2.5 text-sm font-medium transition-colors ${
              mode === 'register' ? 'bg-terra text-white' : 'bg-white text-ink/60 hover:bg-paper'}`}>
            Registrati
          </button>
        </div>

        <form onSubmit={handleSubmit} className="card p-6 space-y-4">
          <div>
            <label className="text-xs font-medium text-ink/60 mb-1 block">Nome utente</label>
            <input className="input" value={username} onChange={e => setUsername(e.target.value)}
              placeholder={mode === 'login' ? 'luchino, alix o il tuo username' : 'scegli un username'} autoFocus />
          </div>
          <div>
            <label className="text-xs font-medium text-ink/60 mb-1 block">Password</label>
            <input className="input" type="password" value={password} onChange={e => setPassword(e.target.value)}
              placeholder={mode === 'register' ? 'almeno 4 caratteri' : ''} />
          </div>
          {error && <p className="text-red-500 text-sm">{error}</p>}
          <button type="submit" disabled={loading} className="btn-primary w-full flex items-center justify-center gap-2">
            {mode === 'login' ? <LogIn size={15} /> : <UserPlus size={15} />}
            {loading ? '…' : mode === 'login' ? 'Accedi' : 'Crea account'}
          </button>
          {mode === 'register' && (
            <p className="text-xs text-ink/40 text-center leading-relaxed">
              Il tuo account potrà esplorare città, mappa e recensioni e salvare i preferiti.
              Solo Luchino e Alix possono aggiungere posti e voti.
            </p>
          )}
        </form>

        <p className="text-center text-xs text-ink/30 mt-5">
          <Link to="/" className="hover:text-ink/60 transition-colors">Continua come ospite →</Link>
        </p>
      </div>
    </div>
  )
}
