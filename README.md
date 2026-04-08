# ocpp-proxy-app
Home assistant ocpp proxy app for Home Assistant
# OCPP Proxy — Home Assistant Add-on Handleiding

De proxy zit tussen je EV-laadpaal en je CSMS (Charge Point Management System) in, en kan het verkeer optioneel ook naar meerdere backends spiegelen.

---

## Vereisten

- **Home Assistant OS** of **Home Assistant Supervised**
- Een werkende CSMS met een WebSocket URL (bijv. `wss://jouw-csms.example.com/ocpp`)

---

## Stap 1 — Add-on installeren in Home Assistant

1. Ga naar **Instellingen → Add-ons**
2. Klik rechtsboven op het **⋮ menu**
3. Kies **"Check for updates"** of **"Zoek naar lokale add-ons"**
4. De **OCPP Proxy** verschijnt nu in de lijst onder "Lokale add-ons"
5. Klik op de add-on en kies **Installeren**

---

## Stap 2 — Configureren

Ga naar het tabblad **Configuratie** van de add-on en vul in:

| Instelling | Beschrijving | Voorbeeld |
|---|---|---|
| `primary_csms_url` | WebSocket URL van je primaire CSMS | `wss://csms.example.com/ocpp` |
| `secondary_csms_urls` | Optioneel: kommagescheiden lijst van secundaire CSMS URLs | `wss://analytics.example.com/ocpp` |
| `log_level` | Logniveau | `info` |

Sla op en start de add-on.

---

## Stap 3 — Laadpaal instellen

Verander in de instellingen van je laadpaal de OCPP backend URL:

```
Vóór:  wss://jouw-csms.example.com/ocpp/LAADPAAL-001
Na:    ws://homeassistant.local:9000/LAADPAAL-001
```

De proxy voegt het laadpaal-ID automatisch toe aan de upstream CSMS URL's. De volgende URL-patronen worden herkend:

```
ws://proxy:9000/LAADPAAL-001
ws://proxy:9000/ocpp/LAADPAAL-001
ws://proxy:9000/ws/LAADPAAL-001
```

---

## Architectuur

```
Laadpaal  ←→  OCPP Proxy (HA)  ←→  Primaire CSMS  (volledig bidirectioneel)
                    ↓
              Secundaire CSMS  (alleen lezen, gespiegeld)
```

| Richting | Primaire CSMS | Secundaire CSMS |
|---|---|---|
| Laadpaal → CSMS | ✅ Doorgestuurd | ✅ Gespiegeld |
| CSMS → Laadpaal | ✅ Doorgestuurd | ❌ Genegeerd |

---

## Logs bekijken

Ga in Home Assistant naar de add-on en klik op het tabblad **Logboek**. Zet `log_level` op `debug` om alle individuele OCPP berichten te zien.

---

## Bronnen

- GitHub: [joulo-nl/joulo-ocpp-proxy](https://github.com/joulo-nl/joulo-ocpp-proxy)
- Docker image: `ghcr.io/joulo-nl/joulo-ocpp-proxy:main`
- Gemaakt door [Joulo](https://joulo.nl) — Nederlands platform voor slim thuisladen
