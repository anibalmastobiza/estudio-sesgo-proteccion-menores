# ------------------------------------------------------------------------------
# Configuración común a todos los scripts de análisis.
# Se carga con: source("analisis/_comun.R")
# ------------------------------------------------------------------------------

# --- Codificación -------------------------------------------------------------
# Rscript arranca en locale C en macOS, y en locale C toda cadena con tilde se
# trunca al escribirla. Sin esto, "Andalucía" se guarda como "Andaluc".
fija_utf8 <- function() {
  if (isTRUE(l10n_info()$`UTF-8`)) return(invisible(TRUE))
  for (lc in c("es_ES.UTF-8", "en_US.UTF-8", "C.UTF-8")) {
    if (suppressWarnings(Sys.setlocale("LC_CTYPE", lc)) != "") {
      if (isTRUE(l10n_info()$`UTF-8`)) return(invisible(TRUE))
    }
  }
  warning("No hay locale UTF-8 disponible. Las cadenas con tilde se corromperán. ",
          "Ejecute con LC_ALL=es_ES.UTF-8 delante del comando.", call. = FALSE)
  invisible(FALSE)
}
fija_utf8()

options(stringsAsFactors = FALSE, width = 100)

# --- Constantes del protocolo -------------------------------------------------
# Variante fotográfica: dos condiciones. No hay estímulos válidos para la
# condición magrebí (ver estimulos/README.md), que se estudia con nombres.
CONDICIONES_FOTO   <- c("no_racializado", "subsahariano")
CONDICIONES_NOMBRE <- c("no_racializado", "magrebi", "subsahariano")
CONDICIONES <- CONDICIONES_FOTO
ETIQUETAS   <- c(no_racializado = "No racializado",
                 magrebi        = "Magrebí",
                 subsahariano   = "Subsahariano")

# Criterios de exclusión preregistrados (apartado 10 del preregistro).
DURACION_MIN_S <- 90
DURACION_MAX_S <- 3600

# Familia confirmatoria: cinco contrastes con corrección de Holm.
EXPRESIONES <- c("contento", "afligido")
ETIQ_EXPR   <- c(contento = "Cara contenta", afligido = "Cara afligida")

# Familia confirmatoria sobre el índice de protección y las tres respuestas
# secundarias. La edad percibida queda fuera: las dos muestras de caras no están
# perfectamente emparejadas en edad percibida normativa y el desajuste apunta en
# la dirección de la hipótesis de adultificación, de modo que no se puede separar
# el sesgo del participante del desajuste del estímulo.
FAMILIA_H <- c(H1 = "indice_proteccion", H2 = "decision_devolucion",
               H3 = "credibilidad", H4 = "peligro")

# Paleta accesible en escala de grises y para daltonismo.
COLORES <- c(no_racializado = "#4C6EA8", magrebi = "#C4762E", subsahariano = "#3F8A70")
COLOR_EXPR <- c(contento = "#7A9BC4", afligido = "#1c4b82")

# --- Utilidades ---------------------------------------------------------------

escribe_csv <- function(x, ruta) {
  dir.create(dirname(ruta), showWarnings = FALSE, recursive = TRUE)
  write.csv(x, ruta, row.names = FALSE, fileEncoding = "UTF-8")
  invisible(ruta)
}

cabecera <- function(txt) {
  cat("\n", strrep("=", 78), "\n", txt, "\n", strrep("=", 78), "\n", sep = "")
}

# d de Cohen a partir de un contraste de un modelo mixto: la diferencia se
# divide por la DT total implicada por el modelo (residual más efectos
# aleatorios), no solo por la residual.
d_desde_modelo <- function(estimacion, modelo) {
  vc <- as.data.frame(lme4::VarCorr(modelo))
  estimacion / sqrt(sum(vc$vcov))
}
