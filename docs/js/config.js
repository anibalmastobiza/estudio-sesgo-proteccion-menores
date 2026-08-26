/* Configuración del estudio. Editar antes de publicar. */
window.CONFIG = {

  // Quién firma el estudio. Aparece en la portada y en el debriefing.
  INVESTIGADOR: "Aníbal Astobiza",
  INSTITUCION:  "Universidad de Granada",
  CONTACTO:     "amastobiza@ugr.es",

  // Referencia del comité de ética. Mientras esté vacía, la portada NO afirma
  // que el estudio esté aprobado: decirlo sin serlo sería falso.
  REF_ETICA: "",

  // URL del Web App de Google Apps Script (apps-script/INSTALACION.md).
  // Mientras esté vacía, el experimento funciona pero no envía nada.
  ENDPOINT: "https://script.google.com/macros/s/AKfycbyzrBifkVB_PfuYn40iVPWOp4Fj0J6QSOpigUTmZt5Eg1Koi-7iYS98sGVM0M2ruBKJ/exec",

  // Debe coincidir con TOKEN en Codigo.gs. Vacío = sin comprobación.
  TOKEN: "",

  // "foto"   : diseño 2 x 2, fenotipo del menor por expresión de su cara.
  // "nombre" : la manipulación es el nombre propio del menor (variante ejecutable
  //            sin estímulos visuales; se preregistra por separado).
  VARIANTE: "foto",

  // Condiciones de la variante "nombre". En variante "foto" mandan las que
  // declare docs/estimulos/manifiesto.json, que hoy son dos: no hay estímulos
  // fotográficos válidos para la condición magrebí (ver estimulos/README.md).
  CONDICIONES: ["no_racializado", "magrebi", "subsahariano"],

  // Nombres usados en VARIANTE = "nombre".
  NOMBRES: {
    no_racializado: ["Javier", "Sergio", "Iván", "Rubén", "Álvaro", "Marcos"],
    magrebi:        ["Youssef", "Bilal", "Anas", "Hamza", "Ayoub", "Mehdi"],
    subsahariano:   ["Ibrahima", "Mamadou", "Cheikh", "Ousmane", "Moussa", "Abdoulaye"]
  },

  RUTA_ESTIMULOS: "estimulos/",
  MANIFIESTO: "estimulos/manifiesto.json",

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
  VERSION_PROTOCOLO: "2.0.0"
};
