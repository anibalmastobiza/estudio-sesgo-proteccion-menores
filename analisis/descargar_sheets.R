# ------------------------------------------------------------------------------
# Descarga las respuestas desde Google Sheets sin autenticación.
#
# Requiere que la hoja esté publicada: en la hoja, Archivo > Compartir >
# Publicar en la web > pestaña `respuestas` > formato CSV. Google devuelve una
# URL que termina en /pub?gid=...&single=true&output=csv.
#
# Publicar la hoja la hace legible por cualquiera que tenga la URL. Los datos no
# contienen identificadores personales, y aun así conviene despublicarla al
# terminar la recogida. Si prefiere no publicarla, use el menú
# `Estudio > Exportar CSV a Drive` desde la propia hoja.
#
# Uso:
#   Rscript analisis/descargar_sheets.R "https://docs.google.com/.../pub?...output=csv"
# ------------------------------------------------------------------------------

source("analisis/_comun.R")

args <- commandArgs(trailingOnly = TRUE)
url <- if (length(args) >= 1) args[1] else Sys.getenv("HOJA_CSV_URL", "")
if (url == "")
  stop("Indique la URL del CSV publicado, o defina la variable de entorno HOJA_CSV_URL.")
if (!grepl("output=csv", url, fixed = TRUE))
  warning("La URL no termina en output=csv. Compruebe que ha publicado la hoja como CSV.")

dir.create("analisis/datos", showWarnings = FALSE, recursive = TRUE)
marca <- format(Sys.time(), "%Y%m%d_%H%M")
ruta_copia <- file.path("analisis/datos", paste0("respuestas_", marca, ".csv"))
ruta_ultima <- "analisis/datos/respuestas.csv"

d <- read.csv(url, fileEncoding = "UTF-8", check.names = TRUE)
if (!nrow(d)) stop("La hoja no ha devuelto filas.")

write.csv(d, ruta_copia, row.names = FALSE, fileEncoding = "UTF-8")
write.csv(d, ruta_ultima, row.names = FALSE, fileEncoding = "UTF-8")

cabecera("Descarga")
cat("Filas:", nrow(d), "| Columnas:", ncol(d), "\n")
if ("parcial" %in% names(d)) {
  cat("Completas:", sum(d$parcial == 0), "| Parciales:", sum(d$parcial == 1), "\n")
}
if ("condicion" %in% names(d)) { cat("\nReparto por condición:\n"); print(table(d$condicion)) }
cat("\nCopia fechada:", ruta_copia, "\n")
cat("Última versión :", ruta_ultima, "\n")
cat("\nSiguiente paso:\n  Rscript analisis/01_preparar.R", ruta_ultima, "\n")
