# 🗺️ Wanderlist — Il vostro diario di viaggio

App full-stack per tracciare i posti dove mangiate, bevete e andate in visita, città per città — con voti separati per Luchino e Alix, mappa interattiva e filtri per categoria/tag.

## Stack

- **Backend:** Python + FastAPI + SQLite (un unico file `wanderlist.db`, nessun database esterno da installare)
- **Frontend:** React + Vite + Tailwind CSS + React Router
- **Mappa:** Leaflet + OpenStreetMap (gratuita, nessuna API key richiesta) + link diretto a Google Maps per le indicazioni

## Requisiti

- **Python 3.9+** (verifica con `python3 --version`)
- **Node.js 18+** (verifica con `node --version`)

Se non li hai installati: [python.org/downloads](https://www.python.org/downloads/) e [nodejs.org](https://nodejs.org/)

## Avvio rapido

Servono **due terminali aperti contemporaneamente** (uno per il backend, uno per il frontend).

### Terminale 1 — Backend

```bash
cd wanderlist/backend
chmod +x start.sh
./start.sh
```

La prima volta installerà le dipendenze Python automaticamente (richiede qualche secondo). Il backend resta in ascolto su **http://localhost:8000**.

### Terminale 2 — Frontend

```bash
cd wanderlist/frontend
chmod +x start.sh
./start.sh
```

La prima volta installerà i pacchetti npm (può richiedere un minuto). Il frontend si apre su **http://localhost:5173**.

### Apri il browser

Vai su **http://localhost:5173** — l'app è pronta!

> Per chiudere: `Ctrl+C` in entrambi i terminali. Per riavviare la prossima volta, basta rilanciare gli stessi due comandi `./start.sh`.

## Credenziali di accesso

| Utente | Username | Password |
|---|---|---|
| Luchino | `luchino` | `luchino123` |
| Alix | `alix` | `alix123` |

Senza login si naviga come **ospite**: si vedono tutti i posti e si possono salvare nei preferiti, ma non si possono aggiungere recensioni.

> 🔒 **Consiglio:** cambia le password in `backend/main.py` (dizionario `USERS` in cima al file) prima di usarla regolarmente, soprattutto se la condividi.

## Come si usa

1. **Home** → crea le città (es. Milano, Roma, Lisbona…)
2. Entra in una città → **Aggiungi** un posto, scegli se è "Mangiare & Bere" o "Da Visitare"
3. Per "Mangiare & Bere": categoria libera + tag momento (Colazione, Pranzo, Cena…) + voti su Qualità/Quantità/Prezzo/Servizio/Pulizia
4. Per "Da Visitare": categoria fissa (Musei, Chiese, Monumenti…) + voti su Bellezza/Costo
5. Ogni posto mostra il voto medio di entrambi + la media generale
6. Vista **Mappa** per vedere tutti i pin sulla città, cliccando si apre la recensione e il bottone per le indicazioni Google Maps
7. **Filtri** per tipo, categoria e tag
8. **Preferiti** ❤️ per salvare i posti che ti interessano (disponibile anche da ospite)

## Dati salvati

Tutto viene salvato automaticamente in `backend/wanderlist.db` (database SQLite). Questo file **è il tuo intero diario**: fai un backup ogni tanto copiandolo altrove (es. su Google Drive o iCloud) per non perdere nulla.

## Struttura del progetto

```
wanderlist/
├── backend/
│   ├── main.py           # API FastAPI (città, posti, voti, preferiti)
│   ├── requirements.txt
│   ├── start.sh
│   └── wanderlist.db     # creato automaticamente al primo avvio
└── frontend/
    ├── src/
    │   ├── pages/         # Home, CityPage, PlaceDetail, Login, Favorites
    │   ├── components/    # Navbar, PlaceCard, PlacesMap, PlaceForm, StarRating
    │   ├── context/        # AuthContext
    │   └── utils/api.js
    ├── package.json
    └── start.sh
```

## Estensioni future possibili

- Foto per ogni posto
- Esportazione/backup automatico
- App mobile (PWA) per usarla anche fuori casa
- Statistiche (media voti per città, posti più amati, ecc.)
