# Conectar el estudio con Google Sheets

Todo lo que se podía dejar hecho está hecho. Queda un paso que exige tu cuenta
de Google y no se puede automatizar: **desplegar el receptor como aplicación
web**, porque Google pide aceptar los permisos en una pantalla que solo puedes
pulsar tú.

Son cuatro minutos. Cuando termines, pásame la URL y yo hago el resto.

## 1. Abre la hoja y su editor de scripts

Hoja: **Estudio menores - respuestas**
https://docs.google.com/spreadsheets/d/19anStdR8m8QaATmn63aL7DowKZEDsTK48kZ-_1FaPyc/edit

Menú **Extensiones > Apps Script**. Se abre el editor en otra pestaña.

## 2. Pega el receptor

Borra lo que haya en `Código.gs` y pega entero este archivo:

https://raw.githubusercontent.com/anibalmastobiza/estudio-sesgo-proteccion-menores/main/apps-script/Codigo.gs

Guarda con `Cmd+S`.

## 3. Autoriza y comprueba que escribe

1. En el desplegable de funciones elige **`prueba_`** y pulsa **Ejecutar**.
2. Google pide permisos la primera vez. La ruta es:
   **Revisar permisos** > tu cuenta > **Configuración avanzada** >
   **Ir a (proyecto sin verificar)** > **Permitir**.
   El aviso de "sin verificar" es normal: es tu propio script entrando en tu
   propia hoja, no hay terceros.
3. Vuelve a la hoja. Debe aparecer una fila `PRUEBA-...`. Bórrala.

Si este paso funciona, lo demás ya está garantizado.

## 4. Despliega

**Implementar > Nueva implementación**

- Tipo: **Aplicación web** (el engranaje de la izquierda, si no aparece)
- Ejecutar como: **Yo**
- Quién tiene acceso: **Cualquier usuario**

**Implementar**, y copia la **URL de la aplicación web**. Termina en `/exec`.

## 5. Pásame esa URL

Con ella hago lo que queda, que es todo automatizable:

- ponerla en `docs/js/config.js`
- subir el número de caché de los `<script>`
- publicar el cambio
- ejecutar `apps-script/verificar.sh`, que envía una fila de prueba real
- leer la hoja y confirmar que la fila ha llegado

Si prefieres hacerlo tú, la comprobación es:

```bash
bash apps-script/verificar.sh "TU_URL_QUE_TERMINA_EN_EXEC"
```

## Si algo falla

| Síntoma | Causa casi segura |
|---|---|
| La URL abierta en el navegador no devuelve `{"ok":true...}` | La implementación no es de tipo aplicación web, o el acceso no es "cualquier usuario" |
| `prueba_` da error de permisos | Falta completar el paso 3 |
| La fila no aparece en la hoja | El script se creó vinculado a otra hoja. Comprueba que abriste el editor desde esta |
| Cambias el código y no surte efecto | Apps Script no actualiza el despliegue al guardar: **Implementar > Gestionar implementaciones > lápiz > Versión: Nueva versión > Implementar**. La URL no cambia |

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
