# ------------------------------------------------------------------------------
# Figuras del informe.
#
# Uso:  Rscript analisis/03_figuras.R
# Salida: analisis/figuras/*.png (300 ppp) y *.pdf
# ------------------------------------------------------------------------------

source("analisis/_comun.R")
suppressPackageStartupMessages({
  library(ggplot2); library(dplyr); library(tidyr); library(lme4)
})

d   <- readRDS("analisis/datos/preparados.rds")
res <- read.csv("analisis/salida/resultados_confirmatorios.csv", fileEncoding = "UTF-8")

dir.create("analisis/figuras", showWarnings = FALSE, recursive = TRUE)

tema <- theme_minimal(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        plot.title = element_text(face = "bold", size = 12),
        plot.subtitle = element_text(colour = "grey35", size = 9.5),
        plot.caption = element_text(colour = "grey45", size = 8, hjust = 0),
        legend.position = "none")

# cairo_pdf incrusta las tildes correctamente. En algunas instalaciones de R en
# macOS `capabilities("cairo")` devuelve TRUE y el dispositivo falla igualmente
# al cargarse, de modo que la comprobación se hace intentándolo de verdad.
CAIRO_OK <- tryCatch({
  tmp <- tempfile(fileext = ".pdf")
  suppressWarnings(grDevices::cairo_pdf(tmp)); grDevices::dev.off()
  file.remove(tmp); TRUE
}, error = function(e) FALSE, warning = function(w) FALSE)
if (!CAIRO_OK)
  message("Sin cairo operativo: los PDF se generan con el dispositivo estandar de R.")

guarda <- function(g, nombre, ancho, alto) {
  ggsave(file.path("analisis/figuras", paste0(nombre, ".png")), g,
         width = ancho, height = alto, dpi = 300)
  ok <- TRUE
  if (CAIRO_OK) {
    ok <- tryCatch({
      ggsave(file.path("analisis/figuras", paste0(nombre, ".pdf")), g,
             width = ancho, height = alto, device = cairo_pdf); TRUE
    }, error = function(e) FALSE, warning = function(w) FALSE)
  }
  if (!CAIRO_OK || !ok) {
    ggsave(file.path("analisis/figuras", paste0(nombre, ".pdf")), g,
           width = ancho, height = alto)
  }
  cat("  ", nombre, ".png y .pdf\n", sep = "")
}

ic <- function(x) { m <- mean(x); e <- qt(.975, length(x) - 1) * sd(x) / sqrt(length(x))
                    c(media = m, inf = m - e, sup = m + e) }

# --- Figura 1. Índice de protección por condición ------------------------------

f1_datos <- d |>
  group_by(condicion) |>
  summarise(as.data.frame(t(ic(indice_proteccion))), n = n(), .groups = "drop") |>
  mutate(etiqueta = ETIQUETAS[as.character(condicion)])

g1 <- ggplot(d, aes(condicion, indice_proteccion, colour = condicion, fill = condicion)) +
  geom_violin(alpha = .12, colour = NA, width = .85) +
  geom_jitter(width = .16, alpha = .10, size = .7) +
  geom_errorbar(data = f1_datos, aes(condicion, y = media, ymin = inf, ymax = sup),
                width = .10, linewidth = .8, inherit.aes = FALSE, colour = "grey15") +
  geom_point(data = f1_datos, aes(condicion, media), size = 3.1,
             inherit.aes = FALSE, colour = "grey15") +
  geom_text(data = f1_datos, aes(condicion, media, label = sprintf("%.1f", media)),
            inherit.aes = FALSE, nudge_x = .22, size = 3.2, colour = "grey15") +
  scale_x_discrete(labels = ETIQUETAS) +
  scale_colour_manual(values = COLORES) + scale_fill_manual(values = COLORES) +
  labs(title = "Protección considerada adecuada, por fenotipo del menor",
       subtitle = "El texto del caso es idéntico en las tres condiciones",
       x = NULL, y = "Índice de protección (0 a 100)",
       caption = paste0("Punto y barra: media e intervalo de confianza al 95 %. ",
                        "n = ", paste(f1_datos$n, collapse = " / "), ".")) +
  tema
guarda(g1, "fig1_indice_proteccion", 6.6, 4.4)

# --- Figura 2. Contrastes confirmatorios --------------------------------------
# Todo en unidades de desviación típica para que las cinco variables sean
# comparables en el mismo eje. H2 se muestra aparte por estar en escala logit.

etiq_h <- c(H1 = "Protección\n(índice)", H3 = "Edad percibida",
            H4 = "Credibilidad", H5 = "Sospecha de delito")
f2 <- res |>
  filter(hipotesis != "H2") |>
  mutate(hip = factor(hipotesis, levels = rev(c("H1", "H3", "H4", "H5"))),
         etiqueta = etiq_h[as.character(hipotesis)],
         d_inf = d * ic_inf / estimacion, d_sup = d * ic_sup / estimacion)

g2 <- ggplot(f2, aes(d, hip)) +
  geom_vline(xintercept = 0, colour = "grey60", linewidth = .4) +
  geom_errorbarh(aes(xmin = d_inf, xmax = d_sup), height = .13, linewidth = .8,
                 colour = "grey20") +
  geom_point(size = 3, colour = "#1c4b82") +
  geom_text(aes(label = sprintf("d = %.2f", d)), vjust = -1.25, size = 3.1, colour = "grey25") +
  scale_y_discrete(labels = rev(etiq_h)) +
  labs(title = "Efecto del fenotipo racializado sobre cada respuesta",
       subtitle = "Diferencia entre condiciones racializadas y no racializada",
       x = "Diferencia tipificada (d)", y = NULL,
       caption = paste0("Barras: intervalo de confianza al 95 %.\n",
                        "H2 (decisión de devolución) no aparece por estar en escala logit: ",
                        sprintf("OR = %.2f.", exp(res$estimacion[res$hipotesis == "H2"])))) +
  tema + theme(panel.grid.major.x = element_line(colour = "grey92"))
guarda(g2, "fig2_contrastes", 6.6, 4.0)

# --- Figura 3. Variabilidad entre estímulos -----------------------------------
# La figura que justifica el modelo: si el efecto cambia mucho de un rostro a
# otro, tratar los estímulos como fijos infla el error de tipo I.

por_conj <- d |>
  group_by(conjunto) |>
  summarise(n = n(),
            dif = mean(indice_proteccion[rac == 1]) - mean(indice_proteccion[rac == 0]),
            et = sqrt(var(indice_proteccion[rac == 1]) / sum(rac == 1) +
                      var(indice_proteccion[rac == 0]) / sum(rac == 0)),
            .groups = "drop") |>
  arrange(dif) |>
  mutate(conjunto = factor(conjunto, levels = conjunto))

global <- res$estimacion[res$hipotesis == "H1"]

g3 <- ggplot(por_conj, aes(dif, conjunto)) +
  geom_vline(xintercept = 0, colour = "grey60", linewidth = .4) +
  geom_vline(xintercept = global, colour = "#1c4b82", linewidth = .7, linetype = "22") +
  geom_errorbarh(aes(xmin = dif - 1.96 * et, xmax = dif + 1.96 * et),
                 height = 0, linewidth = .6, colour = "grey55") +
  geom_point(size = 2.2, colour = "grey15") +
  annotate("text", x = global, y = nlevels(por_conj$conjunto) + .4,
           label = sprintf("efecto global: %.1f", global),
           colour = "#1c4b82", size = 3, hjust = -0.05) +
  labs(title = "El mismo efecto, rostro a rostro",
       subtitle = "Diferencia en el índice de protección dentro de cada conjunto de estímulo",
       x = "Racializado menos no racializado (puntos)", y = "Conjunto",
       caption = paste0("Barras: intervalo de confianza al 95 % por conjunto. ",
                        "La dispersión entre conjuntos es lo que obliga a modelar\n",
                        "el estímulo como factor aleatorio con pendiente.")) +
  tema + theme(panel.grid.major.x = element_line(colour = "grey92"))
guarda(g3, "fig3_por_estimulo", 6.6, 4.8)

# --- Figura 4. Decisión inmediata ---------------------------------------------

etiq_dec <- c(proteccion = "Servicios sociales\ny acogida", casa = "Llevarlo\na su casa",
              comisaria = "Retenerlo en\ncomisaría", devolucion = "Iniciar la\ndevolución")
f4 <- d |>
  count(condicion, decision) |>
  group_by(condicion) |> mutate(p = 100 * n / sum(n)) |> ungroup() |>
  mutate(decision = factor(decision, levels = c("proteccion", "casa", "comisaria", "devolucion")))

g4 <- ggplot(f4, aes(decision, p, fill = condicion)) +
  geom_col(position = position_dodge(width = .78), width = .7) +
  geom_text(aes(label = sprintf("%.1f", p)), position = position_dodge(width = .78),
            vjust = -0.45, size = 2.7, colour = "grey25") +
  scale_x_discrete(labels = etiq_dec) +
  scale_fill_manual(values = COLORES, labels = ETIQUETAS, name = NULL) +
  labs(title = "Qué debería hacer la policía esta misma noche",
       subtitle = "Porcentaje de participantes que elige cada opción, por condición",
       x = NULL, y = "Porcentaje") +
  tema + theme(legend.position = "top", panel.grid.major.x = element_blank())
guarda(g4, "fig4_decision", 7.0, 4.4)

cat("\nFiguras en analisis/figuras/\n")
