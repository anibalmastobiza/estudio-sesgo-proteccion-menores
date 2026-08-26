# ------------------------------------------------------------------------------
# Análisis confirmatorio preregistrado. Diseño 2 x 2 entre participantes:
# fenotipo del menor (no racializado, subsahariano) por expresión de su cara
# (contento, afligido), con los estímulos ANIDADOS en cada casilla.
#
# Uso:  Rscript analisis/02_analisis_principal.R
# Requiere: analisis/datos/preparados.rds (lo produce 01_preparar.R)
# Salida:   analisis/salida/resultados_confirmatorios.csv y consola
# ------------------------------------------------------------------------------

source("analisis/_comun.R")
suppressPackageStartupMessages({ library(lme4); library(lmerTest); library(dplyr) })

d <- readRDS("analisis/datos/preparados.rds")
cabecera(sprintf("N = %d | caras = %d | casillas = %d",
                 nrow(d), nlevels(d$cara), nlevels(d$condicion) * nlevels(d$expresion)))

N_PERM <- 10000
set.seed(20260826)

# El intercepto aleatorio por cara es obligatorio: cada cara pertenece a una sola
# casilla, de modo que la variación entre caras entra entera en el error de los
# contrastes (Judd, Westfall y Kenny, 2012). Sin él, la comparación se haría
# contra la variación entre participantes, que es mucho menor, y el error de
# tipo I se dispara.
formula_base <- function(v) as.formula(sprintf("%s ~ rac * afl + (1 | cara)", v))

resume <- function(v, familia = TRUE) {
  m <- lmer(formula_base(v), data = d, REML = TRUE)
  co <- summary(m)$coefficients
  ic <- suppressMessages(confint(m, parm = c("rac", "afl", "rac:afl"), method = "Wald"))
  dt_total <- sqrt(sum(as.data.frame(VarCorr(m))$vcov))
  out <- lapply(c("rac", "afl", "rac:afl"), function(term) {
    data.frame(variable = v, efecto = term,
               estimacion = co[term, "Estimate"], et = co[term, "Std. Error"],
               ic_inf = ic[term, 1], ic_sup = ic[term, 2],
               gl = co[term, "df"], p = co[term, "Pr(>|t|)"],
               d = co[term, "Estimate"] / dt_total,
               singular = isSingular(m))
  })
  list(modelo = m, tabla = do.call(rbind, out))
}

# ------------------------------------------------------------------ H1 a H4 ---

cabecera("Modelo principal sobre el índice de protección")
r1 <- resume("indice_proteccion")
print(summary(r1$modelo)$coefficients, digits = 4)
cat("\nComponentes de varianza:\n"); print(VarCorr(r1$modelo))
if (isSingular(r1$modelo))
  cat("\nAJUSTE SINGULAR: la varianza entre caras se estima en cero.\n")

cat("\nMedias por casilla:\n")
print(as.data.frame(d |> group_by(condicion, expresion) |>
        summarise(n = n(), media = mean(indice_proteccion),
                  et = sd(indice_proteccion) / sqrt(n()), .groups = "drop")),
      row.names = FALSE, digits = 4)

# --- Permutación entre caras --------------------------------------------------
# La unidad de análisis es la cara. La hipótesis nula se construye barajando la
# etiqueta de fenotipo ENTRE caras dentro de cada expresión, que es exactamente
# la aleatoriedad que no tenemos: las caras no fueron asignadas al azar a su
# fenotipo, vienen dadas por su aspecto.
agg <- d |> group_by(cara, condicion, expresion) |>
  summarise(media = mean(indice_proteccion), .groups = "drop")

t_fenotipo <- function(a) {
  x <- a$media[a$rac == 1]; y <- a$media[a$rac == 0]
  (mean(x) - mean(y)) / sqrt(var(x) / length(x) + var(y) / length(y))
}
agg$rac <- as.integer(agg$condicion != "no_racializado")
t_obs <- t_fenotipo(agg)
nulo <- replicate(N_PERM, {
  a <- agg
  a$rac <- unsplit(lapply(split(a$rac, a$expresion), sample), a$expresion)
  t_fenotipo(a)
})
p_perm <- (1 + sum(abs(nulo) >= abs(t_obs))) / (1 + N_PERM)
cat(sprintf("\nPermutación entre caras (%d remuestreos): t = %.3f sobre %d caras, p = %.4f\n",
            N_PERM, t_obs, nrow(agg), p_perm))
if (nrow(agg) < 24)
  cat("AVISO: con 22 caras la prueba de permutación tiene poca resolución.\n")

# --- Decisión categórica ------------------------------------------------------
cabecera("Decisión de devolución")
m2 <- glmer(decision_devolucion ~ rac * afl + (1 | cara), data = d, family = binomial,
            control = glmerControl(optimizer = "bobyqa"))
print(summary(m2)$coefficients, digits = 4)
co2 <- summary(m2)$coefficients
cat(sprintf("\nOR del fenotipo = %.2f [%.2f, %.2f]\n", exp(co2["rac", "Estimate"]),
            exp(co2["rac", "Estimate"] - 1.96 * co2["rac", "Std. Error"]),
            exp(co2["rac", "Estimate"] + 1.96 * co2["rac", "Std. Error"])))
cat("\nDistribución de la decisión por casilla (porcentaje por fila):\n")
print(round(100 * prop.table(table(interaction(d$condicion, d$expresion, sep = " / "),
                                   d$decision), 1), 1))

# --- Respuestas secundarias ---------------------------------------------------
r3 <- resume("credibilidad")
r4 <- resume("peligro")

confirmatorio <- rbind(r1$tabla, r3$tabla, r4$tabla,
  data.frame(variable = "decision_devolucion", efecto = c("rac", "afl", "rac:afl"),
             estimacion = co2[c("rac", "afl", "rac:afl"), "Estimate"],
             et = co2[c("rac", "afl", "rac:afl"), "Std. Error"],
             ic_inf = co2[c("rac", "afl", "rac:afl"), "Estimate"] -
                      1.96 * co2[c("rac", "afl", "rac:afl"), "Std. Error"],
             ic_sup = co2[c("rac", "afl", "rac:afl"), "Estimate"] +
                      1.96 * co2[c("rac", "afl", "rac:afl"), "Std. Error"],
             gl = NA, p = co2[c("rac", "afl", "rac:afl"), "Pr(>|z|)"],
             d = NA, singular = isSingular(m2)))
rownames(confirmatorio) <- NULL

# Corrección de Holm dentro de cada familia de efectos, no sobre las doce
# pruebas juntas: fenotipo, expresión e interacción responden a preguntas
# distintas y no se corrigen unas por otras.
confirmatorio <- confirmatorio |>
  group_by(efecto) |>
  mutate(p_holm = p.adjust(p, method = "holm")) |>
  ungroup() |>
  mutate(significativo = p_holm < .05) |>
  arrange(factor(efecto, levels = c("rac", "afl", "rac:afl")), variable)

cabecera("Familia confirmatoria, Holm dentro de cada efecto")
cat("rac     = fenotipo racializado frente a no racializado\n")
cat("afl     = cara afligida frente a cara contenta\n")
cat("rac:afl = interacción, si la cara pesa distinto según el fenotipo\n\n")
print(as.data.frame(confirmatorio), row.names = FALSE, digits = 4)
escribe_csv(confirmatorio, "analisis/salida/resultados_confirmatorios.csv")

# ---------------------------------------------------------- Exploratorio ------

cabecera("EXPLORATORIO. Nada de lo que sigue es confirmatorio.")

cat("\nModeración por ideología, contacto y amenaza percibida:\n")
for (mod in c("ideologia", "contacto", "prejuicio")) {
  d$mod_z <- as.numeric(scale(d[[mod]]))
  mm <- lmer(indice_proteccion ~ rac * mod_z + afl + (1 | cara), data = d)
  co <- summary(mm)$coefficients["rac:mod_z", ]
  cat(sprintf("  %-10s interacción con el fenotipo = %6.2f (ET %.2f), p = %.4f\n",
              mod, co["Estimate"], co["Std. Error"], co["Pr(>|t|)"]))
}

cat("\nExtranjería atribuida (origen distinto de España) por casilla:\n")
print(round(100 * tapply(d$extranjero_atribuido,
                         interaction(d$condicion, d$expresion, sep = " / "), mean), 1))

cat("\nEdad percibida. NO es contraste confirmatorio: las dos muestras de caras\n")
cat("difieren 0.27 años en edad percibida normativa, en la misma dirección que\n")
cat("la hipótesis de adultificación.\n")
me <- lmer(edad_percibida ~ rac * afl + (1 | cara), data = d)
print(summary(me)$coefficients[c("rac", "afl", "rac:afl"), ], digits = 4)

cabecera("Sesión")
cat(R.version.string, "| lme4", as.character(packageVersion("lme4")), "\n")
cat("Resultados en analisis/salida/resultados_confirmatorios.csv\n")
