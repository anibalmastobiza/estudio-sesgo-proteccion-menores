# Conectar el estudio con Google Sheets

Cinco minutos. Todo se hace desde tu cuenta de Google y no hace falta ninguna
clave de API. El único paso que no se puede automatizar es el 4: desplegar un
Web App exige aceptar permisos en tu propia cuenta, de forma interactiva.

## 1. La hoja ya existe

Está creada en tu Drive, con las 71 columnas del protocolo en la primera fila:

**Estudio menores - respuestas**
https://docs.google.com/spreadsheets/d/12VMUIHyxaWxFSjC7PpG9IhvWL3CJda6IVC0l-4p_h-E/edit

Sirve igual cualquier hoja vacía: el receptor crea la pestaña `respuestas` y las
cabeceras la primera vez que recibe algo, y si el libro tiene una sola pestaña la
reutiliza y la renombra.

## 2. Pega el receptor

1. En la hoja: **Extensiones > Apps Script**.
2. Borra el contenido de `Código.gs` y pega entero [`Codigo.gs`](Codigo.gs).
3. Si quieres protegerlo de envíos ajenos, cambia la primera línea:
   ```javascript
   var TOKEN = "una-cadena-larga-y-aleatoria";
   ```
   Genera una con:
   ```bash
   openssl rand -hex 24
   ```
4. Guarda con `Cmd+S`.

## 3. Comprueba que escribe

1. En el desplegable de funciones del editor, elige `prueba_` y pulsa **Ejecutar**.
2. Google pedirá permisos la primera vez: **Revisar permisos**, tu cuenta,
   **Configuración avanzada**, **Ir a (proyecto sin verificar)**, **Permitir**.
   Es tu propio script accediendo a tu propia hoja.
3. Vuelve a la hoja. Debe aparecer una fila `PRUEBA-...` en la pestaña
   `respuestas`. Bórrala.

## 4. Despliega

1. **Implementar > Nueva implementación**.
2. Tipo: **Aplicación web**.
3. Ejecutar como: **Yo**.
4. Quién tiene acceso: **Cualquier usuario**.
5. **Implementar**, y copia la **URL de la aplicación web**. Termina en `/exec`.

## 5. Verifica la sincronización de punta a punta

Desde la raíz del repositorio:

```bash
bash apps-script/verificar.sh "PEGA_AQUI_LA_URL_QUE_TERMINA_EN_EXEC"
```

Si pusiste token, añádelo como segundo argumento. El script consulta el
servicio, envía una fila de prueba y vuelve a consultarlo. Termina con
`SINCRONIZACION CORRECTA` si todo está bien, y con un mensaje concreto si no.
Borra la fila `PRUEBA-...` antes de recoger datos reales.

## 6. Conecta el experimento

En [`docs/js/config.js`](../docs/js/config.js):

```javascript
ENDPOINT: "https://script.google.com/macros/s/AKfy.../exec",
TOKEN: "la-misma-cadena-que-pusiste-en-Codigo.gs",
```

Sube además el número de `?v=` en las etiquetas `<script>` de
[`docs/index.html`](../docs/index.html), para que a nadie le sirva el navegador
la configuración anterior desde la caché.

En cuanto `ENDPOINT` deje de estar vacío, desaparece solo el aviso de versión de
prueba que hoy muestra la portada.

## 7. Cada vez que cambies el script

Apps Script **no** actualiza el despliegue al guardar. Hay que ir a
**Implementar > Gestionar implementaciones**, el lápiz, **Versión: Nueva
versión**, **Implementar**. La URL no cambia.

## Notas de funcionamiento

- **Una fila por participante.** El campo `id` es un UUID generado en el
  navegador. Si alguien abandona a mitad se guarda una fila con `parcial = 1`;
  si luego termina, esa misma fila se sobrescribe. Así se puede calcular el
  abandono por condición sin duplicar casos.
- **CORS.** El experimento envía con `Content-Type: text/plain` a propósito:
  evita la petición previa que Apps Script no responde. No lo cambies a
  `application/json`.
- **Estudio normativo.** `docs/norming.html` usa el mismo endpoint y escribe en
  una pestaña aparte, `norming`, en formato largo.
- **Sin identificadores personales.** El receptor no registra IP ni correo, y
  Apps Script no se los pasa al script cuando el acceso es público.
- **Exportar.** Menú `Estudio > Exportar CSV a Drive` en la propia hoja, o
  `analisis/descargar_sheets.R` si prefieres publicarla como CSV.
- **Respaldo.** Duplica la hoja una vez por semana durante la recogida.
