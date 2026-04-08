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
