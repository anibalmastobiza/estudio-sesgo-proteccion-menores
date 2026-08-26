# Estímulos

## Estado

**Los estímulos están instalados.** 22 imágenes en `docs/estimulos/aifaces/`,
11 por fenotipo, repartidas en las cuatro casillas del diseño 2 x 2.

Proceden de **AI-Faces by Illinois** (OSF: https://osf.io/vurm5/, CC BY-NC 4.0),
una base abierta de 1.152 caras infantiles fotorrealistas generadas con IA que
varían de forma sistemática en edad aparente (3, 6, 10 y 15 años), sexo, ocho
categorías raciales y expresión, con datos normativos de jueces adultos.

`preparar_aifaces.py` reproduce toda la selección: lee el índice de los ZIP de
OSF por peticiones de rango sin descargar los 640 MB, extrae las caras de chicos
de 15 años, empareja las condiciones con la matriz normativa publicada y compone
las imágenes sobre fondo gris uniforme a 512 px.

## Qué se descartó, y por qué

### La condición magrebí no existe en el material disponible

Es la condición más pertinente para el debate español, y no se puede montar.
De las 18 caras de chicos etiquetadas como norteafricanas o de Oriente Medio,
los jueces perciben como tales solo 3. Nueve las ven blancas y cuatro latinas.
El promedio de la valoración "MENA" es 2.62 sobre 7, por debajo del 3.41 que
esas mismas caras reciben en la valoración "blanco".

En toda la base, contando las 1.152 imágenes, solo hay **cuatro** caras de chico
percibidas mayoritariamente como magrebíes con edad aparente entre 12 y 17 años,
y con valoraciones débiles.

Por eso el contraste magrebí se estudia con la variante de nombre propio
(Youssef frente a Javier), que no necesita fotografías.

### La edad percibida deja de ser hipótesis y pasa a ser control

En el conjunto completo, las caras negras de 15 años se perciben **1,2 años más
mayores** que las blancas (p = .030) y más masculinas (p < .001). El desajuste
apunta en la misma dirección que la hipótesis de adultificación de Goff y
colaboradores, de modo que usarlo sin corregir metería la conclusión dentro de
los estímulos. Tras el emparejamiento el desajuste baja a 0,27 y 0,43 años según
el estrato, y aun así la edad percibida se informa como comprobación de la
manipulación y no como contraste confirmatorio.

### El nivel "triste" puro no se puede emparejar

Las caras ceñudas son las genuinamente tristes (tristeza 4,83 sobre 7, frente a
2,84 de las enfadadas), pero solo hay cuatro por fenotipo y no admiten
emparejamiento: el mejor subconjunto deja 1,04 desviaciones típicas de
diferencia en masculinidad y realismo. Juntando ceñudas y enfadadas sí se
emparejan. La consecuencia es que el nivel negativo mezcla tristeza y enfado, y
por eso el cuestionario **pregunta de forma expresa cómo se percibe la emoción**
en lugar de darla por supuesta.

## Cómo quedó el emparejamiento

Criterio: dentro de cada nivel de expresión, ninguna variable de emoción puede
diferir entre fenotipos más de 0,25 desviaciones típicas, y ninguna del resto
más de 0,60.

| Nivel | Caras por fenotipo | Peor dif. en emoción | Peor dif. en el resto |
|---|---|---|---|
| Contento | 7 | 0,10 DT | 0,47 DT (masculinidad) |
| Afligido | 4 | 0,16 DT | 0,45 DT (masculinidad) |

La masculinidad y el realismo quedan por encima de lo deseable y entran como
covariables de nivel de imagen en la comprobación de robustez. La emoción, que
es lo que podría confundirse con el efecto de la expresión, queda ajustada.

## El diseño que soporta este material

2 x 2 entre participantes: fenotipo (no racializado, subsahariano) por expresión
(contento, afligido). Cada participante ve **una sola cara**. Las cuatro casillas
se sortean con igual probabilidad.

Las caras son identidades independientes: no existe "la misma cara con otro
fenotipo". El estímulo va por tanto **anidado** en la casilla, que es el caso
difícil de Judd, Westfall y Kenny (2012). La consecuencia práctica está en
`preregistro/potencia_resultados.txt`: con 22 caras, añadir participantes casi no
aumenta la potencia, y la interacción queda claramente infrapotenciada.

## Flujo completo

```
1. preparar_aifaces.py     -> descarga, empareja, procesa y escribe el manifiesto
2. Revisión visual         -> descartar artefactos y caras fuera de rango
3. docs/norming.html       -> normas propias con jueces españoles (recomendado)
4. Enmienda al preregistro -> lista definitiva de caras, con fecha
5. Estudio principal
```

El paso 3 no es obligatorio pero conviene: las normas de AI-Faces las dieron
jueces estadounidenses, y la percepción de "blanco" y "negro" no tiene por qué
trasladarse sin más a una muestra española. `docs/norming.html` recoge esas
normas con el mismo receptor y las escribe en una pestaña aparte.

El paso 4 importa: la lista de caras que entra al estudio se fija por escrito y
con fecha antes de recoger un solo dato, porque elegir estímulos después de ver
los resultados es una de las formas más eficaces de fabricar un efecto.

## Cita obligatoria

Las imágenes son CC BY-NC 4.0. La atribución tiene que aparecer en el artículo y
en la propia web del estudio, donde ya está en el pie:

> Las fotografías no corresponden a ninguna persona real. Proceden de AI-Faces by
> Illinois, University of Illinois, OSF vurm5, bajo licencia CC BY-NC 4.0.

La cláusula NC excluye cualquier uso comercial.

## Referencias

Judd, C. M., Westfall, J. y Kenny, D. A. (2012). Treating stimuli as a random
factor in social psychology. *Journal of Personality and Social Psychology*, 103,
54-69.

LoBue, V. y Thrasher, C. (2015). The Child Affective Facial Expression (CAFE)
set. *Frontiers in Psychology*, 5, 1532.

Marsden, A., Jaurique, A., Ess, M. y Burke, S. (manuscrito en preparación). The
GAN Face Database. https://ganfd.com
