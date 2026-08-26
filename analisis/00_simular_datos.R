# ------------------------------------------------------------------------------
# Genera datos falsos con la MISMA estructura de columnas que exporta la hoja de
# cálculo, para escribir y probar todo el análisis antes de recoger un dato real.
#
# Diseño simulado: 2 x 2 entre participantes, fenotipo (no racializado,
# subsahariano) por expresión (contento, afligido), con los estímulos ANIDADOS en
# cada casilla, que es la estructura de los estímulos reales tomados de AI-Faces
# by Illinois. Cada cara pertenece a una sola casilla.
#
# Los efectos que se inyectan aquí son los de las hipótesis. Que el análisis los
# recupere prueba que el pipeline funciona, y no dice nada sobre si existen.
#
# Uso:  Rscript analisis/00_simular_datos.R [n]
# ------------------------------------------------------------------------------

source("analisis/_comun.R")

args      <- commandArgs(trailingOnly = TRUE)
N         <- if (length(args) >= 1) as.integer(args[1]) else 900
set.seed(20260826)

conds <- CONDICIONES_FOTO
EXPRESIONES <- c("contento", "afligido")

# Material real: 7 caras contentas y 4 afligidas por fenotipo. Cada cara
# pertenece a una sola casilla del diseño 2 x 2.
K <- c(contento = 7, afligido = 4)
caras <- do.call(rbind, lapply(conds, function(cn) {
  do.call(rbind, lapply(EXPRESIONES, function(ex) {
    data.frame(cara = sprintf("%s_%s_%02d", substr(cn, 1, 1), substr(ex, 1, 3), seq_len(K[[ex]])),
               condicion = cn, expresion = ex, stringsAsFactors = FALSE)
  }))
}))

# Participantes repartidos por igual entre las cuatro casillas, y la cara
# concreta sorteada dentro de la casilla.
casilla <- sample(seq_len(4), N, TRUE)
combos  <- expand.grid(condicion = conds, expresion = EXPRESIONES, stringsAsFactors = FALSE)
elige_cara <- function(i) {
  pool <- caras$cara[caras$condicion == combos$condicion[i] & caras$expresion == combos$expresion[i]]
  sample(pool, 1)
}

d <- data.frame(
  id            = paste0("sim-", sprintf("%04d", seq_len(N))),
  recibido_iso  = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ"),
  parcial = 0, completado = 1, abandonos = 0,
  version_protocolo = "2.0.0", version_estimulos = "1.0-aifaces",
  variante = "foto", estructura = "anidada",
  condicion = combos$condicion[casilla],
  expresion = combos$expresion[casilla],
  consentimiento = "si",
  stringsAsFactors = FALSE
)
d$cara <- vapply(casilla, elige_cara, character(1))
d$conjunto <- d$cara
d$codigo_expresion <- ifelse(d$expresion == "contento", "s", sample(c("a", "f"), N, TRUE))
d$estimulo_1 <- paste0("aifaces/", d$cara, ".png")
d$rac_lat <- as.integer(d$condicion != conds[1])
d$afl_lat <- as.integer(d$expresion == "afligido")

# Efecto propio de cada cara. Con estímulos anidados esta varianza entra entera
# en el error de los contrastes.
u <- setNames(rnorm(nrow(caras), 0, 3.5), caras$cara)

# Factores latentes por participante, para que los índices tengan consistencia
# interna realista en lugar de ítems incorrelados.
theta_prot <- rnorm(N, 0, 1); theta_sdo <- rnorm(N, 0, 1); theta_prej <- rnorm(N, 0, 1)

d$ideologia <- pmin(10, pmax(0, round(rnorm(N, 4.8, 2.4))))
d$contacto  <- sample(1:5, N, TRUE, prob = c(.08, .17, .34, .27, .14))
for (v in c("sdo_1", "sdo_2"))
  d[[v]] <- pmin(100, pmax(0, rnorm(N, 22 + 3 * d$ideologia + 14 * theta_sdo, 13)))
for (v in c("sdo_3", "sdo_4"))
  d[[v]] <- pmin(100, pmax(0, rnorm(N, 82 - 3 * d$ideologia - 13 * theta_sdo, 12)))
d$prejuicio_1 <- pmin(100, pmax(0, rnorm(N, 30 + 4.5 * d$ideologia + 15 * theta_prej, 14)))
d$prejuicio_2 <- pmin(100, pmax(0, rnorm(N, 72 - 4.0 * d$ideologia - 15 * theta_prej, 14)))
d$amenaza     <- pmin(100, pmax(0, rnorm(N, 28 + 5.0 * d$ideologia + 15 * theta_prej, 14)))

sdo <- rowMeans(cbind(d$sdo_1, d$sdo_2, 100 - d$sdo_3, 100 - d$sdo_4))
z   <- function(x) as.numeric(scale(x))

# --- Efectos inyectados (puntos sobre 100) -----------------------------------
EF_PROTECCION <- -6.0   # H1: fenotipo racializado
EF_DEVOLUCION <-  8.0   # H2
EF_CREDIBIL   <- -5.0   # H3
EF_PELIGRO    <-  7.0   # H4
EF_EXPR       <-  5.0   # H5: una cara afligida atrae más protección
EF_INTER      <- -3.0   # H6: la cara afligida ayuda menos al chico racializado

efecto <- d$rac_lat * (1 + 0.35 * z(sdo))
afl    <- d$afl_lat
trunca <- function(x) pmin(100, pmax(0, x))

d$proteccion   <- trunca(rnorm(N, 76 + EF_PROTECCION * efecto + EF_EXPR * afl +
                                  EF_INTER * efecto * afl + u[d$cara] + 13 * theta_prot, 11))
d$devolucion   <- trunca(rnorm(N, 34 + EF_DEVOLUCION * efecto - 0.6 * EF_EXPR * afl -
                                  u[d$cara] - 15 * theta_prot, 13))
d$credibilidad <- trunca(rnorm(N, 66 + EF_CREDIBIL * efecto + 4 * afl, 19))
d$peligro      <- trunca(rnorm(N, 24 + EF_PELIGRO * efecto + 6 * afl, 20))

# Percepción del rostro, medida antes de la viñeta.
d$edad_percibida <- round(pmin(30, pmax(6, rnorm(N, 14.5 + 0.3 * d$rac_lat, 2.2))))
# Comprobación de la manipulación de expresión.
d$emocion_percibida <- ifelse(
  d$afl_lat == 1,
  sample(c("triste", "enfadado", "serio", "normal"), N, TRUE, prob = c(.34, .33, .25, .08)),
  sample(c("contento", "normal", "serio"), N, TRUE, prob = c(.82, .12, .06)))
p_no_esp <- plogis(-1.6 + 2.4 * d$rac_lat + 0.02 * (sdo - 50))
d$nacionalidad_atribuida <- ifelse(runif(N) < p_no_esp, "no",
                                   sample(c("si", "nose"), N, TRUE, prob = c(.7, .3)))
d$origen_atribuido <- ifelse(
  d$condicion == conds[1],
  sample(c("espana", "europa", "nose"), N, TRUE, prob = c(.72, .15, .13)),
  sample(c("africa_sub", "latam", "nose"), N, TRUE, prob = c(.80, .07, .13)))

# Decisión categórica: utilidad latente por opción.
U <- cbind(casa       =  0.2 - 0.010 * (d$proteccion - 50),
           proteccion =  2.0 + 0.030 * (d$proteccion - 50),
           comisaria  =  0.1 + 0.015 * (d$peligro - 50),
           devolucion = -1.0 + 0.045 * (d$devolucion - 50) + 0.9 * d$rac_lat)
U <- U - log(-log(matrix(runif(length(U)), nrow = N)))   # ruido Gumbel
d$decision <- colnames(U)[max.col(U)]
d$orden_decision <- replicate(N, paste(sample(colnames(U)), collapse = "|"))

# Calidad, demografía y tiempos.
d$control_atencion <- ifelse(runif(N) < .93, "4", sample(as.character(1:5), N, TRUE))
d$atencion_ok <- d$control_atencion == "4"
d$edad     <- pmin(90, pmax(18, round(rnorm(N, 45, 15))))
d$genero   <- sample(c("mujer", "hombre", "nb", "nc"), N, TRUE, prob = c(.49, .48, .02, .01))
pesos <- c(.18, .16, .14, .11, .06, .05, .05, .05, .03, .03)
d$ccaa <- sample(c("Andalucía", "Cataluña", "Madrid", "Comunidad Valenciana", "Galicia",
                   "Castilla y León", "País Vasco", "Canarias", "Murcia", "Aragón"),
                 N, TRUE, prob = pesos / sum(pesos))
d$racializado   <- sample(c("no", "si", "nc"), N, TRUE, prob = c(.90, .08, .02))
d$sospecha <- sample(c("", "ni idea", "sobre menores", "sobre racismo", "no sé"),
                     N, TRUE, prob = c(.30, .25, .25, .12, .08))
d$seriedad <- ifelse(runif(N) < .97, "si", "no")
d$retirar  <- ifelse(runif(N) < .015, "si", "no")
d$duracion_s <- round(pmax(45, rlnorm(N, log(300), 0.45)))
for (p in c("portada", "instrucciones", "rostro", "caso", "atencion",
            "moderadores", "demografia", "cierre"))
  d[[paste0("t_", p)]] <- round(pmax(600, rlnorm(N, log(18000), 0.5)))
d$inicio_iso <- format(Sys.time() - d$duracion_s, "%Y-%m-%dT%H:%M:%SZ")
d$fin_iso    <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ")
d$pantalla   <- "1440x900"; d$tactil <- 0; d$fuente <- "simulado"
d$zona_horaria <- "Europe/Madrid"; d$idioma_navegador <- "es"
d$rac_lat <- NULL; d$afl_lat <- NULL

# Abandonos: filas parciales.
n_ab <- round(N * 0.12)
ab <- d[sample(nrow(d), n_ab), ]
ab$id <- paste0("simab-", sprintf("%04d", seq_len(n_ab)))
ab$parcial <- 1; ab$completado <- 0; ab$abandonos <- 1
ab$pantalla_actual <- sample(c("portada", "rostro", "caso", "moderadores"), n_ab, TRUE)
for (v in c("proteccion", "devolucion", "credibilidad", "peligro",
            "decision", "seriedad", "retirar")) ab[[v]] <- NA
d$pantalla_actual <- "debriefing"

salida <- rbind(d, ab)
escribe_csv(salida, "analisis/datos/simulados.csv")

cat("Escrito analisis/datos/simulados.csv\n")
cat("Filas:", nrow(salida), "(", N, "completas y", n_ab, "parciales )\n")
cat("Caras:", nrow(caras), "| Casillas del diseño:\n")
print(table(salida$condicion, salida$expresion))
cat("\nEfectos inyectados sobre protección: fenotipo", EF_PROTECCION,
    "| expresión afligida", EF_EXPR, "| interacción", EF_INTER, "\n")
