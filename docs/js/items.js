/* Contenido del estudio: viñeta, ítems y textos.
   Todo el texto visible para el participante vive en este archivo.
   `experimento.js` solo lo renderiza. El libro de códigos de `analisis/`
   se genera a partir de estas claves. */

window.ITEMS = {

  /* ---------------------------------------------------------------- VIÑETA */

  // Idéntica en las tres condiciones. Ni la nacionalidad ni el origen del chico
  // se mencionan en ningún momento: cualquier atribución de extranjería la
  // aporta el participante.
  vinyeta: [
    "Un chico de 14 años entra solo en una comisaría en España.",
    "Dice que no quiere volver a casa. Cuenta que sus padres lo tienen desatendido, " +
    "que no come si no se busca la vida por su cuenta y que no le queda tiempo para ir al colegio."
  ],

  // Variante "nombre": misma viñeta con el nombre insertado.
  vinyeta_nombre: [
    "Un chico de 14 años llamado {NOMBRE} entra solo en una comisaría en España.",
    "Dice que no quiere volver a casa. Cuenta que sus padres lo tienen desatendido, " +
    "que no come si no se busca la vida por su cuenta y que no le queda tiempo para ir al colegio."
  ],

  /* ------------------------------------------- BLOQUE 0: percepción del rostro */
  /* Se responde ANTES de leer la viñeta. La edad percibida se mide aquí porque
     la viñeta declara que tiene 14 años y contaminaría la estimación. */

  bloque0: [
    {
      id: "edad_percibida",
      tipo: "numero",
      enunciado: "¿Qué edad dirías que tiene?",
      ayuda: "Escribe una cifra en años.",
      min: 6, max: 30, sufijo: "años"
    },
    {
      id: "origen_atribuido",
      tipo: "opcion",
      enunciado: "¿De dónde dirías que es?",
      opciones: [
        ["espana", "De España"],
        ["europa", "De otro país de Europa"],
        ["magreb", "De Marruecos o del norte de África"],
        ["africa_sub", "Del África subsahariana"],
        ["latam", "De América Latina"],
        ["otro", "De otro sitio"],
        ["nose", "No sabría decirlo"]
      ]
    },
    {
      id: "nacionalidad_atribuida",
      tipo: "opcion",
      enunciado: "¿Crees que tiene nacionalidad española?",
      opciones: [["si", "Sí"], ["no", "No"], ["nose", "No lo sé"]]
    }
  ],

  /* ------------------------------------------------- BLOQUE 1: decisión (VD) */

  bloque1: [
    {
      id: "decision",
      tipo: "opcion",
      aleatorizar: true,          // se baraja el orden de las opciones
      enunciado: "¿Qué debería hacer la policía esta misma noche?",
      opciones: [
        ["casa",       "Llevarlo de vuelta a su casa"],
        ["proteccion", "Avisar a servicios sociales y darle plaza en un centro de acogida"],
        ["comisaria",  "Retenerlo en comisaría hasta identificarlo"],
        ["devolucion", "Iniciar su devolución al país de origen de su familia"]
      ]
    },
    {
      id: "proteccion",
      tipo: "escala",
      enunciado: "Debe abrirse un expediente de protección y pasar la noche en un centro de acogida.",
      izq: "Totalmente en desacuerdo", der: "Totalmente de acuerdo"
    },
    {
      id: "devolucion",
      tipo: "escala",
      enunciado: "Debe devolverse al chico con su familia lo antes posible.",
      izq: "Totalmente en desacuerdo", der: "Totalmente de acuerdo"
    },
    {
      id: "garantias",
      tipo: "escala",
      enunciado: "Antes de devolverlo, hay que comprobar su identidad y en qué condiciones va a vivir.",
      izq: "Totalmente en desacuerdo", der: "Totalmente de acuerdo"
    },
    {
      id: "credibilidad",
      tipo: "escala",
      enunciado: "¿Cuánto te crees lo que cuenta el chico?",
      izq: "Nada", der: "Del todo"
    },
    {
      id: "responsabilidad",
      tipo: "escala",
      enunciado: "¿Hasta qué punto es él responsable de su situación?",
      izq: "Nada responsable", der: "Totalmente responsable"
    },
    {
      id: "peligro",
      tipo: "escala",
      enunciado: "¿Qué probabilidad hay de que haya cometido algún delito?",
      izq: "Ninguna", der: "Muy alta"
    },
    {
      id: "dias_evaluacion",
      tipo: "numero",
      enunciado: "¿Cuántos días debería durar la evaluación de su caso antes de tomar una decisión?",
      ayuda: "Escribe un número de días, de 0 a 90.",
      min: 0, max: 90, sufijo: "días"
    }
  ],

  /* ------------------------------------- BLOQUE 2: revelación (intrasujeto) */

  revelacion_intro: "Ahora imagina exactamente el mismo caso, con las mismas palabras, " +
                    "pero el chico que entra en la comisaría es este otro.",
  revelacion_intro_nombre: "Ahora imagina exactamente el mismo caso, con las mismas palabras, " +
                    "pero el chico que entra en la comisaría se llama {NOMBRE}.",

  bloque2: [
    {
      id: "proteccion_2",
      tipo: "escala",
      enunciado: "Debe abrirse un expediente de protección y pasar la noche en un centro de acogida.",
      izq: "Totalmente en desacuerdo", der: "Totalmente de acuerdo"
    },
    {
      id: "devolucion_2",
      tipo: "escala",
      enunciado: "Debe devolverse al chico con su familia lo antes posible.",
      izq: "Totalmente en desacuerdo", der: "Totalmente de acuerdo"
    },
    {
      id: "cambio_declarado",
      tipo: "opcion",
      enunciado: "¿Cambiarías algo de lo que has respondido antes?",
      opciones: [["nada", "No, nada"], ["poco", "Sí, un poco"], ["bastante", "Sí, bastante"]]
    }
  ],

  /* -------------------------------------------------------- ATENCIÓN */

  atencion: {
    id: "control_atencion",
    tipo: "opcion",
    enunciado: "Esta pregunta comprueba que lees los enunciados. Marca “Bastante en desacuerdo”.",
    opciones: [
      ["1", "Totalmente de acuerdo"],
      ["2", "Bastante de acuerdo"],
      ["3", "Ni de acuerdo ni en desacuerdo"],
      ["4", "Bastante en desacuerdo"],
      ["5", "Totalmente en desacuerdo"]
    ],
    correcta: "4"
  },

  /* ----------------------------------------------------- MODERADORES */

  moderadores: [
    {
      id: "ideologia",
      tipo: "escala",
      enunciado: "En política, ¿dónde te situarías?",
      izq: "Izquierda", der: "Derecha", max: 10, paso: 1
    },
    {
      id: "contacto",
      tipo: "opcion",
      enunciado: "¿Con qué frecuencia tratas con personas de origen migrante?",
      opciones: [
        ["1", "Nunca"], ["2", "Casi nunca"], ["3", "A veces"],
        ["4", "A menudo"], ["5", "A diario"]
      ]
    },
    {
      id: "sdo_1",
      tipo: "escala", grupo: "sdo",
      enunciado: "Hay grupos de personas que simplemente valen menos que otros.",
      izq: "Totalmente en desacuerdo", der: "Totalmente de acuerdo"
    },
    {
      id: "sdo_2",
      tipo: "escala", grupo: "sdo",
      enunciado: "No pasa nada porque unos grupos tengan más oportunidades en la vida que otros.",
      izq: "Totalmente en desacuerdo", der: "Totalmente de acuerdo"
    },
    {
      id: "sdo_3",
      tipo: "escala", grupo: "sdo", invertido: true,
      enunciado: "Deberíamos esforzarnos por igualar las condiciones de todos los grupos.",
      izq: "Totalmente en desacuerdo", der: "Totalmente de acuerdo"
    },
    {
      id: "sdo_4",
      tipo: "escala", grupo: "sdo", invertido: true,
      enunciado: "Ningún grupo debería dominar en la sociedad.",
      izq: "Totalmente en desacuerdo", der: "Totalmente de acuerdo"
    },
    {
      id: "prejuicio_1",
      tipo: "escala", grupo: "prejuicio",
      enunciado: "Los menores migrantes que llegan solos reciben más ayudas de las que les corresponden.",
      izq: "Totalmente en desacuerdo", der: "Totalmente de acuerdo"
    },
    {
      id: "prejuicio_2",
      tipo: "escala", grupo: "prejuicio", invertido: true,
      enunciado: "Me parecería bien que abrieran un centro de menores migrantes en mi barrio.",
      izq: "Totalmente en desacuerdo", der: "Totalmente de acuerdo"
    },
    {
      id: "amenaza",
      tipo: "escala", grupo: "prejuicio",
      enunciado: "La llegada de menores migrantes no acompañados es un problema para España.",
      izq: "Totalmente en desacuerdo", der: "Totalmente de acuerdo"
    }
  ],

  /* ----------------------------------------------------- DEMOGRAFÍA */

  demografia: [
    { id: "edad", tipo: "numero", enunciado: "¿Cuántos años tienes?", min: 18, max: 99, sufijo: "años" },
    {
      id: "genero", tipo: "opcion", enunciado: "¿Cuál es tu género?",
      opciones: [["mujer", "Mujer"], ["hombre", "Hombre"], ["nb", "No binario"],
                 ["nc", "Prefiero no contestar"]]
    },
    {
      id: "estudios", tipo: "opcion", enunciado: "¿Cuál es tu nivel de estudios terminado?",
      opciones: [["primaria", "Primaria o menos"], ["secundaria", "Secundaria o FP básica"],
                 ["bachiller_fp", "Bachillerato o FP superior"], ["universidad", "Universidad"],
                 ["posgrado", "Máster o doctorado"]]
    },
    {
      id: "ccaa", tipo: "select", enunciado: "¿En qué comunidad autónoma vives?",
      opciones: ["Andalucía", "Aragón", "Asturias", "Baleares", "Canarias", "Cantabria",
                 "Castilla-La Mancha", "Castilla y León", "Cataluña", "Ceuta",
                 "Comunidad Valenciana", "Extremadura", "Galicia", "La Rioja", "Madrid",
                 "Melilla", "Murcia", "Navarra", "País Vasco", "Fuera de España"]
    },
    {
      id: "origen_propio", tipo: "opcion",
      enunciado: "¿Naciste tú, o alguno de tus padres, fuera de España?",
      opciones: [["no", "No"], ["padres", "Sí, alguno de mis padres"], ["yo", "Sí, yo"],
                 ["nc", "Prefiero no contestar"]]
    },
    {
      id: "racializado", tipo: "opcion",
      enunciado: "¿Te consideras una persona racializada?",
      ayuda: "Es decir, una persona a la que en España se le atribuye habitualmente un origen no español por su aspecto.",
      opciones: [["no", "No"], ["si", "Sí"], ["nc", "Prefiero no contestar"]]
    },
    {
      id: "voto", tipo: "select", opcional: true,
      enunciado: "¿A qué partido votaste en las últimas elecciones generales?",
      ayuda: "Puedes dejarlo en blanco.",
      opciones: ["PSOE", "PP", "Vox", "Sumar", "Podemos", "ERC", "Junts", "EH Bildu",
                 "PNV", "Otro partido", "En blanco o nulo", "No voté", "Prefiero no contestar"]
    }
  ],

  /* --------------------------------------------------- CIERRE Y CALIDAD */

  cierre: [
    {
      id: "sospecha", tipo: "texto", opcional: true,
      enunciado: "¿Qué crees que estudiaba esta encuesta?",
      ayuda: "Responde con lo primero que se te ocurra. Puedes dejarlo en blanco."
    },
    {
      id: "seriedad", tipo: "opcion",
      enunciado: "Última pregunta, y no tiene consecuencias para ti: ¿deberíamos usar tus respuestas?",
      ayuda: "Cobrarás o recibirás tu compensación igual si dices que no.",
      opciones: [["si", "Sí, he respondido con atención"],
                 ["no", "No, he respondido sin fijarme"]]
    }
  ]
};
