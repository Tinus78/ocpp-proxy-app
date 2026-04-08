# ocpp-proxy-app
Home assistant ocpp proxy app for Home Assistant
# OCPP Proxy — Home Assistant Add-on Handleiding

Deze handleiding beschrijft hoe je de [joulo-ocpp-proxy](https://github.com/joulo-nl/joulo-ocpp-proxy) installeert als lokale custom add-on in Home Assistant OS.

De proxy zit tussen je EV-laadpaal en je CSMS (Charge Point Management System) in, en kan het verkeer optioneel ook naar meerdere backends spiegelen.

---

## Vereisten

- **Home Assistant OS** of **Home Assistant Supervised**
- De **SSH** of **Samba** add-on geïnstalleerd, om bestanden op je HA systeem te kunnen plaatsen
- Een werkende CSMS met een WebSocket URL (bijv. `wss://jouw-csms.example.com/ocpp`)

---

## Stap 1 — Mappenstructuur aanmaken

Maak via SSH of Samba de volgende map aan op je Home Assistant systeem:

```
/addons/ocpp-proxy/
```

De uiteindelijke structuur ziet er zo uit:

```
/addons/
  ocpp-proxy/
    config.yaml
    Dockerfile
    run.sh
```

---

## Stap 2 — Bestanden aanmaken

Maak de volgende drie bestanden aan in de map `/addons/ocpp-proxy/`.

### `config.yaml`

Beschrijft de add-on aan Home Assistant.

```yaml
name: "OCPP Proxy"
description: "Joulo OCPP WebSocket proxy – stuurt laadpaalverkeer door naar een of meerdere CSMS backends."
version: "1.0.0"
slug: "ocpp_proxy"
init: false
homeassistant_api: false
auth_api: false

arch:
  - aarch64
  - amd64
  - armv7
  - armhf
  - i386

ports:
  9000/tcp: 9000
ports_description:
  9000/tcp: "OCPP WebSocket poort voor laadpalen"

options:
  primary_csms_url: "wss://jouw-csms.example.com/ocpp"
  secondary_csms_urls: ""
  log_level: "info"

schema:
  primary_csms_url: str
  secondary_csms_urls: str
  log_level: list(debug|info|warn|error)
```

---

### `Dockerfile`

Gebruikt de officiële joulo-ocpp-proxy image en voegt het opstartscript toe.

```dockerfile
ARG BUILD_FROM
FROM ghcr.io/joulo-nl/joulo-ocpp-proxy:main

USER root
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/bin/sh"]
CMD ["/run.sh"]
```

> **Let op:** `USER root` is nodig omdat de originele image als non-root gebruiker draait. Het `ENTRYPOINT` wordt overschreven zodat ons eigen opstartscript gebruikt wordt.

---

### `run.sh`

Leest de configuratie uit Home Assistant en start de proxy.

```sh
#!/bin/sh

# Home Assistant slaat add-on configuratie op in /data/options.json
OPTIONS_FILE="/data/options.json"

if [ ! -f "$OPTIONS_FILE" ]; then
  echo "FOUT: $OPTIONS_FILE niet gevonden"
  exit 1
fi

# Lees waarden uit options.json met behulp van node (al aanwezig in de image)
PRIMARY_CSMS_URL=$(node -e "const o=require('$OPTIONS_FILE');process.stdout.write(o.primary_csms_url||'')")
SECONDARY_CSMS_URLS=$(node -e "const o=require('$OPTIONS_FILE');process.stdout.write(o.secondary_csms_urls||'')")
LOG_LEVEL=$(node -e "const o=require('$OPTIONS_FILE');process.stdout.write(o.log_level||'info')")

echo "OCPP Proxy starten..."
echo "Primaire CSMS: ${PRIMARY_CSMS_URL}"

if [ -n "${SECONDARY_CSMS_URLS}" ]; then
  echo "Secundaire CSMS: ${SECONDARY_CSMS_URLS}"
fi

exec env \
  PRIMARY_CSMS_URL="${PRIMARY_CSMS_URL}" \
  SECONDARY_CSMS_URLS="${SECONDARY_CSMS_URLS}" \
  LOG_LEVEL="${LOG_LEVEL}" \
  PORT=9000 \
  node /app/dist/index.js
```

> **Let op:** Dit script gebruikt geen `bashio`, omdat dat niet beschikbaar is in de Node.js-gebaseerde image. De configuratie wordt rechtstreeks uit `/data/options.json` gelezen via `node`.

---

## Stap 3 — Add-on installeren in Home Assistant

1. Ga naar **Instellingen → Add-ons**
2. Klik rechtsboven op het **⋮ menu**
3. Kies **"Check for updates"** of **"Zoek naar lokale add-ons"**
4. De **OCPP Proxy** verschijnt nu in de lijst onder "Lokale add-ons"
5. Klik op de add-on en kies **Installeren**

---

## Stap 4 — Configureren

Ga naar het tabblad **Configuratie** van de add-on en vul in:

| Instelling | Beschrijving | Voorbeeld |
|---|---|---|
| `primary_csms_url` | WebSocket URL van je primaire CSMS | `wss://csms.example.com/ocpp` |
| `secondary_csms_urls` | Optioneel: kommagescheiden lijst van secundaire CSMS URLs | `wss://analytics.example.com/ocpp` |
| `log_level` | Logniveau | `info` |

Sla op en start de add-on.

---

## Stap 5 — Laadpaal instellen

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
