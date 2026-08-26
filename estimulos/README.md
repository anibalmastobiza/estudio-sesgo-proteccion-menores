# Estímulos

## Estado

**Este repositorio no contiene ningún rostro, real ni sintético.** Lo que hay en
`docs/estimulos/placeholder/` son siluetas SVG con una etiqueta, para poder
probar que la aplicación funciona. La aplicación se niega a arrancar en variante
fotográfica mientras `manifiesto.json` declare `version: "0.0-marcadores"`.

Los estímulos son la parte del estudio con más consecuencias metodológicas y con
más restricciones legales. Se producen aparte, se normativizan aparte y se
aprueban aparte.

## Qué tiene que cumplir un estímulo

El diseño exige **conjuntos**: una misma identidad facial presentada en tres
versiones fenotípicas. La estructura del rostro, la pose, el encuadre, la
iluminación y la expresión se mantienen constantes; varían el tono de piel, la
textura del pelo y los rasgos asociados al fenotipo. Es el procedimiento de la
GAN Face Database (Marsden, Jaurique, Ess y Burke, manuscrito en preparación,
ganfd.com), que genera con StyleGAN2 y aplica mezcla de estilos para modificar
el fenotipo percibido conservando la estructura subyacente.

Sin esa estructura de conjuntos, cualquier diferencia entre condiciones podría
deberse a que unas caras concretas resultan más simpáticas, más mayores o mejor
iluminadas que otras. Con ella, el conjunto entra como factor aleatorio cruzado
y el efecto generaliza a rostros nuevos (Judd, Westfall y Kenny, 2012).

Requisitos operativos, además de los cuatro criterios normativos del
preregistro:

- Edad aparente entre 13 y 16 años.
- Expresión neutra, boca cerrada, mirada al frente.
- Fondo liso de gris fijo, idéntico en todas las imágenes.
- Sin gafas, joyas, gorras, pañuelos ni ningún marcador religioso o de clase.
- Camiseta lisa de color idéntico en todas las imágenes.
- Encuadre idéntico: distancia interpupilar y posición de los ojos constantes.
- 512 x 512 píxeles, sRGB, PNG.
- Contraste RMS dentro de ±10 % de la mediana del conjunto completo.

El tono de piel y la textura del pelo son la manipulación: **no se igualan**. Lo
que se iguala es todo lo demás. Igualar la luminancia media de la imagen
destruiría la manipulación.

## Tres rutas admisibles

### A. Base validada de rostros infantiles

La ruta más defendible ante un comité de ética, porque el material ya existe,
tiene consentimiento documentado y tiene normas publicadas. El Child Affective
Facial Expression set (LoBue y Thrasher, 2015) es diverso racialmente y de
acceso libre para investigación a través de Databrary, con la limitación de que
cubre de 2 a 8 años y no llega a la adolescencia. Cualquier base que se use debe
comprobarse contra los requisitos de arriba antes de asumir que sirve.

Coste de esta ruta: no ofrece conjuntos. Con rostros de personas distintas se
pierde el control de la estructura facial y hay que compensarlo con muchos más
estímulos y con emparejamiento estadístico posterior.

### B. Generación local con modelo abierto

`generar_caras.py` documenta el procedimiento con StyleGAN2-ADA. Requiere GPU,
pesos del modelo y decisiones que dependen del modelo concreto.
**Ese script no se ha ejecutado**, y no se puede afirmar que funcione tal cual.
Está escrito como punto de partida y como registro de las decisiones que hay que
tomar, no como herramienta terminada.

FFHQ, el conjunto con el que se entrenó StyleGAN2, contiene pocos rostros
adolescentes, de modo que la calidad en ese rango de edad es peor que en adultos
y hay que revisar cada imagen a mano.

### C. Proveedor comercial de rostros sintéticos

Rápido y con la restricción de que la mayoría de proveedores prohíbe de forma
expresa generar rostros de menores de apariencia realista. Comprobar los
términos de servicio antes de usar cualquiera. Un estudio que dependa de un
material que infringe los términos del proveedor no es publicable.

## Advertencia sobre rostros sintéticos de menores

Generar imágenes fotorrealistas de menores, aunque sean sintéticas, es una
categoría sensible en casi todas las jurisdicciones y en casi todas las
políticas de uso. Antes de generar nada:

1. Someterlo al comité de ética como punto expreso, no como detalle técnico.
2. Ejecutar el modelo en local. No subir prompts ni imágenes a servicios de
   terceros.
3. Guardar los estímulos en almacenamiento cifrado y con acceso registrado.
4. Decidir por adelantado si se publican con el artículo. Si se publican, hacerlo
   bajo licencia que prohíba el uso comercial y el reentrenamiento de modelos.
5. Documentar el modelo, la versión, las semillas y los parámetros, para que la
   generación sea reproducible sin volver a distribuir las imágenes.

## Flujo completo

```
1. Generar o seleccionar          -> muchos candidatos, sin filtrar
2. normalizar_estimulos.py        -> geometría, fondo y contraste homogéneos
3. Revisión visual del equipo     -> descartar artefactos, edades fuera de rango
4. docs/norming.html              -> ~150 jueces, una versión por identidad
5. seleccion_emparejada.R         -> aplica los cuatro criterios, elige conjuntos
6. Actualizar manifiesto.json     -> version distinta de "0.0-marcadores"
7. Enmienda al preregistro        -> lista definitiva de conjuntos, con fecha
8. Estudio principal
```

El paso 7 importa: la lista de conjuntos que entra al estudio se fija por
escrito y con fecha antes de recoger un solo dato, porque elegir estímulos
después de ver los resultados es una de las formas más eficaces de fabricar un
efecto.

## Referencias

Judd, C. M., Westfall, J. y Kenny, D. A. (2012). Treating stimuli as a random
factor in social psychology. *Journal of Personality and Social Psychology*, 103,
54-69.

LoBue, V. y Thrasher, C. (2015). The Child Affective Facial Expression (CAFE)
set. *Frontiers in Psychology*, 5, 1532.

Marsden, A., Jaurique, A., Ess, M. y Burke, S. (manuscrito en preparación). The
GAN Face Database. https://ganfd.com
