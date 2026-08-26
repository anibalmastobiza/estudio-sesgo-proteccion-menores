#!/usr/bin/env bash
# Comprueba de punta a punta que la aplicación puede escribir en Google Sheets.
#
#   bash apps-script/verificar.sh "https://script.google.com/macros/s/AKfy.../exec" [TOKEN]
#
# Envía una fila de prueba con id PRUEBA-<fecha>. Si aparece en la hoja, la
# sincronización funciona. Borre esa fila antes de abrir el campo.

set -uo pipefail

URL="${1:-}"
TOKEN="${2:-}"

if [ -z "$URL" ]; then
  echo "Uso: bash apps-script/verificar.sh <URL_DEL_WEB_APP> [TOKEN]" >&2
  exit 2
fi

echo "1. Comprobando que el servicio responde"
GET=$(curl -sL --max-time 30 "$URL")
echo "   $GET"
case "$GET" in
  *'"ok":true'*) : ;;
  *) echo "   FALLO: el Web App no responde como se espera." >&2
     echo "   Revise que la implementación sea de tipo aplicación web, que se ejecute" >&2
     echo "   'como yo' y que el acceso sea 'cualquier usuario'." >&2
     exit 1 ;;
esac

ID="PRUEBA-$(date +%Y%m%d-%H%M%S)"
echo "2. Enviando una fila de prueba con id $ID"
CUERPO=$(cat <<JSON
{"token":"$TOKEN","parcial":false,"datos":{
  "id":"$ID","variante":"foto","condicion":"no_racializado","condicion_2":"subsahariano",
  "conjunto":"w_b_15_f_002","estimulo_1":"aifaces/w_b_15_f_002.png",
  "consentimiento":"si","edad_percibida":15,"origen_atribuido":"espana",
  "nacionalidad_atribuida":"si","decision":"proteccion","proteccion":88,"devolucion":12,
  "garantias":95,"credibilidad":70,"responsabilidad":10,"peligro":15,"dias_evaluacion":14,
  "control_atencion":"4","atencion_ok":true,"seriedad":"si","retirar":"no",
  "completado":true,"duracion_s":300,"fuente":"verificacion"}}
JSON
)
POST=$(curl -sL --max-time 30 -X POST -H "Content-Type: text/plain;charset=utf-8" \
             --data "$CUERPO" "$URL")
echo "   $POST"

case "$POST" in
  *'"ok":true'*) ;;
  *'"error":"token"'*)
     echo "   FALLO: token incorrecto. El segundo argumento debe coincidir con TOKEN en Codigo.gs." >&2
     exit 1 ;;
  *) echo "   FALLO: la escritura no se ha confirmado." >&2; exit 1 ;;
esac

echo "3. Releyendo el servicio"
FIN=$(curl -sL --max-time 30 "$URL")
echo "   $FIN"

echo
echo "SINCRONIZACION CORRECTA."
echo "Abra la hoja y compruebe la fila $ID. Bórrela antes de recoger datos reales."
echo
echo "Siguiente paso: pegue la URL en docs/js/config.js"
echo "  ENDPOINT: \"$URL\","
if [ -n "$TOKEN" ]; then echo "  TOKEN: \"$TOKEN\","; fi
echo "y suba el numero de ?v= en las etiquetas <script> de docs/index.html."
