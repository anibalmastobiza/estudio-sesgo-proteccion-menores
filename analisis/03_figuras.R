# ------------------------------------------------------------------------------
# Figuras del informe. Diseño 2 x 2: fenotipo por expresión.
#
# Uso:  Rscript analisis/03_figuras.R
# Salida: analisis/figuras/*.png (300 ppp) y *.pdf
# ------------------------------------------------------------------------------

source("analisis/_comun.R")
suppressPackageStartupMessages({ library(ggplot2); library(dplyr); library(lme4) })

d   <- readRDS("analisis/datos/preparados.rds")
res <- read.csv("analisis/salida/resultados_confirmatorios.csv", fileEncoding = "UTF-8")
dir.create("analisis/figuras", showWarnings = FALSE, recursive = TRUE)

tema <- theme_minimal(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold", size = 12),
        plot.subtitle = element_text(colour = "grey35", size = 9.5),
        plot.caption = element_text(colour = "grey45", size = 8, hjust = 0),
        legend.position = "top")

CAIRO_OK <- tryCatch({
  tmp <- tempfile(fileext = ".pdf")
  suppressWarnings(grDevices::cairo_pdf(tmp)); grDevices::dev.off(); file.remove(tmp); TRUE
}, error = function(e) FALSE, warning = function(w) FALSE)

guarda <- function(g, nombre, ancho, alto) {
  ggsave(file.path("analisis/figuras", paste0(nombre, ".png")), g,
         width = ancho, height = alto, dpi = 300)
  ok <- CAIRO_OK && tryCatch({
    ggsave(file.path("analisis/figuras", paste0(nombre, ".pdf")), g,
           width = ancho, height = alto, device = cairo_pdf); TRUE
  }, error = function(e) FALSE, warning = function(w) FALSE)
  if (!ok) ggsave(file.path("analisis/figuras", paste0(nombre, ".pdf")), g,
                  width = ancho, height = alto)
  cat("  ", nombre, ".png y .pdf\n", sep = "")
}

# --- Figura 1. Las cuatro casillas --------------------------------------------

f1 <- d |>
  group_by(condicion, expresion) |>
  summarise(n = n(), media = mean(indice_proteccion),
            et = sd(indice_proteccion) / sqrt(n()), .groups = "drop") |>
  mutate(inf = media - 1.96 * et, sup = media + 1.96 * et)

g1 <- ggplot(f1, aes(expresion, media, colour = condicion, group = condicion)) +
  geom_line(linewidth = .8) +
  geom_errorbar(aes(ymin = inf, ymax = sup), width = .06, linewidth = .7) +
  geom_point(size = 3.2) +
  geom_text(aes(label = sprintf("%.1f", media)), vjust = -1.4, size = 3.1, show.legend = FALSE) +
  scale_x_discrete(labels = ETIQ_EXPR) +
  scale_colour_manual(values = COLORES, labels = ETIQUETAS, name = NULL) +
  labs(title = "Protección considerada adecuada",
       subtitle = "Mismo caso, mismas palabras. Cambia el chico de la foto y la cara que pone",
       x = NULL, y = "Índice de protección (0 a 100)",
       caption = paste0("Barras: intervalo de confianza al 95 %. n por casilla: ",
                        paste(f1$n, collapse = " / "), ".\n",
                        "Si las dos líneas fueran paralelas, la cara pesaría lo mismo en ",
                        "los dos chicos.")) +
  tema
guarda(g1, "fig1_casillas", 6.6, 4.6)

# --- Figura 2. Los tres efectos, en las cuatro respuestas ---------------------

etiq_v <- c(indice_proteccion = "Protección", credibilidad = "Credibilidad",
            peligro = "Sospecha de delito", decision_devolucion = "Elegir devolución")
etiq_e <- c(rac = "Fenotipo\n(racializado)", afl = "Expresión\n(afligida)",
            `rac:afl` = "Interacción")

f2 <- res |>
  filter(variable != "decision_devolucion") |>
  mutate(variable = factor(etiq_v[variable], levels = rev(unname(etiq_v[1:3]))),
         efecto = factor(etiq_e[efecto], levels = unname(etiq_e)))

g2 <- ggplot(f2, aes(estimacion, variable)) +
  geom_vline(xintercept = 0, colour = "grey60", linewidth = .4) +
  geom_errorbarh(aes(xmin = ic_inf, xmax = ic_sup), height = .12, linewidth = .8,
                 colour = "grey25") +
  geom_point(size = 3, colour = "#1c4b82") +
  facet_wrap(~efecto, nrow = 1) +
  labs(title = "Los tres efectos que separa el diseño",
       subtitle = "Cuánto mueve cada factor la respuesta, en puntos sobre 100",
       x = "Diferencia (puntos)", y = NULL,
       caption = paste0("Barras: intervalo de confianza al 95 %. ",
                        "La decisión de devolución va aparte por estar en escala logit.")) +
  tema + theme(legend.position = "none",
               panel.grid.major.y = element_blank(),
               strip.text = element_text(face = "bold", size = 9))
guarda(g2, "fig2_efectos", 8.2, 3.8)

# --- Figura 3. Cara a cara ----------------------------------------------------

por_cara <- d |>
  group_by(condicion, expresion, cara) |>
  summarise(n = n(), media = mean(indice_proteccion),
            et = sd(indice_proteccion) / sqrt(n()), .groups = "drop") |>
  arrange(expresion, condicion, media) |>
  mutate(cara = factor(cara, levels = cara))

g3 <- ggplot(por_cara, aes(media, cara, colour = condicion)) +
  geom_errorbarh(aes(xmin = media - 1.96 * et, xmax = media + 1.96 * et),
                 height = 0, linewidth = .6) +
  geom_point(size = 2.2) +
  facet_wrap(~expresion, scales = "free_y", labeller = as_labeller(ETIQ_EXPR)) +
  scale_colour_manual(values = COLORES, labels = ETIQUETAS, name = NULL) +
  labs(title = "Cara a cara",
       subtitle = "Media de cada estímulo, dentro de su casilla",
       x = "Índice de protección (0 a 100)", y = NULL,
       caption = paste0("Barras: intervalo de confianza al 95 % por cara. ",
                        "Cada cara pertenece a una sola casilla, de modo que el\n",
                        "solapamiento entre las dos nubes de cada panel es el error real ",
                        "del contraste de fenotipo.")) +
  tema + theme(axis.text.y = element_text(size = 6),
               strip.text = element_text(face = "bold", size = 9))
guarda(g3, "fig3_por_estimulo", 7.4, 5.0)

# --- Figura 4. Comprobación de la manipulación de expresión -------------------

f4 <- d |>
  count(expresion, emocion_percibida) |>
  group_by(expresion) |> mutate(p = 100 * n / sum(n)) |> ungroup()
orden <- c("triste", "enfadado", "serio", "normal", "contento")
f4$emocion_percibida <- factor(f4$emocion_percibida, levels = orden)

g4 <- ggplot(f4, aes(emocion_percibida, p, fill = expresion)) +
  geom_col(position = position_dodge(width = .78), width = .7) +
  scale_x_discrete(labels = c(triste = "Triste", enfadado = "Enfadado", serio = "Serio",
                              normal = "Normal", contento = "Contento")) +
  scale_fill_manual(values = COLOR_EXPR, labels = ETIQ_EXPR, name = NULL) +
  labs(title = "¿Llega la manipulación de la expresión?",
       subtitle = "Qué emoción atribuyen los participantes a la foto que les tocó",
       x = NULL, y = "Porcentaje",
       caption = "Comprobación de la manipulación. Se calcula antes de leer la viñeta.") +
  tema
guarda(g4, "fig4_expresion", 6.8, 4.2)

cat("\nFiguras en analisis/figuras/\n")
