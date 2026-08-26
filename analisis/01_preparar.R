# ------------------------------------------------------------------------------
# Preparación de datos: exclusiones preregistradas, índices y libro de códigos.
#
# Uso:
#   Rscript analisis/01_preparar.R                       # usa datos simulados
#   Rscript analisis/01_preparar.R datos/respuestas.csv  # datos reales
#
# Salida: analisis/datos/preparados.rds y analisis/salida/exclusiones.csv
# ------------------------------------------------------------------------------

source("analisis/_comun.R")
suppressPackageStartupMessages({ library(dplyr) })

args <- commandArgs(trailingOnly = TRUE)
ruta <- if (length(args) >= 1) args[1] else "analisis/datos/simulados.csv"
if (!file.exists(ruta)) stop("No existe ", ruta, ". Ejecute antes 00_simular_datos.R.")

bruto <- read.csv(ruta, fileEncoding = "UTF-8", na.strings = c("", "NA"))
cabecera(paste("Datos leídos de", ruta))
cat("Filas:", nrow(bruto), "| Columnas:", ncol(bruto), "\n")

# --- Abandonos ----------------------------------------------------------------
# Se analizan como resultado antes de descartarlos: un abandono diferencial por
# condición comprometería el análisis principal (apartado 9.5 del preregistro).

parciales <- bruto |> filter(parcial == 1 | completado != 1)
cabecera("Abandono")
if (nrow(parciales)) {
  tabla_ab <- table(parciales$condicion)
  tabla_total <- table(bruto$condicion)
  cat("Tasa de abandono por condición:\n")
  print(round(100 * tabla_ab / tabla_total, 1))
  pr <- suppressWarnings(chisq.test(tabla_ab))
  cat(sprintf("\nChi cuadrado de igualdad entre condiciones: X2(%d) = %.2f, p = %.3f\n",
              pr$parameter, pr$statistic, pr$p.value))
  if (pr$p.value < .05)
    cat("AVISO: abandono diferencial por condición. Añada límites de Manski al informe.\n")
  if ("pantalla_actual" %in% names(parciales)) {
    cat("\nPantalla en la que abandonan:\n"); print(table(parciales$pantalla_actual))
  }
} else cat("Sin filas parciales.\n")

# --- Exclusiones --------------------------------------------------------------

d <- bruto |> filter(parcial == 0, completado == 1)
n0 <- nrow(d)
registro <- data.frame(criterio = character(), excluidos = integer(), quedan = integer())
aplica <- function(datos, cond, etiqueta) {
  antes <- nrow(datos)
  datos <- datos[cond, , drop = FALSE]
  registro <<- rbind(registro, data.frame(criterio = etiqueta,
                                          excluidos = antes - nrow(datos),
                                          quedan = nrow(datos)))
  datos
}

d <- aplica(d, d$consentimiento == "si" & !is.na(d$consentimiento), "sin consentimiento")
d <- aplica(d, !is.na(d$edad) & d$edad >= 18,                       "menor de 18")
d <- aplica(d, d$atencion_ok %in% c(TRUE, "TRUE", "true", 1),       "falla control de atención")
d <- aplica(d, d$duracion_s >= DURACION_MIN_S & d$duracion_s <= DURACION_MAX_S,
                                                                    "duración fuera de rango")
d <- aplica(d, is.na(d$seriedad) | d$seriedad != "no",              "declara no usar sus datos")
d <- aplica(d, is.na(d$retirar)  | d$retirar  != "si",              "retira sus datos")

cabecera("Exclusiones preregistradas")
registro <- rbind(data.frame(criterio = "completos de partida", excluidos = 0, quedan = n0),
                  registro)
print(registro, row.names = FALSE)
cat("\nRetenidos:", nrow(d), sprintf("(%.1f %%)\n", 100 * nrow(d) / n0))
escribe_csv(registro, "analisis/salida/exclusiones.csv")

# El criterio 7 (identifica la manipulación en la pregunta de sospecha) exige
# codificación manual ciega a la condición. Se deja preparado el archivo.
if ("sospecha" %in% names(d)) {
  escribe_csv(data.frame(id = d$id, sospecha = d$sospecha, codigo = NA_character_),
              "analisis/salida/sospecha_para_codificar.csv")
  cat("Escrito analisis/salida/sospecha_para_codificar.csv para codificación ciega.\n")
}

# --- Variables derivadas ------------------------------------------------------

d <- d |>
  mutate(
    condicion = factor(condicion, levels = CONDICIONES),
    conjunto  = factor(conjunto),
    rac       = as.integer(condicion != "no_racializado"),

    # Respuesta principal. La devolución se invierte para que el índice apunte
    # siempre en la dirección de más protección.
    indice_proteccion = rowMeans(cbind(proteccion, garantias, 100 - devolucion)),

    decision_devolucion = as.integer(decision == "devolucion"),
    decision_proteccion = as.integer(decision == "proteccion"),
    extranjeria = as.integer(nacionalidad_atribuida == "no"),

    sdo       = rowMeans(cbind(sdo_1, sdo_2, 100 - sdo_3, 100 - sdo_4)),
    prejuicio = rowMeans(cbind(prejuicio_1, 100 - prejuicio_2, amenaza)),
    contacto  = as.numeric(contacto),

    cambio_proteccion = proteccion_2 - proteccion,
    orden_racial = as.integer(condicion_2 != "no_racializado") - rac
  )

alfa_cronbach <- function(m) {
  m <- m[complete.cases(m), , drop = FALSE]
  k <- ncol(m)
  k / (k - 1) * (1 - sum(apply(m, 2, var)) / var(rowSums(m)))
}

cabecera("Consistencia interna")
a_prot <- alfa_cronbach(cbind(d$proteccion, d$garantias, 100 - d$devolucion))
a_sdo  <- alfa_cronbach(cbind(d$sdo_1, d$sdo_2, 100 - d$sdo_3, 100 - d$sdo_4))
a_prej <- alfa_cronbach(cbind(d$prejuicio_1, 100 - d$prejuicio_2, d$amenaza))
cat(sprintf("índice de protección (3 ítems): alfa = %.3f\n", a_prot))
cat(sprintf("dominancia social (4 ítems)   : alfa = %.3f\n", a_sdo))
cat(sprintf("prejuicio y amenaza (3 ítems) : alfa = %.3f\n", a_prej))
if (a_prot < .60)
  cat("\nAVISO: alfa < .60. El preregistro obliga a pasar a `proteccion` como\n",
      "respuesta principal y a declarar la desviación.\n", sep = "")

# --- Comprobación de la manipulación ------------------------------------------

cabecera("Comprobación de la manipulación")
if (all(!is.na(d$origen_atribuido))) {
  cat("Origen atribuido por condición (porcentaje por fila):\n")
  print(round(100 * prop.table(table(d$condicion, d$origen_atribuido), 1), 1))
  cat("\nAtribución de nacionalidad no española, por condición:\n")
  print(round(100 * tapply(d$extranjeria, d$condicion, mean, na.rm = TRUE), 1))
}

# --- Descriptivos y guardado --------------------------------------------------

cabecera("Descriptivos por condición")
resumen <- d |>
  group_by(condicion) |>
  summarise(n = n(),
            # `summarise` evalúa en orden y reutiliza lo ya creado: la DT debe
            # calcularse antes de sobrescribir la columna con su media.
            dt_indice = sd(indice_proteccion),
            media_indice = mean(indice_proteccion),
            dt_edad = sd(edad_percibida),
            media_edad = mean(edad_percibida),
            media_credibilidad = mean(credibilidad),
            media_peligro = mean(peligro),
            devolucion_pct = 100 * mean(decision_devolucion), .groups = "drop") |>
  select(condicion, n, media_indice, dt_indice, media_edad, dt_edad,
         media_credibilidad, media_peligro, devolucion_pct)
print(as.data.frame(resumen), row.names = FALSE, digits = 4)
escribe_csv(resumen, "analisis/salida/descriptivos.csv")

dir.create("analisis/datos", showWarnings = FALSE, recursive = TRUE)
saveRDS(d, "analisis/datos/preparados.rds")
cat("\nGuardado analisis/datos/preparados.rds con", nrow(d), "casos y",
    nlevels(d$conjunto), "conjuntos.\n")
