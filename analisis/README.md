# Análisis

Todo se ejecuta desde la raíz del repositorio, no desde esta carpeta.

## Orden

```bash
Rscript analisis/00_simular_datos.R          # datos falsos, para probar el pipeline
Rscript analisis/01_preparar.R               # exclusiones, índices, libro de códigos
Rscript analisis/02_analisis_principal.R     # modelos confirmatorios preregistrados
Rscript analisis/03_figuras.R                # cuatro figuras en PNG y PDF
```

Con datos reales, sustituya el primer paso:

```bash
Rscript analisis/descargar_sheets.R "https://docs.google.com/.../pub?...output=csv"
Rscript analisis/01_preparar.R analisis/datos/respuestas.csv
Rscript analisis/02_analisis_principal.R
Rscript analisis/03_figuras.R
```

## Qué hace cada script

| Script | Entrada | Salida |
|---|---|---|
| `_comun.R` | | Locale UTF-8, constantes del protocolo, utilidades. Lo cargan los demás. |
| `00_simular_datos.R` | | `datos/simulados.csv` con la misma estructura de columnas que la hoja real |
| `descargar_sheets.R` | URL del CSV publicado | `datos/respuestas.csv` y una copia fechada |
| `01_preparar.R` | CSV | `datos/preparados.rds`, `salida/exclusiones.csv`, `salida/descriptivos.csv` |
| `02_analisis_principal.R` | `preparados.rds` | `salida/resultados_confirmatorios.csv` y salida por consola |
| `03_figuras.R` | `preparados.rds` y resultados | `figuras/*.png` y `figuras/*.pdf` |

## Por qué probarlo antes con datos simulados

`00_simular_datos.R` inyecta efectos conocidos. Si el análisis los recupera con
el signo y la magnitud correctos, el pipeline funciona. Escribir y depurar el
análisis con datos simulados evita la tentación de ajustar decisiones analíticas
después de ver los resultados reales.

Los efectos inyectados están declarados en la cabecera del script: protección
-6 puntos, devolución +8, edad percibida +1.1 años, credibilidad -5, sospecha de
delito +7. La comprobación es que `02_analisis_principal.R` los devuelva.

## Paquetes

`lme4`, `lmerTest`, `dplyr`, `tidyr`, `ggplot2`. Nada más.

```r
install.packages(c("lme4", "lmerTest", "dplyr", "tidyr", "ggplot2"))
```

## Nota sobre codificación

Rscript arranca en locale C en macOS, y en locale C toda cadena con tilde se
trunca al escribirla en un CSV. `_comun.R` fuerza un locale UTF-8 al cargarse.
Si aparece el aviso de que no hay ninguno disponible, ejecute con el locale
delante del comando:

```bash
LC_ALL=es_ES.UTF-8 Rscript analisis/01_preparar.R
```
