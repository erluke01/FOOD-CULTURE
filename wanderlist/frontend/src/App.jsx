import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import { Navbar } from './components/Navbar'
import { MobileTabBar } from './components/MobileTabBar'
import Home from './pages/Home'
import CityPage from './pages/CityPage'
import PlaceDetail from './pages/PlaceDetail'
import Login from './pages/Login'
import Favorites from './pages/Favorites'

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Navbar />
        <div className="pb-16 sm:pb-0">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/city/:cityId" element={<CityPage />} />
            <Route path="/places/:placeId" element={<PlaceDetail />} />
            <Route path="/login" element={<Login />} />
            <Route path="/favorites" element={<Favorites />} />
          </Routes>
        </div>
        <MobileTabBar />
      </BrowserRouter>
    </AuthProvider>
  )
}
