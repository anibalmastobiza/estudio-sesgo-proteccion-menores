/* Configuración del estudio. Editar antes de publicar. */
window.CONFIG = {

  // URL del Web App de Google Apps Script (apps-script/INSTALACION.md).
  // Mientras esté vacía, el experimento funciona pero no envía nada.
  ENDPOINT: "",

  // Debe coincidir con TOKEN en Codigo.gs. Vacío = sin comprobación.
  TOKEN: "",

  // "foto"   : la manipulación es la imagen del menor (diseño principal).
  // "nombre" : la manipulación es el nombre propio del menor (variante ejecutable
  //            sin estímulos visuales; se preregistra por separado).
  VARIANTE: "nombre",

  // Condiciones. El orden fija los niveles del factor en el análisis.
  CONDICIONES: ["no_racializado", "magrebi", "subsahariano"],

  // Nombres usados en VARIANTE = "nombre".
  NOMBRES: {
    no_racializado: ["Javier", "Sergio", "Iván", "Rubén", "Álvaro", "Marcos"],
    magrebi:        ["Youssef", "Bilal", "Anas", "Hamza", "Ayoub", "Mehdi"],
    subsahariano:   ["Ibrahima", "Mamadou", "Cheikh", "Ousmane", "Moussa", "Abdoulaye"]
  },

  RUTA_ESTIMULOS: "estimulos/",
  MANIFIESTO: "estimulos/manifiesto.json",

  // Bloque 2: réplica intrasujeto con la cara alternativa (lógica del hilo original).
  BLOQUE_REVELACION: true,

  // Segundos mínimos de exposición al estímulo antes de poder avanzar.
  EXPOSICION_MINIMA_S: 3,

  // Guardar copia en localStorage y reintentar el envío si falla la red.
  GUARDAR_LOCAL: true,

  // true = muestra la condición asignada en pantalla. Solo para pruebas.
  MODO_DEPURACION: false,

  // Al cambiar cualquier cosa de este archivo o de items.js, suba el número de
  // `?v=` en las etiquetas <script> de index.html y norming.html. Sin eso, los
  // navegadores que ya hayan visitado la página pueden seguir con la versión
  // anterior durante el tiempo de caché.
  VERSION_PROTOCOLO: "1.0.0"
};
