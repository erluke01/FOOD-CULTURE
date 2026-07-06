from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from pydantic import BaseModel
from typing import Optional, List
import sqlite3, secrets, hashlib, os

app = FastAPI(title="Wanderlist API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

security = HTTPBasic(auto_error=False)
DB_PATH = os.path.join(os.path.dirname(__file__), "wanderlist.db")

# ── Users ──────────────────────────────────────────────────────────────────
USERS = {
    "luchino": {"password": hashlib.sha256("luchino123".encode()).hexdigest(), "role": "editor"},
    "alix":    {"password": hashlib.sha256("alix123".encode()).hexdigest(),    "role": "editor"},
}

def get_current_user(credentials: HTTPBasicCredentials = Depends(security)):
    if not credentials:
        return None
    user = USERS.get(credentials.username)
    if not user:
        return None
    hashed = hashlib.sha256(credentials.password.encode()).hexdigest()
    if not secrets.compare_digest(hashed, user["password"]):
        return None
    return {"username": credentials.username, "role": user["role"]}

def require_editor(credentials: HTTPBasicCredentials = Depends(security)):
    user = get_current_user(credentials)
    if not user or user["role"] != "editor":
        raise HTTPException(status_code=401, detail="Accesso non autorizzato")
    return user

# ── DB Init ────────────────────────────────────────────────────────────────
def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL")
    return conn

def init_db():
    conn = get_db()
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS cities (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE NOT NULL,
            country TEXT,
            lat REAL,
            lng REAL,
            created_at TEXT DEFAULT (datetime('now'))
        );

        CREATE TABLE IF NOT EXISTS places (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            city_id INTEGER NOT NULL REFERENCES cities(id),
            type TEXT NOT NULL CHECK(type IN ('food','visit')),
            name TEXT NOT NULL,
            address TEXT,
            category TEXT,
            tag TEXT,
            lat REAL,
            lng REAL,
            date_visited TEXT,
            note TEXT,
            created_at TEXT DEFAULT (datetime('now')),
            created_by TEXT
        );

        CREATE TABLE IF NOT EXISTS ratings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            place_id INTEGER NOT NULL REFERENCES places(id) ON DELETE CASCADE,
            user TEXT NOT NULL,
            quality REAL,
            quantity REAL,
            price REAL,
            service REAL,
            cleanliness REAL,
            beauty REAL,
            cost REAL,
            created_at TEXT DEFAULT (datetime('now')),
            UNIQUE(place_id, user)
        );

        CREATE TABLE IF NOT EXISTS favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user TEXT NOT NULL,
            place_id INTEGER NOT NULL REFERENCES places(id) ON DELETE CASCADE,
            created_at TEXT DEFAULT (datetime('now')),
            UNIQUE(user, place_id)
        );
    """)
    conn.commit()
    conn.close()

init_db()

# ── Models ─────────────────────────────────────────────────────────────────
class CityCreate(BaseModel):
    name: str
    country: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None

class PlaceCreate(BaseModel):
    city_id: int
    type: str
    name: str
    address: Optional[str] = None
    category: Optional[str] = None
    tag: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    date_visited: Optional[str] = None
    note: Optional[str] = None

class RatingCreate(BaseModel):
    place_id: int
    quality: Optional[float] = None
    quantity: Optional[float] = None
    price: Optional[float] = None
    service: Optional[float] = None
    cleanliness: Optional[float] = None
    beauty: Optional[float] = None
    cost: Optional[float] = None

# ── Helpers ────────────────────────────────────────────────────────────────
def avg(*vals):
    v = [x for x in vals if x is not None]
    return round(sum(v) / len(v), 2) if v else None

def row_to_dict(row):
    return dict(row) if row else None

def place_with_ratings(conn, place_id, fav_user=None):
    place = row_to_dict(conn.execute("SELECT * FROM places WHERE id=?", (place_id,)).fetchone())
    if not place:
        return None
    ratings = [row_to_dict(r) for r in conn.execute(
        "SELECT * FROM ratings WHERE place_id=?", (place_id,)).fetchall()]
    
    # compute averages per user and global
    for r in ratings:
        if place["type"] == "food":
            r["avg"] = avg(r["quality"], r["quantity"], r["price"], r["service"], r["cleanliness"])
        else:
            r["avg"] = avg(r["beauty"], r["cost"])
    
    global_scores = [r["avg"] for r in ratings if r["avg"] is not None]
    place["ratings"] = ratings
    place["avg_score"] = round(sum(global_scores) / len(global_scores), 2) if global_scores else None
    
    if fav_user:
        fav = conn.execute(
            "SELECT id FROM favorites WHERE user=? AND place_id=?", (fav_user, place_id)).fetchone()
        place["is_favorite"] = bool(fav)
    
    return place

# ── Cities ─────────────────────────────────────────────────────────────────
@app.get("/cities")
def list_cities():
    conn = get_db()
    rows = conn.execute("SELECT * FROM cities ORDER BY name").fetchall()
    conn.close()
    return [dict(r) for r in rows]

@app.post("/cities", status_code=201)
def create_city(body: CityCreate, user=Depends(require_editor)):
    conn = get_db()
    try:
        cur = conn.execute(
            "INSERT INTO cities(name,country,lat,lng) VALUES(?,?,?,?)",
            (body.name, body.country, body.lat, body.lng))
        conn.commit()
        city_id = cur.lastrowid
    except sqlite3.IntegrityError:
        conn.close()
        raise HTTPException(400, "Città già esistente")
    row = conn.execute("SELECT * FROM cities WHERE id=?", (city_id,)).fetchone()
    conn.close()
    return dict(row)

@app.delete("/cities/{city_id}")
def delete_city(city_id: int, user=Depends(require_editor)):
    conn = get_db()
    conn.execute("DELETE FROM cities WHERE id=?", (city_id,))
    conn.commit()
    conn.close()
    return {"ok": True}

# ── Places ─────────────────────────────────────────────────────────────────
@app.get("/places")
def list_places(city_id: Optional[int] = None, type: Optional[str] = None,
                category: Optional[str] = None, tag: Optional[str] = None,
                user: Optional[str] = None, credentials=Depends(security)):
    current = get_current_user(credentials)
    fav_user = current["username"] if current else None
    
    conn = get_db()
    q = "SELECT id FROM places WHERE 1=1"
    params = []
    if city_id:
        q += " AND city_id=?"; params.append(city_id)
    if type:
        q += " AND type=?"; params.append(type)
    if category:
        q += " AND category=?"; params.append(category)
    if tag:
        q += " AND tag=?"; params.append(tag)
    
    rows = conn.execute(q, params).fetchall()
    places = [place_with_ratings(conn, r["id"], fav_user) for r in rows]
    
    # sort: category asc, avg_score desc
    places.sort(key=lambda p: (
        p["category"] or "zzz",
        -(p["avg_score"] or -1)
    ))
    conn.close()
    return places

@app.get("/places/{place_id}")
def get_place(place_id: int, credentials=Depends(security)):
    current = get_current_user(credentials)
    fav_user = current["username"] if current else None
    conn = get_db()
    place = place_with_ratings(conn, place_id, fav_user)
    conn.close()
    if not place:
        raise HTTPException(404, "Posto non trovato")
    return place

@app.post("/places", status_code=201)
def create_place(body: PlaceCreate, user=Depends(require_editor)):
    conn = get_db()
    cur = conn.execute(
        "INSERT INTO places(city_id,type,name,address,category,tag,lat,lng,date_visited,note,created_by) "
        "VALUES(?,?,?,?,?,?,?,?,?,?,?)",
        (body.city_id, body.type, body.name, body.address, body.category,
         body.tag, body.lat, body.lng, body.date_visited, body.note, user["username"]))
    conn.commit()
    place_id = cur.lastrowid
    place = place_with_ratings(conn, place_id)
    conn.close()
    return place

@app.put("/places/{place_id}")
def update_place(place_id: int, body: PlaceCreate, user=Depends(require_editor)):
    conn = get_db()
    conn.execute(
        "UPDATE places SET name=?,address=?,category=?,tag=?,lat=?,lng=?,date_visited=?,note=? WHERE id=?",
        (body.name, body.address, body.category, body.tag,
         body.lat, body.lng, body.date_visited, body.note, place_id))
    conn.commit()
    place = place_with_ratings(conn, place_id)
    conn.close()
    return place

@app.delete("/places/{place_id}")
def delete_place(place_id: int, user=Depends(require_editor)):
    conn = get_db()
    conn.execute("DELETE FROM places WHERE id=?", (place_id,))
    conn.commit()
    conn.close()
    return {"ok": True}

# ── Ratings ────────────────────────────────────────────────────────────────
@app.post("/ratings", status_code=201)
def upsert_rating(body: RatingCreate, user=Depends(require_editor)):
    conn = get_db()
    conn.execute("""
        INSERT INTO ratings(place_id,user,quality,quantity,price,service,cleanliness,beauty,cost)
        VALUES(?,?,?,?,?,?,?,?,?)
        ON CONFLICT(place_id,user) DO UPDATE SET
            quality=excluded.quality, quantity=excluded.quantity, price=excluded.price,
            service=excluded.service, cleanliness=excluded.cleanliness,
            beauty=excluded.beauty, cost=excluded.cost
    """, (body.place_id, user["username"], body.quality, body.quantity, body.price,
          body.service, body.cleanliness, body.beauty, body.cost))
    conn.commit()
    place = place_with_ratings(conn, body.place_id)
    conn.close()
    return place

# ── Favorites ──────────────────────────────────────────────────────────────
@app.get("/favorites")
def list_favorites(credentials=Depends(security)):
    user = get_current_user(credentials)
    if not user:
        raise HTTPException(401, "Login richiesto")
    conn = get_db()
    rows = conn.execute(
        "SELECT place_id FROM favorites WHERE user=?", (user["username"],)).fetchall()
    places = [place_with_ratings(conn, r["place_id"], user["username"]) for r in rows]
    conn.close()
    return places

@app.post("/favorites/{place_id}", status_code=201)
def add_favorite(place_id: int, credentials=Depends(security)):
    user = get_current_user(credentials)
    if not user:
        raise HTTPException(401, "Login richiesto")
    conn = get_db()
    try:
        conn.execute("INSERT INTO favorites(user,place_id) VALUES(?,?)", (user["username"], place_id))
        conn.commit()
    except sqlite3.IntegrityError:
        pass
    conn.close()
    return {"ok": True}

@app.delete("/favorites/{place_id}")
def remove_favorite(place_id: int, credentials=Depends(security)):
    user = get_current_user(credentials)
    if not user:
        raise HTTPException(401, "Login richiesto")
    conn = get_db()
    conn.execute("DELETE FROM favorites WHERE user=? AND place_id=?", (user["username"], place_id))
    conn.commit()
    conn.close()
    return {"ok": True}

# ── Categories & Tags ──────────────────────────────────────────────────────
@app.get("/categories")
def list_categories(type: Optional[str] = None, city_id: Optional[int] = None):
    conn = get_db()
    q = "SELECT DISTINCT category FROM places WHERE category IS NOT NULL AND category != ''"
    params = []
    if type:
        q += " AND type=?"; params.append(type)
    if city_id:
        q += " AND city_id=?"; params.append(city_id)
    rows = conn.execute(q + " ORDER BY category", params).fetchall()
    conn.close()
    return [r["category"] for r in rows]

@app.get("/me")
def me(credentials=Depends(security)):
    user = get_current_user(credentials)
    if not user:
        return {"user": None}
    return {"user": user["username"], "role": user["role"]}
