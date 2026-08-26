/* Contenido del estudio: viñeta, ítems y textos.
   Todo el texto visible para el participante vive en este archivo.
   `experimento.js` solo lo renderiza.

   Versión corta: 20 ítems, unos 3 minutos. El diseño es 2 x 2, fenotipo del
   chico por expresión de su cara, entre participantes. Cada persona ve una sola
   foto y una sola viñeta. */

window.ITEMS = {

  /* ---------------------------------------------------------------- VIÑETA */

  // Idéntica en las cuatro casillas del diseño. Ni la nacionalidad ni el origen
  // del chico se mencionan: cualquier atribución de extranjería la aporta el
  // participante.
  vinyeta: [
    "Un chico de 14 años entra solo en una comisaría en España.",
    "Dice que no quiere volver a casa. Cuenta que sus padres lo tienen desatendido, " +
    "que no come si no se busca la vida por su cuenta y que no le queda tiempo para ir al colegio."
  ],

  vinyeta_nombre: [
    "Un chico de 14 años llamado {NOMBRE} entra solo en una comisaría en España.",
    "Dice que no quiere volver a casa. Cuenta que sus padres lo tienen desatendido, " +
    "que no come si no se busca la vida por su cuenta y que no le queda tiempo para ir al colegio."
  ],

  /* ------------------------------------------- BLOQUE 0: percepción del rostro */
  /* Se responde ANTES de leer la viñeta. La edad percibida se mide aquí porque
     la viñeta declara que tiene 14 años y anclaría la estimación. La emoción
     percibida es la comprobación de la manipulación de expresión. */

  bloque0: [
    {
      id: "emocion_percibida",
      tipo: "opcion",
      enunciado: "¿Cómo se le ve?",
      opciones: [
        ["triste", "Triste"],
        ["enfadado", "Enfadado"],
        ["serio", "Serio"],
        ["contento", "Contento"],
        ["normal", "Normal, ni una cosa ni otra"]
      ]
    },
    {
      id: "edad_percibida",
      tipo: "numero",
      enunciado: "¿Qué edad dirías que tiene?",
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
    }
  ],

  /* ------------------------------------------------- BLOQUE 1: decisión (VD) */

  bloque1: [
    {
      id: "decision",
      tipo: "opcion",
      aleatorizar: true,
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
      id: "credibilidad",
      tipo: "escala",
      enunciado: "¿Cuánto te crees lo que cuenta el chico?",
      izq: "Nada", der: "Del todo"
    },
    {
      id: "peligro",
      tipo: "escala",
      enunciado: "¿Qué probabilidad hay de que haya cometido algún delito?",
      izq: "Ninguna", der: "Muy alta"
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
      id: "ccaa", tipo: "select", enunciado: "¿En qué comunidad autónoma vives?",
      opciones: ["Andalucía", "Aragón", "Asturias", "Baleares", "Canarias", "Cantabria",
                 "Castilla-La Mancha", "Castilla y León", "Cataluña", "Ceuta",
                 "Comunidad Valenciana", "Extremadura", "Galicia", "La Rioja", "Madrid",
                 "Melilla", "Murcia", "Navarra", "País Vasco", "Fuera de España"]
    },
    {
      id: "racializado", tipo: "opcion",
      enunciado: "¿Te consideras una persona racializada?",
      ayuda: "Es decir, una persona a la que en España se le atribuye habitualmente un origen no español por su aspecto.",
      opciones: [["no", "No"], ["si", "Sí"], ["nc", "Prefiero no contestar"]]
    }
  ],

  /* --------------------------------------------------- CIERRE Y CALIDAD */

  cierre: [
    {
      id: "sospecha", tipo: "texto", opcional: true,
      enunciado: "¿Qué crees que estudiaba esta encuesta?",
      ayuda: "Lo primero que se te ocurra. Puedes dejarlo en blanco."
    },
    {
      id: "seriedad", tipo: "opcion",
      enunciado: "¿Deberíamos usar tus respuestas?",
      ayuda: "Cobrarás o recibirás tu compensación igual si dices que no.",
      opciones: [["si", "Sí, he respondido con atención"],
                 ["no", "No, he respondido sin fijarme"]]
    }
  ]
};
