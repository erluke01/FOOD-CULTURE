import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import { Navbar } from './components/Navbar'
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
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/city/:cityId" element={<CityPage />} />
          <Route path="/places/:placeId" element={<PlaceDetail />} />
          <Route path="/login" element={<Login />} />
          <Route path="/favorites" element={<Favorites />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  )
}
