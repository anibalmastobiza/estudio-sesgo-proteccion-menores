# ------------------------------------------------------------------------------
# Potencia del diseño 2 x 2: fenotipo del menor por expresión de su cara,
# entre participantes, con los estímulos ANIDADOS en cada casilla.
#
# Los estímulos de AI-Faces by Illinois son identidades independientes: cada cara
# pertenece a una sola casilla del diseño. La variación entre caras entra por
# tanto entera en el error de los contrastes, que es el caso difícil de Judd,
# Westfall y Kenny (2012). Añadir participantes casi no la reduce; solo la reduce
# añadir caras.
#
# Modelo:  y ~ fenotipo * expresion + (1 | cara)
#
# Material disponible: 7 caras contentas y 4 afligidas por fenotipo, 22 en total.
#
# Uso:  Rscript preregistro/potencia.R [n_simulaciones]
# ------------------------------------------------------------------------------

suppressPackageStartupMessages({ library(lme4); library(lmerTest) })

args  <- commandArgs(trailingOnly = TRUE)
N_SIM <- if (length(args) >= 1) as.integer(args[1]) else 500
set.seed(20260826)

# k_c caras contentas y k_a afligidas por fenotipo
genera <- function(n_part, k_c, k_a, d_fen, d_exp, d_int, tau) {
  casillas <- expand.grid(fen = c(0, 1), exp = c(0, 1))   # exp: 0 contento, 1 afligido
  caras <- do.call(rbind, lapply(seq_len(nrow(casillas)), function(i) {
    k <- if (casillas$exp[i] == 0) k_c else k_a
    data.frame(fen = casillas$fen[i], exp = casillas$exp[i], cara = paste0(i, "_", seq_len(k)))
  }))
  caras$u <- rnorm(nrow(caras), 0, tau)

  # Participantes repartidos por igual entre las cuatro casillas.
  cual <- sample(seq_len(nrow(casillas)), n_part, replace = TRUE)
  fila <- vapply(cual, function(i) {
    idx <- which(caras$fen == casillas$fen[i] & caras$exp == casillas$exp[i])
    idx[sample.int(length(idx), 1)]
  }, integer(1))

  x <- caras[fila, ]
  data.frame(y = d_fen * x$fen + d_exp * x$exp + d_int * x$fen * x$exp +
                 x$u + rnorm(n_part, 0, 1),
             fen = x$fen, exp = x$exp, cara = factor(x$cara))
}

prueba <- function(datos) {
  m <- suppressMessages(suppressWarnings(
    lmerTest::lmer(y ~ fen * exp + (1 | cara), data = datos,
                   control = lmerControl(calc.derivs = FALSE))))
  co <- summary(m)$coefficients
  c(p_fen = co["fen", "Pr(>|t|)"], p_exp = co["exp", "Pr(>|t|)"],
    p_int = co["fen:exp", "Pr(>|t|)"], est_fen = co["fen", "Estimate"])
}

cat("Diseño 2 x 2 con estímulos anidados. Simulaciones por escenario:", N_SIM, "\n\n")

cat("PARTE A. Error de tipo I (todos los efectos nulos, n_part = 900).\n")
esc_a <- expand.grid(k = c(4, 7, 12, 20), tau = c(0.10, 0.20))
alfa <- do.call(rbind, lapply(seq_len(nrow(esc_a)), function(i) {
  e <- esc_a[i, ]
  r <- replicate(N_SIM, prueba(genera(900, e$k, e$k, 0, 0, 0, e$tau)))
  data.frame(caras_por_casilla = e$k, tau = e$tau,
             alfa_fenotipo = mean(r["p_fen", ] < .05),
             alfa_expresion = mean(r["p_exp", ] < .05),
             alfa_interaccion = mean(r["p_int", ] < .05))
}))
print(alfa[order(alfa$tau, alfa$caras_por_casilla), ], row.names = FALSE, digits = 3)

cat("\nPARTE B. Potencia con el material real (7 contentas y 4 afligidas por fenotipo).\n")
cat("Efectos: fenotipo d = 0.30, expresión d = 0.40, interacción d = 0.20.\n")
esc_b <- expand.grid(n_part = c(600, 900, 1200, 2000), tau = c(0.10, 0.20))
pot <- do.call(rbind, lapply(seq_len(nrow(esc_b)), function(i) {
  e <- esc_b[i, ]
  r <- replicate(N_SIM, prueba(genera(e$n_part, 7, 4, 0.30, 0.40, 0.20, e$tau)))
  data.frame(n_part = e$n_part, tau = e$tau,
             pot_fenotipo = mean(r["p_fen", ] < .05),
             pot_expresion = mean(r["p_exp", ] < .05),
             pot_interaccion = mean(r["p_int", ] < .05))
}))
print(pot[order(pot$tau, pot$n_part), ], row.names = FALSE, digits = 3)

cat("\nPARTE C. Cuántas caras harían falta, con 900 participantes y tau = 0.20.\n")
esc_c <- data.frame(k = c(4, 7, 12, 20, 30))
mas <- do.call(rbind, lapply(esc_c$k, function(k) {
  r <- replicate(N_SIM, prueba(genera(900, k, k, 0.30, 0.40, 0.20, 0.20)))
  data.frame(caras_por_casilla = k,
             pot_fenotipo = mean(r["p_fen", ] < .05),
             pot_interaccion = mean(r["p_int", ] < .05))
}))
print(mas, row.names = FALSE, digits = 3)

if (!interactive()) {
  con <- file("preregistro/potencia_resultados.txt", "w", encoding = "UTF-8")
  writeLines(c(
    "Potencia del diseno 2 x 2 (fenotipo x expresion) con estimulos anidados.",
    paste("Fecha:", Sys.Date(), "| Simulaciones por escenario:", N_SIM),
    paste("Semilla: 20260826 | R", as.character(getRversion()), "| lme4",
          as.character(packageVersion("lme4"))),
    "Modelo: y ~ fen * exp + (1 | cara). Alfa nominal .05 bilateral. DT residual = 1.",
    "tau = DT del efecto propio de cada cara, en unidades de DT de la respuesta.",
    "", "PARTE A. Error de tipo I empirico (efectos nulos, n_part = 900):",
    paste(capture.output(print(alfa[order(alfa$tau, alfa$caras_por_casilla), ],
                               row.names = FALSE, digits = 3)), collapse = "\n"),
    "", "PARTE B. Potencia con el material real (7 contentas y 4 afligidas por fenotipo):",
    paste(capture.output(print(pot[order(pot$tau, pot$n_part), ],
                               row.names = FALSE, digits = 3)), collapse = "\n"),
    "", "PARTE C. Potencia segun el numero de caras (900 participantes, tau = 0.20):",
    paste(capture.output(print(mas, row.names = FALSE, digits = 3)), collapse = "\n")
  ), con)
  close(con)
  cat("\nEscrito en preregistro/potencia_resultados.txt\n")
}

# ------------------------------------------------------------------------------
# PARTE D. Efecto mínimo detectable, con el material real y 900 participantes.
# Es la cifra que hay que mirar antes de interpretar un resultado nulo.
# ------------------------------------------------------------------------------
if (!interactive()) {
  cat("\nPARTE D. Efecto mínimo detectable (potencia .80, n = 900, material real).\n")
  mde <- function(cual, tau) {
    for (dd in seq(0.10, 1.60, by = 0.05)) {
      a <- if (cual == "fen") dd else 0.30
      b <- if (cual == "exp") dd else 0.40
      i <- if (cual == "int") dd else 0.20
      r <- replicate(300, prueba(genera(900, 7, 4, a, b, i, tau)))
      if (mean(r[paste0("p_", cual), ] < .05) >= .80) return(dd)
    }
    NA
  }
  tabla_d <- do.call(rbind, lapply(c(0.10, 0.20), function(tau) {
    data.frame(tau = tau,
               d_min_fenotipo = mde("fen", tau),
               d_min_expresion = mde("exp", tau),
               d_min_interaccion = mde("int", tau))
  }))
  print(tabla_d, row.names = FALSE, digits = 3)
  con <- file("preregistro/potencia_resultados.txt", "a", encoding = "UTF-8")
  writeLines(c("", "PARTE D. Efecto minimo detectable (potencia .80, n = 900, material real):",
               paste(capture.output(print(tabla_d, row.names = FALSE, digits = 3)),
                     collapse = "\n")), con)
  close(con)
}
