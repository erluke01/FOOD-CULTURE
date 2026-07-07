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

---

## Stato del progetto

La piattaforma Android è già configurata in `frontend/android/` (creata con
`npx cap add android`), con icona, splash screen, status bar e gestione del
tasto Indietro già personalizzati. Non serve ripetere `cap add android` a
meno che la cartella `frontend/android` venga cancellata.

## Passi — eseguili nella cartella `frontend`

```bash
cd wanderlist/frontend
```

### 1. Installa le dipendenze (solo la prima volta o dopo `git pull`)

```bash
npm install
```

### 2. Build del frontend + sincronizzazione Android

```bash
npm run build
npx cap sync android
```

### 3. Apri in Android Studio

```bash
npx cap open android
```

(La prima apertura può richiedere qualche minuto: Android Studio scarica le
build-tools/piattaforme mancanti automaticamente.)

---

## Installare l'app sul tuo dispositivo

1. Sul telefono: **Impostazioni → Info telefono** → tocca 7 volte su "Numero build"
   per attivare le Opzioni sviluppatore, poi **Opzioni sviluppatore → Debug USB** (ON)
2. Collega il telefono al PC via USB e autorizza la connessione quando richiesto
3. In Android Studio, seleziona il tuo dispositivo dal menu in alto e clicca **▶ Run**
   — l'app si installa e si avvia direttamente sul telefono
4. Per generare un file APK installabile manualmente (es. da condividere):
   **Build → Build Bundle(s) / APK(s) → Build APK(s)**
   Il file si trova in:
   `android/app/build/outputs/apk/debug/app-debug.apk`
   Trasferiscilo sul telefono e aprilo per installarlo (potrebbe servire
   abilitare "Installa da fonti sconosciute" per il file manager usato).

### Build da riga di comando (alternativa ad Android Studio)

```bash
cd android
./gradlew assembleDebug
```

L'APK compare in `android/app/build/outputs/apk/debug/app-debug.apk`.

---

## Comandi di aggiornamento (ogni volta che modifichi il codice)

```bash
npm run build
npx cap sync android
```

Poi in Android Studio clicca **▶ Run** di nuovo (o rilancia `./gradlew assembleDebug`).

---

## Note

- La mappa (Leaflet) richiede connessione internet per le tile di OpenStreetMap
- I font (Google Fonts) richiedono internet; senza internet il font di fallback è serif/system
- I dati sono locali al dispositivo — ogni telefono ha il suo database separato
- Il tasto Indietro del telefono naviga all'indietro nell'app invece di uscire subito
