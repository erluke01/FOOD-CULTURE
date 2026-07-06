# Build APK Android — Wanderlist

## Cosa è cambiato

L'app non usa più il backend Python. Tutti i dati (città, posti, rating, preferiti)
sono salvati direttamente sul dispositivo in IndexedDB via **Dexie.js**.
Credenziali: `luchino / luchino123` e `alix / alix123` (invariate).

---

## Prerequisiti

- **Node.js** ≥ 18 installato
- **Android Studio** installato (include Java e Android SDK)
  → https://developer.android.com/studio
- **Java 17** o superiore (viene con Android Studio)

---

## Passi — eseguili nella cartella `frontend`

```bash
cd wanderlist/frontend
```

### 1. Installa le dipendenze

```bash
npm install dexie @capacitor/core @capacitor/cli @capacitor/android
```

### 2. Build del frontend

```bash
npm run build
```

### 3. Aggiungi la piattaforma Android (solo la prima volta)

```bash
npx cap add android
```

### 4. Sincronizza l'app con Android

```bash
npx cap sync
```

### 5. Apri in Android Studio

```bash
npx cap open android
```

---

## Generare l'APK in Android Studio

1. Connetti il telefono Android via USB con **Debug USB attivo**
   (Impostazioni → Opzioni sviluppatore → Debug USB)
2. In Android Studio clicca **▶ Run** — installa e avvia direttamente sul telefono
3. Per il file APK standalone:
   **Build → Build Bundle(s) / APK(s) → Build APK(s)**
   Il file si trova in:
   `android/app/build/outputs/apk/debug/app-debug.apk`

---

## Comandi di aggiornamento (ogni volta che modifichi il codice)

```bash
npm run build
npx cap sync
```

Poi in Android Studio clicca **▶ Run** di nuovo.

---

## Note

- La mappa (Leaflet) richiede connessione internet per le tile di OpenStreetMap
- I font (Google Fonts) richiedono internet; senza internet il font di fallback è serif/system
- I dati sono locali al dispositivo — ogni telefono ha il suo database separato
