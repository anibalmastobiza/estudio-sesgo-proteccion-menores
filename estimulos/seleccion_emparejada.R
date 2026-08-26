# ------------------------------------------------------------------------------
# Selección de conjuntos de estímulo a partir del estudio normativo.
#
# Aplica los cuatro criterios preregistrados y devuelve la lista de conjuntos
# que entran en el estudio principal. Se ejecuta UNA vez, se guarda su salida y
# se deposita como enmienda al preregistro antes de abrir el campo.
#
# Entrada: CSV en formato largo con una fila por (juez x imagen), tal como lo
# exporta la pestaña `norming` de la hoja de cálculo. Columnas necesarias:
#   conjunto, condicion, origen, prototipicidad, edad, atractivo,
#   confiabilidad, expresion, realismo
#
# Uso:
#   Rscript estimulos/seleccion_emparejada.R datos/norming.csv
#   Rscript estimulos/seleccion_emparejada.R SIMULAR      # prueba del pipeline
# ------------------------------------------------------------------------------

suppressPackageStartupMessages({ library(dplyr); library(tidyr) })

# --- Criterios preregistrados -------------------------------------------------
ACUERDO_MIN        <- 0.70   # proporción de jueces que acierta el origen
DIF_EDAD_MAX       <- 1.0    # años, entre versiones del mismo conjunto
DIF_ATRACTIVO_MAX  <- 8      # puntos sobre 100
DIF_CONFIANZA_MAX  <- 8      # puntos sobre 100
NEUTRA_MIN         <- 0.80   # proporción que codifica la expresión como neutra

ORIGEN_ESPERADO <- list(
  no_racializado = c("espana", "europa"),
  magrebi        = c("magreb"),
  subsahariano   = c("africa_sub")
)

# --- Datos --------------------------------------------------------------------

simula_norming <- function(n_conjuntos = 20, n_jueces_img = 45, semilla = 20260826) {
  set.seed(semilla)
  conds <- names(ORIGEN_ESPERADO)
  expand.grid(conjunto = sprintf("C%03d", seq_len(n_conjuntos)),
              condicion = conds, juez = seq_len(n_jueces_img),
              stringsAsFactors = FALSE) |>
    mutate(
      # Cada conjunto tiene su propia calidad: algunos serán rechazados.
      calidad = as.numeric(factor(conjunto)) %% 4,
      acierta = runif(n()) < ifelse(calidad == 0, 0.55, 0.88),
      origen = ifelse(acierta,
                      sapply(condicion, function(c) ORIGEN_ESPERADO[[c]][1]),
                      sample(c("latam", "otro", "nose"), n(), TRUE)),
      prototipicidad = pmin(100, pmax(0, rnorm(n(), 65, 15))),
      # Desajuste de edad deliberado en los conjuntos de calidad 1.
      edad = rnorm(n(), 14.5 + ifelse(calidad == 1 & condicion != "no_racializado", 1.8, 0), 1.6),
      atractivo = rnorm(n(), 50 + ifelse(calidad == 2 & condicion == "magrebi", 12, 0), 18),
      confiabilidad = rnorm(n(), 55, 18),
      expresion = ifelse(runif(n()) < ifelse(calidad == 3, 0.55, 0.92), "neutra",
                         sample(c("serio", "contento", "triste"), n(), TRUE)),
      realismo = pmin(100, pmax(0, rnorm(n(), 62, 20)))
    ) |>
    select(-calidad, -acierta)
}

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) stop("Indique el CSV de norming, o SIMULAR.")

if (args[1] == "SIMULAR") {
  cat("MODO SIMULACIÓN. Datos inventados para comprobar el pipeline.\n\n")
  bruto <- simula_norming()
} else {
  bruto <- read.csv(args[1], stringsAsFactors = FALSE, fileEncoding = "UTF-8")
}

necesarias <- c("conjunto", "condicion", "origen", "edad", "atractivo",
                "confiabilidad", "expresion")
faltan <- setdiff(necesarias, names(bruto))
if (length(faltan)) stop("Faltan columnas: ", paste(faltan, collapse = ", "))

# --- Agregado por imagen ------------------------------------------------------

por_imagen <- bruto |>
  group_by(conjunto, condicion) |>
  summarise(
    n_jueces      = n(),
    acuerdo       = mean(origen %in% ORIGEN_ESPERADO[[first(condicion)]]),
    edad_M        = mean(edad),
    edad_DT       = sd(edad),
    atractivo_M   = mean(atractivo),
    atractivo_DT  = sd(atractivo),
    confianza_M   = mean(confiabilidad),
    confianza_DT  = sd(confiabilidad),
    neutra        = mean(expresion == "neutra"),
    realismo_M    = if ("realismo" %in% names(bruto)) mean(realismo) else NA_real_,
    prototip_M    = if ("prototipicidad" %in% names(bruto)) mean(prototipicidad) else NA_real_,
    .groups = "drop"
  )

# --- Criterios por conjunto ---------------------------------------------------

por_conjunto <- por_imagen |>
  group_by(conjunto) |>
  summarise(
    n_versiones = n(),
    acuerdo_min = min(acuerdo),
    dif_edad    = max(edad_M) - min(edad_M),
    dif_atract  = max(atractivo_M) - min(atractivo_M),
    dif_confia  = max(confianza_M) - min(confianza_M),
    neutra_min  = min(neutra),
    realismo_min = min(realismo_M),
    # Error tipico de una diferencia entre dos versiones. Sirve para saber si
    # el criterio se decide por informacion o por ruido de muestreo.
    et_dif_edad   = sqrt(2) * sqrt(mean(edad_DT^2) / mean(n_jueces)),
    et_dif_atract = sqrt(2) * sqrt(mean(atractivo_DT^2) / mean(n_jueces)),
    et_dif_confia = sqrt(2) * sqrt(mean(confianza_DT^2) / mean(n_jueces)),
    .groups = "drop"
  ) |>
  mutate(
    c1_origen    = acuerdo_min >= ACUERDO_MIN,
    c2_edad      = dif_edad    <= DIF_EDAD_MAX,
    c3_apariencia = dif_atract <= DIF_ATRACTIVO_MAX & dif_confia <= DIF_CONFIANZA_MAX,
    c4_expresion = neutra_min  >= NEUTRA_MIN,
    completo     = n_versiones == length(ORIGEN_ESPERADO),
    admitido     = completo & c1_origen & c2_edad & c3_apariencia & c4_expresion,
    # Decision fragil: la diferencia observada esta a menos de un error tipico
    # del umbral, de modo que otro grupo de jueces podria invertirla.
    frontera     = abs(dif_edad   - DIF_EDAD_MAX)      < et_dif_edad |
                   abs(dif_atract - DIF_ATRACTIVO_MAX) < et_dif_atract |
                   abs(dif_confia - DIF_CONFIANZA_MAX) < et_dif_confia
  )

# --- Salida -------------------------------------------------------------------

cat("Conjuntos evaluados:", nrow(por_conjunto), "\n")
cat("Motivos de exclusión (un conjunto puede fallar varios criterios):\n")
cat("  origen no reconocido       :", sum(!por_conjunto$c1_origen), "\n")
cat("  edad percibida desigual    :", sum(!por_conjunto$c2_edad), "\n")
cat("  atractivo o confianza desiguales:", sum(!por_conjunto$c3_apariencia), "\n")
cat("  expresión no neutra        :", sum(!por_conjunto$c4_expresion), "\n")
cat("  versiones incompletas      :", sum(!por_conjunto$completo), "\n\n")

cat("Precisión del estudio normativo\n")
cat("  jueces por imagen (mediana):", median(por_imagen$n_jueces), "\n")
cat("  error típico de una diferencia, atractivo:",
    round(median(por_conjunto$et_dif_atract), 2), "puntos\n")
cat("  error típico de una diferencia, edad     :",
    round(median(por_conjunto$et_dif_edad), 2), "años\n")
cat("  conjuntos en zona de frontera            :", sum(por_conjunto$frontera), "\n")
if (median(por_conjunto$et_dif_atract) > DIF_ATRACTIVO_MAX / 4) {
  cat("  AVISO: el error típico supera un cuarto del umbral. Con esta precisión\n")
  cat("  el criterio de apariencia se decide en buena parte por ruido. Suba el\n")
  cat("  número de jueces por imagen o acepte el emparejamiento estadístico\n")
  cat("  posterior (normas como covariable en el modelo principal).\n")
}
cat("\n")

admitidos <- por_conjunto$conjunto[por_conjunto$admitido]
cat("ADMITIDOS:", length(admitidos), "\n")
cat(paste(admitidos, collapse = ", "), "\n\n")

if (length(admitidos) < 12) {
  cat("AVISO: el preregistro exige un mínimo de 12 conjuntos.\n")
  cat("Con menos, la simulación de potencia deja de sostener el diseño.\n")
  cat("Genere y normativice más candidatos antes de abrir el campo.\n\n")
}

dir.create("estimulos/salida", showWarnings = FALSE, recursive = TRUE)
write.csv(por_imagen,   "estimulos/salida/normas_por_imagen.csv",   row.names = FALSE)
write.csv(por_conjunto, "estimulos/salida/criterios_por_conjunto.csv", row.names = FALSE)

# Manifiesto listo para copiar a docs/estimulos/ tras revisar la lista.
manif <- paste0(
  '{\n  "version": "1.0-', format(Sys.Date(), "%Y%m%d"), '",\n',
  '  "condiciones": ["no_racializado", "magrebi", "subsahariano"],\n',
  '  "n_conjuntos": ', length(admitidos), ',\n',
  '  "conjuntos": [\n',
  paste(sprintf(
    '    {"id": "%s", "imagenes": {"no_racializado": "%s_no_racializado.png", "magrebi": "%s_magrebi.png", "subsahariano": "%s_subsahariano.png"}}',
    admitidos, admitidos, admitidos, admitidos), collapse = ",\n"),
  '\n  ]\n}\n')
writeLines(manif, "estimulos/salida/manifiesto_propuesto.json")

cat("Escrito en estimulos/salida/:\n")
cat("  normas_por_imagen.csv\n  criterios_por_conjunto.csv\n  manifiesto_propuesto.json\n")
cat("\nRevise la lista a ojo antes de copiar el manifiesto a docs/estimulos/.\n")
