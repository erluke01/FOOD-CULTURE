import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { LogIn, LogOut, Heart, MapPin, ShieldCheck } from 'lucide-react'

export function Navbar() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  return (
    <nav className="sticky top-0 z-50 bg-white/90 backdrop-blur border-b border-paper-dark">
      <div className="max-w-6xl mx-auto px-4 h-14 flex items-center justify-between">
        <Link to="/" className="font-display text-xl text-terra flex items-center gap-2">
          <MapPin size={18} className="text-terra" />
          Wanderlist
        </Link>

        <div className="hidden sm:flex items-center gap-2">
          {user ? (
            <>
              <Link to="/favorites" className="btn-ghost flex items-center gap-1.5 py-1.5">
                <Heart size={14} /> Preferiti
              </Link>
              <span className={`inline-flex items-center gap-1 text-xs font-medium px-2.5 py-1 rounded-full ${
                user.role === 'master' ? 'bg-terra/10 text-terra' : 'bg-sage/10 text-sage'}`}>
                {user.role === 'master' && <ShieldCheck size={11} />}
                {user.username} · {user.role === 'master' ? 'Master' : 'Visitatore'}
              </span>
              <button onClick={() => { logout(); navigate('/') }} className="btn-ghost py-1.5 flex items-center gap-1.5">
                <LogOut size={14} /> Esci
              </button>
            </>
          ) : (
            <Link to="/login" className="btn-ghost py-1.5 flex items-center gap-1.5">
              <LogIn size={14} /> Accedi
            </Link>
          )}
        </div>
      </div>
    </nav>
  )
}
