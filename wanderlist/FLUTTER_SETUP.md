# Wanderlist Flutter — Setup & Build

## Struttura del progetto

```
wanderlist/
  flutter_app/     ← app Flutter (questa cartella)
  backend/         ← FastAPI Python (server sync, opzionale)
  frontend/        ← vecchio frontend React (non più necessario)
```

---

## 1. Installa Flutter SDK

Scarica e installa Flutter: https://docs.flutter.dev/get-started/install/windows/mobile

In breve:
1. Scarica il file `.zip` da flutter.dev
2. Estrailo in `C:\src\flutter` (NON in `Program Files`)
3. Aggiungi `C:\src\flutter\bin` alla variabile PATH di Windows
4. Riavvia il terminale e verifica: `flutter doctor`

**Requisiti:**
- Android Studio installato (già richiesto per Capacitor)
- Java 17+ (incluso in Android Studio)

Esegui `flutter doctor` e segui le istruzioni per risolvere eventuali problemi (accettare licenze Android, ecc.)

---

## 2. Crea il progetto Flutter base

Apri un terminale nella cartella `wanderlist`:

```bash
cd wanderlist

# Crea il progetto Flutter nella cartella flutter_app
flutter create flutter_app --org com.wanderlist --project-name wanderlist --platforms android

# Entra nella cartella
cd flutter_app
```

> ⚠️ `flutter create` genera i file Android. I file `lib/` che ho già scritto
> NON verranno sovrascritti se li hai già nella cartella.

---

## 3. Installa le dipendenze

```bash
cd wanderlist/flutter_app
flutter pub get
```

---

## 4. Avvia su dispositivo / emulatore

```bash
# Lista dispositivi disponibili
flutter devices

# Avvia sull'unico dispositivo connesso
flutter run

# Oppure specifica il dispositivo
flutter run -d emulator-5554
```

---

## 5. Build APK

```bash
# APK di debug (per testing, installabile direttamente)
flutter build apk --debug

# APK di release (ottimizzato, per distribuzione)
flutter build apk --release
```

Il file APK si trova in:
```
flutter_app/build/app/outputs/flutter-apk/app-debug.apk
flutter_app/build/app/outputs/flutter-apk/app-release.apk
```

### Installare l'APK sul telefono

Con USB debugging abilitato:
```bash
flutter install
```

Oppure copia il file `.apk` sul telefono e installalo manualmente (devi abilitare
"Installa da sorgenti sconosciute" nelle impostazioni Android).

---

## 6. Configurare il server sync (opzionale)

Il sync è opzionale — l'app funziona perfettamente offline.

Per sincronizzare tra Luchino e Alix:

1. **Avvia il backend** sul PC:
   ```bash
   cd wanderlist/backend
   pip install fastapi uvicorn
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```

2. **Trova l'IP del PC** sulla rete WiFi:
   ```
   Windows: ipconfig → cerca "IPv4 Address", es. 192.168.1.50
   ```

3. **Configura l'URL** nell'app:
   - Vai su → Profilo
   - Inserisci: `http://192.168.1.50:8000`
   - Tocca 💾 per salvare
   - Tocca "Sincronizza ora"

4. **Entrambi i telefoni** devono essere sulla stessa rete WiFi.

---

## Credenziali

| Utente  | Password    |
|---------|-------------|
| luchino | luchino123  |
| alix    | alix123     |

---

## Comandi utili

```bash
# Hot reload durante sviluppo (premi 'r' nel terminale flutter run)
flutter run

# Analisi errori
flutter analyze

# Pulire build cache
flutter clean && flutter pub get
```
