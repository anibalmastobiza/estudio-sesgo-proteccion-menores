# Fenotipo, expresión facial y protección de menores

Experimento en línea, en castellano, sobre si el aspecto de un adolescente y la
cara que pone cambian la protección que la ciudadanía considera adecuada cuando
el relato del caso es **idéntico**.

**Aplicación desplegada:** https://anibalmastobiza.github.io/estudio-sesgo-proteccion-menores/

El diseño operacionaliza el argumento de un hilo público de Luis de Velasco e
Isla ([@VelascoIsla](https://x.com/VelascoIsla/status/2092536364281545192),
26 de agosto de 2026): ante un chico de 14 años que entra en una comisaría
diciendo que está desatendido en casa, el procedimiento esperable es el de
protección. Si la respuesta cambia al cambiar la foto, lo que la ha cambiado es
la foto, porque el caso es el mismo.

## El diseño

2 x 2 entre participantes, 18 ítems, unos 3 minutos.

| | Cara contenta | Cara afligida |
|---|---|---|
| **Chico blanco** | 7 caras | 4 caras |
| **Chico negro** | 7 caras | 4 caras |

Cada participante ve **una sola fotografía** y responde al mismo caso. Cruzar la
expresión con el fenotipo permite separar tres cosas que suelen ir mezcladas:
cuánto pesa el aspecto del chico, cuánto pesa la cara que pone, y si una cosa
depende de la otra. Esa última es la pregunta nueva: **¿le sirve de lo mismo
poner cara de pena a un chico blanco y a un chico negro?**

## Los estímulos

22 fotografías de **AI-Faces by Illinois** (OSF: https://osf.io/vurm5/,
CC BY-NC 4.0), una base abierta de caras infantiles fotorrealistas generadas con
IA, con datos normativos de jueces adultos. No corresponden a ninguna persona
real.

`estimulos/preparar_aifaces.py` reproduce toda la selección: descarga por
peticiones de rango sin bajar los 640 MB de los ZIP, empareja las condiciones
con la matriz normativa y compone las imágenes sobre fondo gris uniforme.

Dos cosas que el material **no** permite, documentadas en
[`estimulos/README.md`](estimulos/README.md):

- **No hay condición magrebí.** De las 18 caras de chicos etiquetadas como
  norteafricanas, los jueces perciben como tales solo 3; nueve las ven blancas.
  Es la condición más pertinente para el debate español. Se estudia con la
  variante de nombre propio (Youssef frente a Javier), que no necesita fotos.
- **La adultificación no se puede contrastar.** Las caras negras de 15 años se
  perciben 1,2 años más mayores que las blancas antes de emparejar, en la misma
  dirección que la hipótesis. La edad percibida se mide como control, no como
  prueba.

## Qué hay en este repositorio

| Carpeta | Contenido |
|---|---|
| `docs/` | El experimento (HTML/CSS/JS sin dependencias), publicado en GitHub Pages |
| `docs/norming.html` | Estudio normativo de los estímulos con jueces españoles |
| `apps-script/` | Receptor en Google Apps Script que vuelca las respuestas en Google Sheets |
| `preregistro/` | Preregistro, hipótesis, plan de análisis y simulación de potencia |
| `estimulos/` | Descarga, emparejamiento y procesamiento de los estímulos |
| `analisis/` | Scripts de R: simulación, preparación, modelos y figuras |
| `etica/` | Hoja de información, consentimiento, debriefing y protección de datos |

## Puesta en marcha

1. **Google Sheets**: sigue [`apps-script/INSTALACION.md`](apps-script/INSTALACION.md).
   La hoja "Estudio menores - respuestas" ya está creada en tu Drive con las 56
   columnas. Falta pegar el receptor, desplegar el Web App y poner su URL en
   `docs/js/config.js`. Verifica la conexión con
   `bash apps-script/verificar.sh "URL"`.
2. **Análisis**: `Rscript analisis/00_simular_datos.R` y los tres siguientes
   validan todo el pipeline antes de recoger un solo dato real.
3. Mientras `ENDPOINT` esté vacío, la portada avisa de que es una versión de
   prueba y no registra nada. El aviso desaparece solo al conectar la hoja.

## Estado

Ejecutado y comprobado:

- Aplicación recorrida de principio a fin, con reparto equilibrado de las cuatro
  casillas verificado sobre 8.000 asignaciones simuladas.
- Estímulos instalados y emparejados. Dentro de cada nivel de expresión, ninguna
  variable de emoción difiere entre fenotipos más de 0,16 desviaciones típicas.
- Simulación de potencia con 500 réplicas por escenario. Error de tipo I entre
  .028 y .068. **La interacción está infrapotenciada** y así se declara en el
  preregistro.
- Pipeline de análisis completo sobre datos simulados: recupera los efectos
  inyectados de fenotipo y expresión, y no recupera el de interacción, que es
  justo lo que la simulación de potencia predice.

Pendiente:

- **Despliegue del Web App de Apps Script.** Exige aceptar permisos en la cuenta
  de Google de forma interactiva.
- **Aprobación del comité de ética.**
- Rellenar los campos entre corchetes de `etica/`.

## Licencia

Código: MIT. Materiales (viñeta, ítems, documentación): CC BY 4.0.
