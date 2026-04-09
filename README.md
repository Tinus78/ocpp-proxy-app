# ocpp-proxy-app
Home assistant ocpp proxy app for Home Assistant
<Dutch version below> 

OCPP Proxy — Home Assistant Add-on Guide
The proxy sits between your EV charger and your CSMS (Charge Point Management System), and can optionally mirror traffic to multiple backends.
Requirements

Home Assistant OS or Home Assistant Supervised
A working CSMS with a WebSocket URL (e.g. wss://your-csms.example.com/ocpp)

**Step 1 — Install the Add-on in Home Assistant**

1. Go to Settings → Add-ons
2. Click the ⋮ menu in the top right
3. Choose "Repositories"
4. Add the following URL: https://github.com/Tinus78/ocpp-proxy-app/
5. Click on the add-on and choose Install

**Step 2 — Configure**
1. Go to the Configuration tab of the add-on and fill in:
    Setting | Description | Example
    primary_csms_url | WebSocket URL of your primary CSMS | wss://csms.example.com/ocpp
    secondary_csms_urls | Optional: comma-separated list of secondary CSMS URLs | wss://analytics.example.com/ocpp
    log_level | Log level | info
2. Save and start the add-on.

**Step 3 — Configure your charger**
1. Change the OCPP backend URL in your charger's settings:
  Before:  wss://your-csms.example.com/ocpp/CHARGER-001
  After:   ws://homeassistant.local:9000/CHARGER-001
2. The proxy automatically appends the charge point ID to the upstream CSMS URLs. The following URL patterns are recognized:
  ws://proxy:9000/CHARGER-001
  ws://proxy:9000/ocpp/CHARGER-001
  ws://proxy:9000/ws/CHARGER-001


**Architecture**
Charger  ←→  OCPP Proxy (HA)  ←→  Primary CSMS  (fully bidirectional)
                   ↓
             Secondary CSMS  (read-only, mirrored)
             
Direction | Primary CSMS | Secondary CSMS
Charger → CSMS | ✅ Forwarded | ✅ Mirrored
CSMS → Charger | ✅ Forwarded | ❌ Ignored

**Viewing Logs**
**Go to the add-on in Home Assistant and click the Log tab. Set log_level to debug to see all individual OCPP messages.
Sources

GitHub: joulo-nl/joulo-ocpp-proxy
Docker image: ghcr.io/joulo-nl/joulo-ocpp-proxy:main
Created by Joulo — Dutch platform for smart home charging

<Dutch version>

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
3. Kies **"repositories"**
4. Voeg de volgende URL toe: "https://github.com/Tinus78/ocpp-proxy-app/"
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
