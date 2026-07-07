import { NavLink } from 'react-router-dom'
import { Home, Heart, User } from 'lucide-react'

const tabs = [
  { to: '/', label: 'Esplora', icon: Home, end: true },
  { to: '/favorites', label: 'Preferiti', icon: Heart },
  { to: '/login', label: 'Account', icon: User },
]

export function MobileTabBar() {
  return (
    <nav
      className="sm:hidden fixed bottom-0 inset-x-0 z-40 bg-white/95 backdrop-blur border-t border-paper-dark flex"
      style={{ paddingBottom: 'env(safe-area-inset-bottom)' }}
    >
      {tabs.map(({ to, label, icon: Icon, end }) => (
        <NavLink
          key={to}
          to={to}
          end={end}
          className={({ isActive }) =>
            `flex-1 flex flex-col items-center gap-0.5 py-2.5 text-xs font-medium transition-colors ${
              isActive ? 'text-terra' : 'text-ink/40'}`
          }
        >
          <Icon size={20} />
          {label}
        </NavLink>
      ))}
    </nav>
  )
}
