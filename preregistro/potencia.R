# ------------------------------------------------------------------------------
# Potencia y error de tipo I del contraste principal
# (racializado vs no racializado) sobre el índice de protección.
#
# El punto crítico de este diseño no es el número de participantes sino el de
# CONJUNTOS de estímulo. Cada conjunto es una identidad facial presentada en tres
# versiones fenotípicas, así que el efecto de la condición puede variar de un
# rostro a otro. Tratar los estímulos como factor fijo infla el error de tipo I
# (Judd, Westfall y Kenny, 2012, Journal of Personality and Social Psychology,
# 103, 54-69). El modelo incluye por tanto pendiente aleatoria por conjunto.
#
# Parte A: error de tipo I con d = 0, comparando dos especificaciones del efecto
#          aleatorio (correlacionada y no correlacionada).
# Parte B: potencia con d = 0.30 cruzando participantes y conjuntos.
#
# Uso:  Rscript preregistro/potencia.R [n_simulaciones]
# ------------------------------------------------------------------------------

suppressPackageStartupMessages({ library(lme4); library(lmerTest) })

args  <- commandArgs(trailingOnly = TRUE)
N_SIM <- if (length(args) >= 1) as.integer(args[1]) else 500
set.seed(20260826)

TAU_INT <- 0.15   # DT del intercepto por conjunto

genera <- function(n_part, n_conjuntos, d, tau_pend) {
  condicion <- sample(c("no_racializado", "magrebi", "subsahariano"), n_part, replace = TRUE)
  conjunto  <- sample(seq_len(n_conjuntos), n_part, replace = TRUE)
  rac       <- as.integer(condicion != "no_racializado")
  u <- rnorm(n_conjuntos, 0, TAU_INT)
  s <- rnorm(n_conjuntos, 0, tau_pend)
  data.frame(y = (d + s[conjunto]) * rac + u[conjunto] + rnorm(n_part, 0, 1),
             rac = rac, conjunto = factor(conjunto))
}

ajusta <- function(datos, spec) {
  f <- switch(spec,
    correlacionada    = y ~ rac + (1 + rac | conjunto),
    no_correlacionada = y ~ rac + (1 + rac || conjunto),
    solo_intercepto   = y ~ rac + (1 | conjunto))
  m <- suppressMessages(suppressWarnings(
    lmerTest::lmer(f, data = datos, control = lmerControl(calc.derivs = FALSE))))
  co <- summary(m)$coefficients
  c(p = co["rac", "Pr(>|t|)"], est = co["rac", "Estimate"], sing = as.numeric(isSingular(m)))
}

# ------------------------------------------------------------- Parte A: alfa --
cat("PARTE A. Error de tipo I (d = 0, n_part = 900).\n")
esc_a <- expand.grid(n_conjuntos = c(6, 12, 24), tau_pend = c(0.10, 0.20),
                     spec = c("correlacionada", "no_correlacionada", "solo_intercepto"),
                     stringsAsFactors = FALSE)
t0 <- Sys.time()
alfa <- do.call(rbind, lapply(seq_len(nrow(esc_a)), function(i) {
  e <- esc_a[i, ]
  r <- replicate(N_SIM, ajusta(genera(900, e$n_conjuntos, 0, e$tau_pend), e$spec))
  data.frame(spec = e$spec, n_conjuntos = e$n_conjuntos, tau_pend = e$tau_pend,
             alfa_empirico = mean(r["p", ] < .05), singulares = mean(r["sing", ]))
}))
alfa <- alfa[order(alfa$spec, alfa$tau_pend, alfa$n_conjuntos), ]
print(alfa, row.names = FALSE, digits = 3)
cat("Tiempo parte A:", round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 2), "min\n\n")

# --------------------------------------------------------- Parte B: potencia --
cat("PARTE B. Potencia (d = 0.30, especificación no correlacionada).\n")
esc_b <- expand.grid(n_part = c(600, 900, 1200), n_conjuntos = c(6, 12, 24),
                     tau_pend = c(0.10, 0.20), stringsAsFactors = FALSE)
t0 <- Sys.time()
pot <- do.call(rbind, lapply(seq_len(nrow(esc_b)), function(i) {
  e <- esc_b[i, ]
  r <- replicate(N_SIM, ajusta(genera(e$n_part, e$n_conjuntos, 0.30, e$tau_pend),
                               "no_correlacionada"))
  data.frame(n_part = e$n_part, n_conjuntos = e$n_conjuntos, tau_pend = e$tau_pend,
             potencia = mean(r["p", ] < .05), sesgo = mean(r["est", ]) - 0.30,
             dt_estim = sd(r["est", ]), singulares = mean(r["sing", ]))
}))
pot <- pot[order(pot$tau_pend, pot$n_conjuntos, pot$n_part), ]
print(pot, row.names = FALSE, digits = 3)
cat("Tiempo parte B:", round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 2), "min\n")

if (!interactive()) {
  con <- file("preregistro/potencia_resultados.txt", "w", encoding = "UTF-8")
  writeLines(c(
    "Potencia y error de tipo I. Contraste racializado vs no racializado.",
    paste("Fecha:", Sys.Date(), "| Simulaciones por escenario:", N_SIM),
    paste("Semilla: 20260826 | R", as.character(getRversion()),
          "| lme4", as.character(packageVersion("lme4"))),
    "y ~ rac + efecto aleatorio por conjunto; alfa nominal = .05 bilateral.",
    paste("tau_int =", TAU_INT, "| DT residual = 1 | d en unidades de DT."),
    "", "PARTE A. Error de tipo I empirico (d = 0, n_part = 900):",
    paste(capture.output(print(alfa, row.names = FALSE, digits = 3)), collapse = "\n"),
    "", "PARTE B. Potencia (d = 0.30, pendientes no correlacionadas):",
    paste(capture.output(print(pot, row.names = FALSE, digits = 3)), collapse = "\n")
  ), con)
  close(con)
  cat("\nEscrito en preregistro/potencia_resultados.txt\n")
}
