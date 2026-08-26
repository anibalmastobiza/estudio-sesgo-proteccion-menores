# ------------------------------------------------------------------------------
# Análisis confirmatorio preregistrado.
#
# Uso:  Rscript analisis/02_analisis_principal.R
# Requiere: analisis/datos/preparados.rds (lo produce 01_preparar.R)
# Salida:   analisis/salida/resultados_confirmatorios.csv y consola
# ------------------------------------------------------------------------------

source("analisis/_comun.R")
suppressPackageStartupMessages({
  library(lme4); library(lmerTest); library(dplyr)
})

d <- readRDS("analisis/datos/preparados.rds")
cabecera(sprintf("N = %d | conjuntos = %d", nrow(d), nlevels(d$conjunto)))

N_PERM <- 10000
set.seed(20260826)

# ------------------------------------------------------------------ H1 --------
# Modelo principal. La pendiente aleatoria por conjunto es lo que hace que el
# contraste generalice a rostros nuevos (Judd, Westfall y Kenny, 2012).
# La simulación de preregistro/potencia.R muestra que omitirla eleva el error de
# tipo I hasta .17 cuando el efecto varía entre rostros.

cabecera("H1. Índice de protección")
m1 <- lmer(indice_proteccion ~ rac + (1 + rac || conjunto), data = d, REML = TRUE)
print(summary(m1)$coefficients, digits = 4)

if (isSingular(m1)) {
  cat("\nAJUSTE SINGULAR. Se pasa a (1 | conjunto) según el preregistro.\n")
  cat("La inferencia queda condicionada al conjunto de estímulos empleado.\n")
  m1 <- lmer(indice_proteccion ~ rac + (1 | conjunto), data = d, REML = TRUE)
  print(summary(m1)$coefficients, digits = 4)
}

co1 <- summary(m1)$coefficients["rac", ]
ic1 <- suppressMessages(confint(m1, parm = "rac", method = "Wald"))
d1  <- d_desde_modelo(co1["Estimate"], m1)
cat(sprintf("\nEfecto: %.2f puntos [%.2f, %.2f] | d = %.3f | p = %.4g\n",
            co1["Estimate"], ic1[1], ic1[2], d1, co1["Pr(>|t|)"]))
cat("Componentes de varianza:\n"); print(VarCorr(m1))

# --- Comprobación de robustez: prueba de permutación por estímulo -------------
# Se calcula la diferencia entre condiciones dentro de cada conjunto y se
# contrasta la media de esas diferencias. Permutar `rac` dentro del conjunto
# mantiene intacta la estructura de estímulos y solo destruye la asignación.

dif_por_conjunto <- function(y, rac, conj) {
  m_r <- tapply(y[rac == 1], conj[rac == 1], mean)
  m_n <- tapply(y[rac == 0], conj[rac == 0], mean)
  comunes <- intersect(names(m_r), names(m_n))
  m_r[comunes] - m_n[comunes]
}
obs <- dif_por_conjunto(d$indice_proteccion, d$rac, d$conjunto)
t_obs <- mean(obs) / (sd(obs) / sqrt(length(obs)))

nulo <- replicate(N_PERM, {
  rac_p <- unsplit(lapply(split(d$rac, d$conjunto), sample), d$conjunto)
  dd <- dif_por_conjunto(d$indice_proteccion, rac_p, d$conjunto)
  mean(dd) / (sd(dd) / sqrt(length(dd)))
})
p_perm <- (1 + sum(abs(nulo) >= abs(t_obs))) / (1 + N_PERM)
cat(sprintf("\nPermutación por estímulo (%d remuestreos): t = %.3f sobre %d conjuntos, p = %.4f\n",
            N_PERM, t_obs, length(obs), p_perm))
cat(sprintf("Diferencia media entre conjuntos: %.2f puntos (rango %.2f a %.2f)\n",
            mean(obs), min(obs), max(obs)))

# ------------------------------------------------------------------ H2 --------
cabecera("H2. Decisión de devolución")
m2 <- glmer(decision_devolucion ~ rac + (1 | conjunto), data = d, family = binomial,
            control = glmerControl(optimizer = "bobyqa"))
print(summary(m2)$coefficients, digits = 4)
co2 <- summary(m2)$coefficients["rac", ]
cat(sprintf("\nOR = %.2f [%.2f, %.2f] | p = %.4g\n",
            exp(co2["Estimate"]),
            exp(co2["Estimate"] - 1.96 * co2["Std. Error"]),
            exp(co2["Estimate"] + 1.96 * co2["Std. Error"]), co2["Pr(>|z|)"]))
cat("\nDistribución de la decisión por condición (porcentaje por fila):\n")
print(round(100 * prop.table(table(d$condicion, d$decision), 1), 1))

# ---------------------------------------------------------------- H3 a H5 -----
secundarias <- list(H3 = "edad_percibida", H4 = "credibilidad", H5 = "peligro")
res_sec <- lapply(names(secundarias), function(h) {
  v <- secundarias[[h]]
  m <- lmer(as.formula(sprintf("%s ~ rac + (1 + rac || conjunto)", v)), data = d, REML = TRUE)
  if (isSingular(m)) m <- lmer(as.formula(sprintf("%s ~ rac + (1 | conjunto)", v)), data = d)
  co <- summary(m)$coefficients["rac", ]
  ic <- suppressMessages(confint(m, parm = "rac", method = "Wald"))
  data.frame(hipotesis = h, variable = v, estimacion = co["Estimate"],
             ic_inf = ic[1], ic_sup = ic[2], et = co["Std. Error"],
             p = co["Pr(>|t|)"], d = d_desde_modelo(co["Estimate"], m),
             singular = isSingular(m))
})

confirmatorio <- rbind(
  data.frame(hipotesis = "H1", variable = "indice_proteccion",
             estimacion = co1["Estimate"], ic_inf = ic1[1], ic_sup = ic1[2],
             et = co1["Std. Error"], p = co1["Pr(>|t|)"], d = d1, singular = isSingular(m1)),
  data.frame(hipotesis = "H2", variable = "decision_devolucion",
             estimacion = co2["Estimate"],
             ic_inf = co2["Estimate"] - 1.96 * co2["Std. Error"],
             ic_sup = co2["Estimate"] + 1.96 * co2["Std. Error"],
             et = co2["Std. Error"], p = co2["Pr(>|z|)"], d = NA, singular = isSingular(m2)),
  do.call(rbind, res_sec))
rownames(confirmatorio) <- NULL
confirmatorio$p_holm <- p.adjust(confirmatorio$p, method = "holm")
confirmatorio$significativo <- confirmatorio$p_holm < .05

cabecera("Familia confirmatoria, corrección de Holm")
print(confirmatorio, row.names = FALSE, digits = 4)
escribe_csv(confirmatorio, "analisis/salida/resultados_confirmatorios.csv")
cat("\nH2 se informa en escala logarítmica de la razón de momios: OR =",
    sprintf("%.2f", exp(confirmatorio$estimacion[2])), "\n")

# --------------------------------------------------------- Exploratorio -------

cabecera("EXPLORATORIO. Nada de lo que sigue es confirmatorio.")

cat("\nContraste magrebí frente a subsahariano:\n")
dr <- d |> filter(condicion != "no_racializado") |> droplevels()
m_rr <- lmer(indice_proteccion ~ condicion + (1 | conjunto), data = dr)
print(summary(m_rr)$coefficients, digits = 4)

cat("\nModeración por dominancia social, ideología y contacto:\n")
for (mod in c("sdo", "ideologia", "contacto")) {
  d$mod_z <- as.numeric(scale(d[[mod]]))
  mm <- lmer(indice_proteccion ~ rac * mod_z + (1 | conjunto), data = d)
  co <- summary(mm)$coefficients["rac:mod_z", ]
  cat(sprintf("  %-10s interacción = %6.2f (ET %.2f), p = %.4f\n",
              mod, co["Estimate"], co["Std. Error"], co["Pr(>|t|)"]))
}

cat("\nExtranjería atribuida como mediador (pasos de Baron y Kenny, orientativo):\n")
ma <- glm(extranjeria ~ rac, data = d, family = binomial)
mb <- lmer(indice_proteccion ~ rac + extranjeria + (1 | conjunto), data = d)
cat(sprintf("  a: rac -> extranjería, OR = %.2f, p = %.3g\n",
            exp(coef(ma)["rac"]), summary(ma)$coefficients["rac", 4]))
cat(sprintf("  b: extranjería -> protección, b = %.2f, p = %.3g\n",
            fixef(mb)["extranjeria"], summary(mb)$coefficients["extranjeria", 5]))
cat(sprintf("  c': rac -> protección con mediador, b = %.2f (sin mediador: %.2f)\n",
            fixef(mb)["rac"], co1["Estimate"]))
cat("  Los tres coeficientes son observacionales para b y c'. No se interpreta\n")
cat("  como efecto causal: el mediador no está aleatorizado.\n")

cat("\nBloque de revelación (intrasujeto):\n")
cambio <- d |>
  filter(orden_racial != 0) |>
  group_by(sentido = ifelse(orden_racial > 0, "no racializado -> racializado",
                                              "racializado -> no racializado")) |>
  summarise(n = n(), cambio_medio = mean(cambio_proteccion, na.rm = TRUE),
            et = sd(cambio_proteccion, na.rm = TRUE) / sqrt(n()), .groups = "drop")
print(as.data.frame(cambio), row.names = FALSE, digits = 3)
cat("\nCambio declarado por el propio participante:\n")
print(round(100 * prop.table(table(d$condicion, d$cambio_declarado), 1), 1))

cabecera("Sesión")
cat(R.version.string, "| lme4", as.character(packageVersion("lme4")), "\n")
cat("Resultados en analisis/salida/resultados_confirmatorios.csv\n")
