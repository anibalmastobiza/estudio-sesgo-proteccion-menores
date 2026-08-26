# ------------------------------------------------------------------------------
# Genera un conjunto de datos falso con la MISMA estructura de columnas que
# exporta la hoja de cálculo, para poder escribir y probar todo el análisis
# antes de recoger un solo dato real.
#
# Los efectos que se inyectan aquí son los de las hipótesis. Que el análisis los
# recupere prueba que el pipeline funciona, y no dice nada sobre si existen.
#
# Uso:  Rscript analisis/00_simular_datos.R [n] [n_conjuntos]
# ------------------------------------------------------------------------------

source("analisis/_comun.R")

args <- commandArgs(trailingOnly = TRUE)
N            <- if (length(args) >= 1) as.integer(args[1]) else 900
N_CONJUNTOS  <- if (length(args) >= 2) as.integer(args[2]) else 12
set.seed(20260826)

conds <- c("no_racializado", "magrebi", "subsahariano")

d <- data.frame(
  id            = paste0("sim-", sprintf("%04d", seq_len(N))),
  recibido_iso  = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ"),
  parcial       = 0,
  completado    = 1,
  abandonos     = 0,
  version_protocolo = "1.0.0",
  version_estimulos = "1.0-simulado",
  variante      = "foto",
  condicion     = sample(conds, N, TRUE),
  conjunto      = sprintf("C%03d", sample(N_CONJUNTOS, N, TRUE)),
  consentimiento = "si",
  stringsAsFactors = FALSE
)
d$condicion_2 <- vapply(d$condicion, function(x) sample(setdiff(conds, x), 1), character(1))
d$rac_lat     <- as.integer(d$condicion != "no_racializado")

# Variabilidad por rostro: intercepto y pendiente del efecto de condición.
u <- setNames(rnorm(N_CONJUNTOS, 0, 3.5),  sprintf("C%03d", seq_len(N_CONJUNTOS)))
s <- setNames(rnorm(N_CONJUNTOS, 0, 2.5),  sprintf("C%03d", seq_len(N_CONJUNTOS)))

# Factores latentes por participante. Sin ellos los ítems de un mismo índice
# saldrían incorrelados y el alfa de Cronbach sería cercano a cero, que es un
# artefacto del simulador y no una propiedad esperable de los datos reales.
theta_prot <- rnorm(N, 0, 1)   # disposición general a proteger
theta_sdo  <- rnorm(N, 0, 1)   # dominancia social
theta_prej <- rnorm(N, 0, 1)   # prejuicio y amenaza percibida

# Moderadores.
d$ideologia  <- pmin(10, pmax(0, round(rnorm(N, 4.8, 2.4))))
d$contacto   <- sample(1:5, N, TRUE, prob = c(.08, .17, .34, .27, .14))
for (v in c("sdo_1", "sdo_2"))
  d[[v]] <- pmin(100, pmax(0, rnorm(N, 22 + 3 * d$ideologia + 14 * theta_sdo, 13)))
for (v in c("sdo_3", "sdo_4"))
  d[[v]] <- pmin(100, pmax(0, rnorm(N, 82 - 3 * d$ideologia - 13 * theta_sdo, 12)))
d$prejuicio_1 <- pmin(100, pmax(0, rnorm(N, 30 + 4.5 * d$ideologia + 15 * theta_prej, 14)))
d$prejuicio_2 <- pmin(100, pmax(0, rnorm(N, 72 - 4.0 * d$ideologia - 15 * theta_prej, 14)))
d$amenaza     <- pmin(100, pmax(0, rnorm(N, 28 + 5.0 * d$ideologia + 15 * theta_prej, 14)))

sdo <- rowMeans(cbind(d$sdo_1, d$sdo_2, 100 - d$sdo_3, 100 - d$sdo_4))
z   <- function(x) as.numeric(scale(x))

# --- Efectos inyectados (puntos sobre 100 salvo donde se indique) -------------
EF_PROTECCION <- -6.0   # H1
EF_DEVOLUCION <-  8.0   # H2
EF_EDAD       <-  1.1   # H3, en años
EF_CREDIBIL   <- -5.0   # H4
EF_PELIGRO    <-  7.0   # H5
MODERA_SDO    <- -3.0   # el efecto crece con dominancia social

efecto <- (d$rac_lat) * (1 + 0.35 * z(sdo)) + s[d$conjunto] * d$rac_lat / 10

trunca <- function(x) pmin(100, pmax(0, x))

d$proteccion  <- trunca(rnorm(N, 76 + EF_PROTECCION * efecto + u[d$conjunto] + 13 * theta_prot, 11))
d$devolucion  <- trunca(rnorm(N, 34 + EF_DEVOLUCION * efecto - u[d$conjunto] - 15 * theta_prot, 13))
d$garantias   <- trunca(rnorm(N, 84 + 0.5 * EF_PROTECCION * efecto + 10 * theta_prot, 11))
d$credibilidad<- trunca(rnorm(N, 66 + EF_CREDIBIL * efecto, 19))
d$responsabilidad <- trunca(rnorm(N, 22 + 3 * efecto, 19))
d$peligro     <- trunca(rnorm(N, 24 + EF_PELIGRO * efecto, 20))
d$dias_evaluacion <- pmin(90, pmax(0, round(rnorm(N, 21 - 3 * efecto, 15))))

# Percepción del rostro, medida antes de la viñeta.
d$edad_percibida <- round(pmin(30, pmax(6, rnorm(N, 14.6 + EF_EDAD * efecto, 2.2))))
p_no_esp <- plogis(-1.6 + 2.4 * d$rac_lat + 0.02 * (sdo - 50))
d$nacionalidad_atribuida <- ifelse(runif(N) < p_no_esp, "no",
                                   sample(c("si", "nose"), N, TRUE, prob = c(.7, .3)))
d$origen_atribuido <- ifelse(
  d$condicion == "no_racializado", sample(c("espana", "europa", "nose"), N, TRUE, prob = c(.72, .15, .13)),
  ifelse(d$condicion == "magrebi", sample(c("magreb", "latam", "nose"), N, TRUE, prob = c(.78, .09, .13)),
                                   sample(c("africa_sub", "latam", "nose"), N, TRUE, prob = c(.80, .07, .13))))

# Decisión categórica: utilidad latente por opción.
u_prot <- 2.0 + 0.030 * (d$proteccion - 50)
u_casa <- 0.2 - 0.010 * (d$proteccion - 50)
u_comi <- 0.1 + 0.015 * (d$peligro - 50)
u_devo <- -1.0 + 0.045 * (d$devolucion - 50) + 0.9 * d$rac_lat
U <- cbind(casa = u_casa, proteccion = u_prot, comisaria = u_comi, devolucion = u_devo)
U <- U - log(-log(matrix(runif(length(U)), nrow = N)))   # ruido Gumbel
d$decision <- colnames(U)[max.col(U)]
d$orden_decision <- replicate(N, paste(sample(colnames(U)), collapse = "|"))

# Bloque de revelación: parte de la respuesta anterior y se corrige a medias.
salto <- (as.integer(d$condicion_2 != "no_racializado") - d$rac_lat)
# EF_PROTECCION ya es negativo: pasar de rostro no racializado a racializado
# (salto = +1) tiene que BAJAR la protección, de modo que el término se suma.
d$proteccion_2 <- trunca(d$proteccion + 0.55 * EF_PROTECCION * salto + rnorm(N, 0, 9))
d$devolucion_2 <- trunca(d$devolucion + 0.55 * EF_DEVOLUCION * salto + rnorm(N, 0, 10))
d$cambio_declarado <- ifelse(abs(d$proteccion_2 - d$proteccion) > 12,
                             sample(c("poco", "bastante"), N, TRUE, prob = c(.6, .4)), "nada")

# Calidad, demografía y tiempos.
d$control_atencion <- ifelse(runif(N) < .93, "4", sample(as.character(1:5), N, TRUE))
d$atencion_ok <- d$control_atencion == "4"
d$edad     <- pmin(90, pmax(18, round(rnorm(N, 45, 15))))
d$genero   <- sample(c("mujer", "hombre", "nb", "nc"), N, TRUE, prob = c(.49, .48, .02, .01))
d$estudios <- sample(c("primaria", "secundaria", "bachiller_fp", "universidad", "posgrado"),
                     N, TRUE, prob = c(.09, .24, .30, .27, .10))
d$ccaa     <- sample(c("Andalucía", "Cataluña", "Madrid", "Comunidad Valenciana", "Galicia",
                       "Castilla y León", "País Vasco", "Canarias", "Murcia", "Aragón"),
                     N, TRUE, prob = c(.18, .16, .14, .11, .06, .05, .05, .05, .03, .03) /
                       sum(c(.18, .16, .14, .11, .06, .05, .05, .05, .03, .03)))
d$origen_propio <- sample(c("no", "padres", "yo", "nc"), N, TRUE, prob = c(.83, .07, .09, .01))
d$racializado   <- sample(c("no", "si", "nc"), N, TRUE, prob = c(.90, .08, .02))
d$voto      <- sample(c("PSOE", "PP", "Vox", "Sumar", "No voté", "Prefiero no contestar"),
                      N, TRUE, prob = c(.26, .29, .13, .11, .12, .09))
d$sospecha  <- sample(c("", "ni idea", "sobre menores", "sobre racismo", "no sé"),
                      N, TRUE, prob = c(.30, .25, .25, .12, .08))
d$seriedad  <- ifelse(runif(N) < .97, "si", "no")
d$retirar   <- ifelse(runif(N) < .015, "si", "no")
d$duracion_s <- round(pmax(45, rlnorm(N, log(300), 0.45)))
for (p in c("portada", "instrucciones", "rostro", "caso", "atencion",
            "revelacion", "moderadores", "demografia", "cierre")) {
  d[[paste0("t_", p)]] <- round(pmax(600, rlnorm(N, log(18000), 0.5)))
}
d$inicio_iso <- format(Sys.time() - d$duracion_s, "%Y-%m-%dT%H:%M:%SZ")
d$fin_iso    <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ")
d$pantalla   <- "1440x900"; d$tactil <- 0; d$fuente <- "simulado"
d$zona_horaria <- "Europe/Madrid"; d$idioma_navegador <- "es"
d$rac_lat <- NULL

# Abandonos: filas parciales, ligeramente más frecuentes en condición racializada.
n_ab <- round(N * 0.12)
ab <- d[sample(nrow(d), n_ab), ]
ab$id <- paste0("simab-", sprintf("%04d", seq_len(n_ab)))
ab$parcial <- 1; ab$completado <- 0; ab$abandonos <- 1
ab$pantalla_actual <- sample(c("portada", "rostro", "caso", "moderadores"), n_ab, TRUE)
for (v in c("proteccion", "devolucion", "garantias", "credibilidad", "responsabilidad",
            "peligro", "dias_evaluacion", "decision", "seriedad", "retirar")) ab[[v]] <- NA
d$pantalla_actual <- "debriefing"

dir.create("analisis/datos", showWarnings = FALSE, recursive = TRUE)
salida <- rbind(d, ab)
write.csv(salida, "analisis/datos/simulados.csv", row.names = FALSE, fileEncoding = "UTF-8")

cat("Escrito analisis/datos/simulados.csv\n")
cat("Filas:", nrow(salida), "(", N, "completas y", n_ab, "parciales )\n")
cat("Conjuntos:", N_CONJUNTOS, "| Reparto por condición:\n")
print(table(salida$condicion))
cat("\nEfectos inyectados: protección", EF_PROTECCION, "| devolución", EF_DEVOLUCION,
    "| edad", EF_EDAD, "años | credibilidad", EF_CREDIBIL, "| peligro", EF_PELIGRO, "\n")
