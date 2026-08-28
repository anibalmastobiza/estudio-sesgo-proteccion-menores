/* Motor del experimento. No depende de librerías externas.
   Toda la aleatorización ocurre en el navegador del participante y queda
   registrada en el propio envío. */

(function () {
  "use strict";

  var C = window.CONFIG, I = window.ITEMS;
  var app = document.getElementById("app");

  /* ------------------------------------------------------------ utilidades */

  function uuid() {
    if (window.crypto && crypto.randomUUID) return crypto.randomUUID();
    return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function (c) {
      var r = (Math.random() * 16) | 0;
      return (c === "x" ? r : (r & 0x3) | 0x8).toString(16);
    });
  }
  function barajar(a) {
    a = a.slice();
    for (var i = a.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      var t = a[i]; a[i] = a[j]; a[j] = t;
    }
    return a;
  }
  function elegir(a) { return a[Math.floor(Math.random() * a.length)]; }
  function esc(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
  }
  function $(sel, raiz) { return (raiz || document).querySelector(sel); }
  function $$(sel, raiz) { return Array.prototype.slice.call((raiz || document).querySelectorAll(sel)); }

  /* ------------------------------------------------------------- estado */

  var D = {                       // se envía tal cual
    id: uuid(),
    version_protocolo: C.VERSION_PROTOCOLO,
    variante: C.VARIANTE,
    inicio_iso: new Date().toISOString(),
    zona_horaria: (Intl.DateTimeFormat().resolvedOptions().timeZone || ""),
    idioma_navegador: navigator.language || "",
    pantalla: window.screen.width + "x" + window.screen.height,
    tactil: ("ontouchstart" in window),
    fuente: new URLSearchParams(location.search).get("fuente") || "",
    completado: false,
    abandonos: 0
  };

  var manifiesto = null;
  var paso = 0, listaPantallas = [], tPantalla = 0;

  /* ------------------------------------------------- asignación aleatoria */

  function asignar() {
    // Diseño 2 x 2 entre participantes: fenotipo por expresión. Cada persona ve
    // UNA sola cara. Las cuatro casillas se sortean con igual probabilidad, y la
    // cara concreta se sortea dentro de la casilla.
    var condiciones = (C.VARIANTE === "foto" && manifiesto.condiciones)
      ? manifiesto.condiciones : C.CONDICIONES;

    D.condicion = elegir(condiciones);

    if (C.VARIANTE === "foto") {
      D.version_estimulos = manifiesto.version;
      D.expresion = elegir(manifiesto.expresiones);
      var pool = manifiesto.caras[D.condicion][D.expresion];
      D.estimulo_1 = elegir(pool);
      D.cara = D.estimulo_1.split("/").pop().replace(/\.[a-z]+$/, "");
      D.conjunto = D.cara;
      D.codigo_expresion = D.cara.split("_")[3];
    } else {
      var k = Math.floor(Math.random() * C.NOMBRES[D.condicion].length);
      D.conjunto = "N" + (k + 1);
      D.cara = D.conjunto;
      D.nombre_1 = C.NOMBRES[D.condicion][k];
      D.expresion = "";
      D.version_estimulos = "nombres-1.0";
    }
  }

  /* ------------------------------------------------------- componentes */

  function pintaEstimulo() {
    if (C.VARIANTE !== "foto") return "";
    return '<figure class="estimulo"><img src="' + esc(C.RUTA_ESTIMULOS + D.estimulo_1) +
           '" alt="Fotografía de un chico adolescente"></figure>';
  }

  function textoVinyeta() {
    var base = (C.VARIANTE === "nombre") ? I.vinyeta_nombre : I.vinyeta;
    return base.map(function (p) {
      return "<p>" + esc(p).replace("{NOMBRE}", "<strong>" + esc(D.nombre_1) + "</strong>") + "</p>";
    }).join("");
  }

  function htmlItem(it) {
    var h = '<div class="item" data-id="' + it.id + '" data-tipo="' + it.tipo +
            '" data-opcional="' + (it.opcional ? "1" : "0") + '">';
    h += '<p class="enunciado">' + esc(it.enunciado) + "</p>";
    if (it.ayuda) h += '<p class="ayuda">' + esc(it.ayuda) + "</p>";

    if (it.tipo === "escala") {
      var max = it.max || 100, paso_ = it.paso || 1;
      h += '<div class="escala">' +
           '<input type="range" min="0" max="' + max + '" step="' + paso_ +
           '" value="' + Math.round(max / 2) + '" class="sin-tocar" aria-label="' +
           esc(it.enunciado) + '">' +
           '<div class="anclas"><span>' + esc(it.izq) + "</span><span>" + esc(it.der) + "</span></div>" +
           '<output class="valor">Sin marcar</output></div>';

    } else if (it.tipo === "opcion") {
      var ops = it.aleatorizar ? barajar(it.opciones) : it.opciones;
      if (it.aleatorizar) D["orden_" + it.id] = ops.map(function (o) { return o[0]; }).join("|");
      h += '<div class="opciones">';
      ops.forEach(function (o) {
        h += '<label class="opcion"><input type="radio" name="' + it.id + '" value="' +
             esc(o[0]) + '"><span>' + esc(o[1]) + "</span></label>";
      });
      h += "</div>";

    } else if (it.tipo === "numero") {
      h += '<div class="numero"><input type="number" inputmode="numeric" min="' + it.min +
           '" max="' + it.max + '"><span class="sufijo">' + esc(it.sufijo || "") + "</span></div>";

    } else if (it.tipo === "select") {
      h += '<select><option value="">Selecciona…</option>';
      it.opciones.forEach(function (o) { h += '<option value="' + esc(o) + '">' + esc(o) + "</option>"; });
      h += "</select>";

    } else if (it.tipo === "texto") {
      h += '<textarea rows="3" maxlength="500"></textarea>';
    }
    return h + '<p class="aviso" hidden>Contesta para poder seguir.</p></div>';
  }

  function activarEscalas(raiz) {
    $$(".escala input[type=range]", raiz).forEach(function (r) {
      var salida = $(".valor", r.parentNode);
      r.addEventListener("input", function () {
        r.classList.remove("sin-tocar");
        salida.textContent = r.value;
      });
    });
  }

  function recoger(raiz) {
    var faltan = [];
    $$(".item", raiz).forEach(function (nodo) {
      var id = nodo.dataset.id, tipo = nodo.dataset.tipo, opcional = nodo.dataset.opcional === "1", v = null;

      if (tipo === "escala") {
        var r = $("input[type=range]", nodo);
        v = r.classList.contains("sin-tocar") ? null : Number(r.value);
      } else if (tipo === "opcion") {
        var m = $("input[type=radio]:checked", nodo);
        v = m ? m.value : null;
      } else if (tipo === "numero") {
        var n = $("input[type=number]", nodo);
        v = n.value === "" ? null : Number(n.value);
        if (v !== null && (v < Number(n.min) || v > Number(n.max))) v = null;
      } else if (tipo === "select") {
        var s = $("select", nodo); v = s.value || null;
      } else if (tipo === "texto") {
        var t = $("textarea", nodo); v = t.value.trim();
        if (v === "") v = null;
      }

      var vacio = (v === null);
      var aviso = $(".aviso", nodo);
      if (aviso) aviso.hidden = !(vacio && !opcional);
      nodo.classList.toggle("falta", vacio && !opcional);
      if (vacio && !opcional) faltan.push(id); else D[id] = v;
    });
    return faltan;
  }

  /* --------------------------------------------------------- pantallas */

  function mostrar(html, nombre) {
    app.innerHTML = html;
    var primeraEscala = $('.item[data-tipo="escala"]', app);
    if (primeraEscala) {
      var instruccion = document.createElement("p");
      instruccion.className = "instruccion-escalas";
      instruccion.textContent = "Pulsa o toca una posición en cada barra gris. Aparecerá un punto azul.";
      primeraEscala.parentNode.insertBefore(instruccion, primeraEscala);
    }
    app.scrollIntoView({ block: "start" });
    window.scrollTo(0, 0);
    activarEscalas(app);
    tPantalla = performance.now();
    D.pantalla_actual = nombre;
    if (C.MODO_DEPURACION) {
      var d = document.createElement("p");
      d.className = "depuracion";
      d.textContent = "[depuración] condición: " + D.condicion + " · alternativa: " +
                      D.condicion_2 + " · conjunto: " + D.conjunto;
      app.appendChild(d);
    }
  }

  function botonSiguiente(txt) {
    return '<button id="siguiente" class="principal">' + esc(txt || "Continuar") + "</button>";
  }

  function alSiguiente(nombre, fn) {
    var b = $("#siguiente");
    if (!b) return;
    b.addEventListener("click", function () {
      var faltan = recoger(app);
      if (faltan.length) { $(".falta").scrollIntoView({ behavior: "smooth", block: "center" }); return; }
      D["t_" + nombre] = Math.round(performance.now() - tPantalla);
      fn();
    });
  }

  /* 1. portada, información y consentimiento */
  function pPortada() {
    mostrar(
      '<h1>¿Cambia la decisión si cambia la cara?</h1>' +
      '<p class="entradilla">Un estudio de la ' + esc(C.INSTITUCION) + ' sobre cómo ' +
      'decidimos qué hacer cuando un menor pide ayuda. Dura unos <strong>3 minutos</strong>.</p>' +
      '<div class="ficha">' +
        '<h2>Antes de empezar</h2>' +
        '<ul>' +
          '<li><strong>Qué vas a hacer.</strong> Leerás un caso breve y darás tu opinión sobre qué debería pasar. Después responderás unas preguntas sobre ti.</li>' +
          '<li><strong>Anonimato.</strong> No pedimos tu nombre, tu correo ni tu IP. No podremos identificarte.</li>' +
          '<li><strong>Voluntario.</strong> Puedes cerrar la pestaña en cualquier momento sin dar explicaciones y sin consecuencias.</li>' +
          '<li><strong>Datos.</strong> Se guardan en una hoja de cálculo con acceso restringido al equipo investigador y se publicarán en abierto de forma agregada y anónima.</li>' +
          '<li><strong>Aviso.</strong> Este estudio no te dice desde el principio qué compara exactamente. Al final te lo explicamos entero y podrás retirar tus respuestas.</li>' +
          '<li><strong>Edad.</strong> Solo pueden participar personas mayores de 18 años.</li>' +
          '<li><strong>Quién lo hace.</strong> ' + esc(C.INVESTIGADOR) + ', ' +
            esc(C.INSTITUCION) + '. Puedes escribir a <a href="mailto:' +
            esc(C.CONTACTO) + '">' + esc(C.CONTACTO) + '</a> para cualquier duda.</li>' +
          (C.REF_ETICA
            ? '<li><strong>Ética.</strong> Estudio aprobado por el comité de ética con la ' +
              'referencia ' + esc(C.REF_ETICA) + '.</li>'
            : '') +
        "</ul>" +
      "</div>" +
      '<div class="item" data-id="consentimiento" data-tipo="opcion" data-opcional="0">' +
        '<p class="enunciado">¿Quieres participar?</p>' +
        '<div class="opciones">' +
          '<label class="opcion"><input type="radio" name="consentimiento" value="si">' +
          "<span>Sí. Tengo 18 años o más, he leído lo anterior y acepto participar.</span></label>" +
        "</div><p class=\"aviso\" hidden>Contesta para poder seguir.</p></div>" +
      botonSiguiente("Empezar"),
      "portada");
    alSiguiente("portada", pInstrucciones);
  }

  /* 2. instrucciones */
  function pInstrucciones() {
    var txt = (C.VARIANTE === "foto")
      ? "En la pantalla siguiente verás la foto de un chico. Míralo unos segundos y responde tres preguntas rápidas. Después te contaremos qué le pasa."
      : "En la pantalla siguiente leerás un caso breve. Contesta con lo que te parezca, no hay respuestas correctas.";
    mostrar('<h2>Cómo funciona</h2><p class="entradilla">' + esc(txt) + "</p>" +
            '<p>No hay respuestas correctas ni incorrectas. Nos interesa lo que te parece a ti.</p>' +
            botonSiguiente(), "instrucciones");
    alSiguiente("instrucciones", pRostro);
  }

  /* 3. bloque 0: percepción del estímulo (antes de la viñeta) */
  function pRostro() {
    if (C.VARIANTE !== "foto") { pCaso(); return; }
    mostrar('<h2>Este es el chico</h2>' + pintaEstimulo() +
            I.bloque0.map(htmlItem).join("") + botonSiguiente(), "rostro");
    bloquearBoton(C.EXPOSICION_MINIMA_S);
    alSiguiente("rostro", pCaso);
  }

  function bloquearBoton(segundos) {
    var b = $("#siguiente");
    if (!b || !segundos) return;
    b.disabled = true;
    var t0 = Date.now(), etiqueta = b.textContent;
    b.textContent = etiqueta + " (" + segundos + ")";
    var iv = setInterval(function () {
      var restan = Math.ceil(segundos - (Date.now() - t0) / 1000);
      if (restan <= 0) { clearInterval(iv); b.disabled = false; b.textContent = etiqueta; }
      else b.textContent = etiqueta + " (" + restan + ")";
    }, 200);
  }

  /* 4. bloque 1: el caso y la decisión */
  function pCaso() {
    mostrar('<h2>El caso</h2>' + pintaEstimulo() +
            '<div class="vinyeta">' + textoVinyeta() + "</div>" +
            I.bloque1.map(htmlItem).join("") + botonSiguiente(), "caso");
    alSiguiente("caso", pAtencion);
  }

  /* 5. control de atención */
  function pAtencion() {
    mostrar("<h2>Una comprobación</h2>" + htmlItem(I.atencion) + botonSiguiente(), "atencion");
    alSiguiente("atencion", function () {
      D.atencion_ok = (D.control_atencion === I.atencion.correcta);
      pModeradores();
    });
  }

  /* 6. moderadores */
  function pModeradores() {
    mostrar("<h2>Y ahora, sobre ti</h2>" +
            I.moderadores.map(htmlItem).join("") + botonSiguiente(), "moderadores");
    alSiguiente("moderadores", pDemografia);
  }

  /* 7. demografía */
  function pDemografia() {
    mostrar("<h2>Casi está</h2>" + I.demografia.map(htmlItem).join("") +
            botonSiguiente(), "demografia");
    alSiguiente("demografia", pCierre);
  }

  /* 8. cierre y control de calidad */
  function pCierre() {
    mostrar("<h2>Dos últimas</h2>" + I.cierre.map(htmlItem).join("") +
            botonSiguiente("Terminar"), "cierre");
    alSiguiente("cierre", function () {
      D.completado = true;
      D.fin_iso = new Date().toISOString();
      D.duracion_s = Math.round((new Date(D.fin_iso) - new Date(D.inicio_iso)) / 1000);
      enviar(false);
      pDebriefing();
    });
  }

  /* 9. debriefing */
  function pDebriefing() {
    var comparadas = { no_racializado: "un chico blanco",
                       magrebi: "un chico de aspecto magrebí",
                       subsahariano: "un chico negro" };
    var comparadasN = { no_racializado: "un nombre español",
                        magrebi: "un nombre magrebí",
                        subsahariano: "un nombre del África occidental" };
    var expr = { afligido: "con cara de disgusto", contento: "sonriendo" };
    var mio = (C.VARIANTE === "foto" ? comparadas : comparadasN)[D.condicion] +
              (C.VARIANTE === "foto" && expr[D.expresion] ? ", " + expr[D.expresion] : "");

    mostrar("<h1>Gracias. Esto es lo que estudiábamos</h1>" +
      '<div class="ficha">' +
      "<p>El caso que has leído es <strong>exactamente el mismo</strong> para todo el mundo: " +
      "las mismas palabras, la misma situación, la misma edad. Lo único que cambiaba entre participantes " +
      "era " + (C.VARIANTE === "foto" ? "la foto del chico: su aspecto y su cara" : "el nombre del chico") +
      ". A ti te tocó " + esc(mio) + ".</p>" +
      "<p>Hay cuatro grupos: chico blanco o chico negro, y cara de disgusto o cara contenta. " +
      "Comparando los cuatro podemos separar tres cosas que suelen ir mezcladas: cuánto pesa el " +
      "aspecto del chico, cuánto pesa la cara que pone, y si una cosa depende de la otra. " +
      "No te lo dijimos antes porque saberlo habría cambiado tus respuestas.</p>" +
      "<p>Que tus respuestas vayan en una dirección u otra no dice nada sobre ti como persona: " +
      "el estudio no evalúa a nadie individualmente, solo compara promedios de grupos grandes.</p>" +
      "<p><strong>Qué dice la investigación previa.</strong> Estudios en Estados Unidos han encontrado " +
      "que a los niños negros se les atribuye más edad y menos inocencia que a los blancos de la misma edad " +
      "(Goff y cols., 2014, <em>Journal of Personality and Social Psychology</em>), y que las caras de niños " +
      "negros de cinco años ya facilitan la identificación de estímulos amenazantes (Todd, Thiem y Neel, 2016, " +
      "<em>Psychological Science</em>). Este estudio pregunta si algo equivalente ocurre en España con los " +
      "menores migrantes, y si llega hasta la decisión de protegerlos o devolverlos.</p>" +
      "<p><strong>Marco legal.</strong> En España, la Ley Orgánica 1/1996 de Protección Jurídica del Menor " +
      "obliga a actuar en interés superior del menor con independencia de su nacionalidad.</p>" +
      "</div>" +
      '<div class="item" data-id="retirar" data-tipo="opcion" data-opcional="1">' +
        '<p class="enunciado">Ahora que lo sabes, ¿quieres que borremos tus respuestas?</p>' +
        '<div class="opciones">' +
          '<label class="opcion"><input type="radio" name="retirar" value="no"><span>No, podéis usarlas</span></label>' +
          '<label class="opcion"><input type="radio" name="retirar" value="si"><span>Sí, borradlas</span></label>' +
        '</div><p class="aviso" hidden>Contesta para poder seguir.</p></div>' +
      '<button id="siguiente" class="principal">Enviar y cerrar</button>' +
      '<p id="estado" class="estado"></p>', "debriefing");

    $("#siguiente").addEventListener("click", function () {
      recoger(app);
      D.fin_debriefing_iso = new Date().toISOString();
      enviar(false);
      mostrar("<h1>Listo</h1><p class=\"entradilla\">Gracias por participar. Ya puedes cerrar la pestaña.</p>" +
              "<p>Si quieres los resultados cuando estén publicados, escribe a " +
              '<a href="mailto:' + esc(C.CONTACTO) + '">' + esc(C.CONTACTO) + "</a>.</p>" +
              "<p>" + esc(C.INVESTIGADOR) + ", " + esc(C.INSTITUCION) + ".</p>", "final");
    });
  }

  /* ------------------------------------------------------------- envío */

  function enviar(parcial) {
    if (C.GUARDAR_LOCAL) {
      try { localStorage.setItem("respuesta_" + D.id, JSON.stringify(D)); } catch (e) {}
    }
    if (!C.ENDPOINT) {
      if (C.MODO_DEPURACION) console.log("[sin ENDPOINT] datos:", D);
      return;
    }
    var cuerpo = JSON.stringify({ token: C.TOKEN, parcial: !!parcial, datos: D });
    // text/plain evita la petición previa CORS contra Apps Script.
    fetch(C.ENDPOINT, {
      method: "POST",
      headers: { "Content-Type": "text/plain;charset=utf-8" },
      body: cuerpo,
      keepalive: true
    }).then(function (r) { return r.text(); })
      .then(function () {
        try { localStorage.removeItem("respuesta_" + D.id); } catch (e) {}
        var e2 = $("#estado"); if (e2) e2.textContent = "Respuestas guardadas.";
      })
      .catch(function () {
        if (navigator.sendBeacon) navigator.sendBeacon(C.ENDPOINT, new Blob([cuerpo], { type: "text/plain" }));
        var e3 = $("#estado"); if (e3) e3.textContent = "No hemos podido confirmar el guardado. Tus respuestas se reintentarán.";
      });
  }

  // Registro de abandonos: envío parcial si la persona se va a mitad.
  window.addEventListener("pagehide", function () {
    if (D.completado || !C.ENDPOINT || !D.condicion) return;
    D.abandonos = 1;
    D.fin_iso = new Date().toISOString();
    var cuerpo = JSON.stringify({ token: C.TOKEN, parcial: true, datos: D });
    if (navigator.sendBeacon) navigator.sendBeacon(C.ENDPOINT, new Blob([cuerpo], { type: "text/plain" }));
  });

  /* ------------------------------------------------------------- arranque */

  function arrancar() {
    asignar();
    pPortada();
  }

  if (C.VARIANTE === "foto") {
    fetch(C.MANIFIESTO)
      .then(function (r) { return r.json(); })
      .then(function (j) {
        manifiesto = j;
        // En estructura anidada, `caras[condicion]` es un objeto indexado por
        // código de expresión. No sirve si falta algún código en alguna
        // condición: la aplicación no podría emparejar la expresión.
        var vacio;
        if (manifiesto.estructura === "anidada") {
          vacio = !manifiesto.caras || !manifiesto.condiciones;
          if (!vacio) {
            var cods0 = Object.keys(manifiesto.caras[manifiesto.condiciones[0]] || {});
            vacio = !cods0.length || manifiesto.condiciones.some(function (c) {
              var pe = manifiesto.caras[c];
              return !pe || cods0.some(function (e) { return !pe[e] || !pe[e].length; });
            });
          }
        } else {
          vacio = !manifiesto.conjuntos || !manifiesto.conjuntos.length;
        }
        if ((/^0\.0-marcadores/.test(manifiesto.version) || vacio) && !C.MODO_DEPURACION) {
          app.innerHTML = "<h1>Estímulos sin instalar</h1><p>El manifiesto todavía apunta a " +
            "marcadores de posición, no a estímulos reales. Sustituye las imágenes de " +
            "<code>docs/estimulos/</code>, actualiza <code>version</code> en " +
            "<code>manifiesto.json</code>, o pon <code>VARIANTE: \"nombre\"</code> en " +
            "<code>config.js</code>. Para probar la aplicación con marcadores, activa " +
            "<code>MODO_DEPURACION</code>.</p>";
          return;
        }
        arrancar();
      })
      .catch(function () {
        app.innerHTML = "<h1>Error de configuración</h1><p>No se ha podido cargar " +
          esc(C.MANIFIESTO) + ". Revisa <code>docs/estimulos/</code> o cambia " +
          "<code>VARIANTE</code> a <code>\"nombre\"</code> en <code>config.js</code>.</p>";
      });
  } else {
    arrancar();
  }
})();
