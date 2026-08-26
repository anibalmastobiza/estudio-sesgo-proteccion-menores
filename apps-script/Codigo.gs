/**
 * Receptor de respuestas del estudio -> Google Sheets.
 *
 * Se despliega como aplicación web (Implementar > Nueva implementación >
 * Aplicación web), ejecutándose "como yo" y con acceso "cualquier usuario".
 * Ver INSTALACION.md.
 *
 * Cada participante ocupa una sola fila. Los envíos parciales (abandonos) se
 * escriben igual y se sobrescriben si la persona termina, de modo que la hoja
 * permite calcular tasas de abandono por condición sin duplicar casos.
 */

// Debe coincidir con CONFIG.TOKEN en docs/js/config.js. Cadena vacía = sin comprobación.
var TOKEN = "";

var HOJA = "respuestas";

// Orden canónico de columnas. Las claves no listadas se añaden al final.
var CABECERAS = [
  "id", "recibido_iso", "parcial", "completado", "abandonos", "pantalla_actual",
  "version_protocolo", "version_estimulos", "variante",
  "condicion", "condicion_2", "conjunto", "estimulo_1", "estimulo_2", "nombre_1", "nombre_2",
  "consentimiento",
  "edad_percibida", "origen_atribuido", "nacionalidad_atribuida",
  "decision", "orden_decision", "proteccion", "devolucion", "garantias",
  "credibilidad", "responsabilidad", "peligro", "dias_evaluacion",
  "control_atencion", "atencion_ok",
  "proteccion_2", "devolucion_2", "cambio_declarado",
  "ideologia", "contacto",
  "sdo_1", "sdo_2", "sdo_3", "sdo_4",
  "prejuicio_1", "prejuicio_2", "amenaza",
  "edad", "genero", "estudios", "ccaa", "origen_propio", "racializado", "voto",
  "sospecha", "seriedad", "retirar",
  "inicio_iso", "fin_iso", "fin_debriefing_iso", "duracion_s",
  "t_portada", "t_instrucciones", "t_rostro", "t_caso", "t_atencion",
  "t_revelacion", "t_moderadores", "t_demografia", "t_cierre",
  "zona_horaria", "idioma_navegador", "pantalla", "tactil", "fuente"
];

function doPost(e) {
  var lock = LockService.getScriptLock();
  try {
    lock.waitLock(30000);

    var cuerpo = JSON.parse(e.postData.contents);
    if (TOKEN && cuerpo.token !== TOKEN) return respuesta_({ ok: false, error: "token" });

    if (cuerpo.tipo === "norming") return norming_(cuerpo);

    var d = cuerpo.datos || {};
    if (!d.id) return respuesta_({ ok: false, error: "sin id" });

    d.recibido_iso = new Date().toISOString();
    d.parcial = cuerpo.parcial ? 1 : 0;

    var hoja = hoja_();
    var cabeceras = cabeceras_(hoja, d);
    var fila = cabeceras.map(function (k) {
      var v = d[k];
      if (v === undefined || v === null) return "";
      if (typeof v === "boolean") return v ? 1 : 0;
      return v;
    });

    var existente = buscarFila_(hoja, d.id);
    if (existente > 0) hoja.getRange(existente, 1, 1, fila.length).setValues([fila]);
    else hoja.appendRow(fila);

    return respuesta_({ ok: true, id: d.id, fila: existente > 0 ? existente : hoja.getLastRow() });

  } catch (err) {
    registrarError_(err, e);
    return respuesta_({ ok: false, error: String(err) });
  } finally {
    try { lock.releaseLock(); } catch (x) {}
  }
}

function doGet() {
  return respuesta_({ ok: true, servicio: "estudio-sesgo-proteccion-menores", filas: hoja_().getLastRow() - 1 });
}

/* ------------------------------------------------------------- internas */

function hoja_() {
  var libro = SpreadsheetApp.getActiveSpreadsheet();
  var h = libro.getSheetByName(HOJA);
  if (!h) {
    h = libro.insertSheet(HOJA);
    h.appendRow(CABECERAS);
    h.setFrozenRows(1);
  }
  return h;
}

function cabeceras_(hoja, d) {
  var actuales = hoja.getRange(1, 1, 1, Math.max(1, hoja.getLastColumn())).getValues()[0]
                     .filter(function (x) { return x !== ""; });
  if (!actuales.length) { hoja.getRange(1, 1, 1, CABECERAS.length).setValues([CABECERAS]); actuales = CABECERAS.slice(); }

  var nuevas = Object.keys(d).filter(function (k) { return actuales.indexOf(k) === -1; });
  if (nuevas.length) {
    hoja.getRange(1, actuales.length + 1, 1, nuevas.length).setValues([nuevas]);
    actuales = actuales.concat(nuevas);
  }
  return actuales;
}

function buscarFila_(hoja, id) {
  var n = hoja.getLastRow();
  if (n < 2) return 0;
  var ids = hoja.getRange(2, 1, n - 1, 1).getValues();
  for (var i = 0; i < ids.length; i++) if (ids[i][0] === id) return i + 2;
  return 0;
}

/**
 * Estudio normativo: formato largo, una fila por (juez x imagen).
 */
function norming_(cuerpo) {
  var libro = SpreadsheetApp.getActiveSpreadsheet();
  var h = libro.getSheetByName("norming");
  var cab = ["juez", "recibido_iso", "version_estimulos", "conjunto", "condicion", "ruta", "orden", "ms",
             "origen", "prototipicidad", "edad", "atractivo", "confiabilidad", "expresion", "realismo",
             "edad_juez", "genero_juez", "racializado_juez"];
  if (!h) { h = libro.insertSheet("norming"); h.appendRow(cab); h.setFrozenRows(1); }

  var j = cuerpo.juez || {}, ahora = new Date().toISOString();
  var filas = (cuerpo.valoraciones || []).map(function (v) {
    v.recibido_iso = ahora;
    v.version_estimulos = j.version_estimulos;
    v.edad_juez = j.edad_juez; v.genero_juez = j.genero_juez; v.racializado_juez = j.racializado_juez;
    return cab.map(function (k) { return (v[k] === undefined || v[k] === null) ? "" : v[k]; });
  });
  if (filas.length) h.getRange(h.getLastRow() + 1, 1, filas.length, cab.length).setValues(filas);
  return respuesta_({ ok: true, filas: filas.length });
}

function respuesta_(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj))
                       .setMimeType(ContentService.MimeType.JSON);
}

function registrarError_(err, e) {
  try {
    var libro = SpreadsheetApp.getActiveSpreadsheet();
    var h = libro.getSheetByName("errores") || libro.insertSheet("errores");
    if (h.getLastRow() === 0) h.appendRow(["momento", "error", "cuerpo"]);
    h.appendRow([new Date(), String(err), e && e.postData ? e.postData.contents.slice(0, 4000) : ""]);
  } catch (x) {}
}

/* ---------------------------------------------------------- utilidades */

/** Ejecutar a mano desde el editor para comprobar que escribe. */
function prueba_() {
  var falso = {
    postData: {
      contents: JSON.stringify({
        token: TOKEN, parcial: false,
        datos: { id: "PRUEBA-" + Date.now(), condicion: "magrebi", condicion_2: "no_racializado",
                 conjunto: "C01", proteccion: 88, devolucion: 12, completado: true }
      })
    }
  };
  Logger.log(doPost(falso).getContent());
}

/** Menú para exportar CSV listo para analisis/01_preparar.R */
function onOpen() {
  SpreadsheetApp.getUi().createMenu("Estudio")
    .addItem("Exportar CSV a Drive", "exportarCSV")
    .addToUi();
}

function exportarCSV() {
  var hoja = hoja_();
  var datos = hoja.getDataRange().getValues();
  var csv = datos.map(function (fila) {
    return fila.map(function (c) {
      var s = String(c === null || c === undefined ? "" : c);
      return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
    }).join(",");
  }).join("\n");
  var nombre = "respuestas_" + Utilities.formatDate(new Date(), "Europe/Madrid", "yyyy-MM-dd_HHmm") + ".csv";
  var archivo = DriveApp.createFile(nombre, csv, MimeType.CSV);
  SpreadsheetApp.getUi().alert("Exportado: " + nombre + "\n" + archivo.getUrl());
}
