# Sesgo racial en decisiones de protección de menores: un experimento de viñeta

Experimento en línea, en castellano, sobre si el fenotipo percibido de un adolescente
altera la decisión de protección que la ciudadanía considera adecuada cuando el relato
del caso es **idéntico**.

El diseño operacionaliza el argumento de un hilo público de Luis de Velasco e Isla
([@VelascoIsla](https://x.com/VelascoIsla/status/2092536364281545192), 26 de agosto de 2026):
ante un chico de 14 años que entra en una comisaría diciendo que está desatendido en casa,
el procedimiento esperable es el de protección (servicios sociales, evaluación, acogida).
Si la respuesta cambia al cambiar la foto del chico, lo que la ha cambiado es la cara,
porque el caso es el mismo.

El hilo plantea la comparación en el mismo lector y de forma secuencial, lo que hace la
manipulación transparente. Aquí se convierte en un contraste **entre sujetos** (cada
participante ve una sola cara), que es lo que permite estimar el efecto sin que la
demanda experimental lo contamine. La comparación secuencial del hilo se conserva
después, como bloque secundario.

**Aplicación desplegada:** https://anibalmastobiza.github.io/estudio-sesgo-proteccion-menores/

Mientras `ENDPOINT` esté vacío en `docs/js/config.js`, la página avisa de que es
una versión de prueba y no registra nada. Ese aviso desaparece solo en cuanto se
conecta la hoja de cálculo.

## Qué hay en este repositorio

| Carpeta | Contenido |
|---|---|
| `docs/` | El experimento (HTML/CSS/JS sin dependencias), publicable en GitHub Pages |
| `docs/norming.html` | Estudio normativo previo de los estímulos |
| `apps-script/` | Receptor en Google Apps Script que vuelca las respuestas en Google Sheets |
| `preregistro/` | Preregistro, hipótesis, plan de análisis y simulación de potencia |
| `estimulos/` | Pipeline de generación de caras, protocolo normativo y selección emparejada |
| `analisis/` | Scripts de R: simulación, preparación, modelos confirmatorios y figuras |
| `etica/` | Hoja de información, consentimiento, debriefing y protección de datos |

## Puesta en marcha

1. **Google Sheets**: sigue [`apps-script/INSTALACION.md`](apps-script/INSTALACION.md) (5 minutos)
   y pega la URL del Web App en `docs/js/config.js`.
2. **Estímulos**: lee [`estimulos/README.md`](estimulos/README.md). El repositorio se
   distribuye con marcadores de posición: **no contiene caras reales ni sintéticas**.
   Sustituye los archivos siguiendo `docs/estimulos/manifiesto.json`.
3. **Norming**: ejecuta `docs/norming.html` con ~150 participantes antes del estudio principal
   y selecciona los conjuntos emparejados con `estimulos/seleccion_emparejada.R`.
4. **Publicación**: activa GitHub Pages sobre la carpeta `/docs` de la rama principal.
5. **Análisis**: `analisis/00_simular_datos.R` permite validar todo el pipeline antes de
   recoger un solo dato real.

## Estado

Ejecutado y comprobado:

- Aplicación web recorrida de principio a fin en las dos variantes, con registro
  completo de las 60 variables por participante.
- Simulación de potencia con 500 réplicas por escenario
  (`preregistro/potencia_resultados.txt`). El resultado que gobierna el diseño:
  con 6 conjuntos de estímulo y variabilidad alta entre rostros, la potencia se
  estanca en .69 por muchos participantes que se añadan, y con 12 conjuntos sube
  a .93. Ignorar la variabilidad entre estímulos eleva el error de tipo I de .05
  a .17.
- Pipeline de análisis completo sobre datos simulados: recupera los cinco
  efectos inyectados con el signo y la magnitud correctos, y produce las cuatro
  figuras.
- Selección de estímulos probada con datos normativos simulados, incluido el
  diagnóstico de precisión que exige subir a 60 jueces por imagen.

Escrito y no ejecutado:

- `estimulos/generar_caras.py`. Requiere GPU y pesos de StyleGAN2. Está
  documentado como punto de partida.
- Receptor de Google Apps Script. La sintaxis está comprobada; el despliegue
  depende de una cuenta de Google y hay que hacerlo a mano siguiendo
  `apps-script/INSTALACION.md`.

Pendiente:

- **Estímulos.** El repositorio no contiene ninguna cara. Sin ellos el estudio
  corre en variante `nombre` (manipulación por nombre propio), que es la
  configuración por defecto.
- **Aprobación del comité de ética.** Obligatoria antes de recoger datos.
- Rellenar los campos entre corchetes de `etica/`.

## Licencia

Código: MIT. Materiales (viñeta, ítems, documentación): CC BY 4.0.
