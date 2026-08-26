# Preregistro

**Título.** Fenotipo, expresión facial y protección de menores: un experimento
de viñeta 2 x 2 sobre la respuesta institucional que se considera adecuada ante
un adolescente desatendido.

**Versión.** 2.0.0 · 26 de agosto de 2026
**Estado.** Borrador para depósito en OSF antes de recoger ningún dato.

---

## 1. Resumen

Los participantes leen la descripción de un adolescente de 14 años que entra
solo en una comisaría española y dice que sus padres lo tienen desatendido. El
texto es idéntico para todos. Lo que varía entre participantes es la fotografía
del chico, en dos factores cruzados: su fenotipo y la cara que pone. Se mide qué
procedimiento consideran adecuado, cuánto crédito dan al relato y qué sospecha
de delito le atribuyen.

Duración estimada: 3 minutos, 18 ítems.

## 2. Origen

El diseño formaliza el argumento de un hilo publicado por Luis de Velasco e Isla
el 26 de agosto de 2026 (https://x.com/VelascoIsla/status/2092536364281545192):
ante un menor que denuncia desatención, el procedimiento previsto por la Ley
Orgánica 1/1996 de Protección Jurídica del Menor es de protección, con
investigación, acogida provisional y evaluación del caso. Si la respuesta que la
gente considera adecuada varía al variar el aspecto del chico, lo que la ha
variado es el aspecto, porque el caso es el mismo.

El hilo presenta la comparación de forma secuencial y al mismo lector, de modo
que la manipulación queda a la vista y el lector puede corregirse. Ese formato
sirve como argumento y resulta inservible como medida. Aquí la comparación es
entre participantes: cada uno ve una sola cara.

## 3. Por qué la expresión entra como factor y no como ruido

Una objeción inmediata al diseño de una sola foto es que la cara del chico no es
solo su fenotipo: es también lo que transmite. Un chico con cara de disgusto
puede atraer más protección que uno sonriente, con independencia de su aspecto.
Si la expresión se dejara variar sin control, cualquier diferencia entre
fenotipos podría ser una diferencia de expresión mal atribuida.

Hay dos salidas. Una es mantener la expresión constante, que elimina la
confusión y deja la pregunta sin responder. La otra es cruzarla con el fenotipo,
que es lo que se hace aquí: el diseño 2 x 2 permite estimar por separado cuánto
pesa el fenotipo, cuánto pesa la expresión y si una cosa depende de la otra.

La interacción es la pregunta sustantiva: **¿le sirve de lo mismo poner cara de
pena a un chico blanco y a un chico negro?**

## 4. Diseño

Experimento entre participantes, 2 x 2, con estímulos anidados en cada casilla.

| | Cara contenta | Cara afligida |
|---|---|---|
| **Chico blanco** | 7 caras | 4 caras |
| **Chico negro** | 7 caras | 4 caras |

- **Asignación:** aleatoria en el navegador. Las cuatro casillas se sortean con
  igual probabilidad y la cara concreta se sortea dentro de la casilla.
- **Cada participante ve una sola fotografía.**
- **Estímulos anidados:** las caras son identidades independientes, no versiones
  fenotípicas de una misma identidad. La variación entre caras entra entera en
  el error de los contrastes (Judd, Westfall y Kenny, 2012).
- **Variante sin fotografía:** una réplica con manipulación por nombre propio
  (Javier, Youssef, Ibrahima) permite estimar el efecto de tres orígenes
  atribuidos sin estímulos visuales. Se preregistra por separado y es la única
  vía para el contraste magrebí (apartado 6.2).

## 5. Hipótesis

| | Hipótesis | Efecto | Dirección |
|---|---|---|---|
| **H1** | El fenotipo racializado reduce la protección considerada adecuada | fenotipo, sobre el índice de protección | Menor con chico negro |
| **H2** | El fenotipo racializado aumenta la preferencia por la devolución | fenotipo, sobre la decisión | Mayor con chico negro |
| **H3** | El fenotipo racializado reduce la credibilidad atribuida al relato | fenotipo, sobre credibilidad | Menor con chico negro |
| **H4** | El fenotipo racializado aumenta la sospecha de delito | fenotipo, sobre peligro | Mayor con chico negro |
| **H5** | Una cara afligida aumenta la protección considerada adecuada | expresión | Mayor con cara afligida |
| **H6** | La cara afligida ayuda menos al chico racializado | interacción | Efecto de la expresión menor en el chico negro |

H4 traslada a una decisión aplicada la asociación implícita entre rostros
infantiles racializados y estímulos amenazantes descrita por Todd, Thiem y Neel
(2016). H6 es la predicción nueva: si la expresión de sufrimiento no se
"cobra" igual según quién la ponga, el sesgo no está solo en el nivel medio de
protección sino en la capacidad de pedir ayuda.

**La adultificación queda fuera de la familia confirmatoria.** El patrón de Goff
y colaboradores (2014) predice que a los chicos negros se les atribuye más edad.
No se puede contrastar con este material: las dos muestras de caras ya difieren
en edad percibida normativa en la misma dirección (apartado 6.3). La edad
percibida se mide y se informa como comprobación, no como prueba de hipótesis.

## 6. Materiales

### 6.1 Viñeta

Idéntica en las cuatro casillas, dos frases, 45 palabras:

> Un chico de 14 años entra solo en una comisaría en España.
> Dice que no quiere volver a casa. Cuenta que sus padres lo tienen desatendido,
> que no come si no se busca la vida por su cuenta y que no le queda tiempo para
> ir al colegio.

Ni el texto ni las preguntas mencionan nacionalidad, origen, lengua o religión.
Cualquier atribución de extranjería la aporta el participante.

### 6.2 Estímulos

22 fotografías de AI-Faces by Illinois (OSF: https://osf.io/vurm5/,
CC BY-NC 4.0), chicos con edad objetivo de 15 años, sobre fondo gris uniforme a
512 px. El procedimiento completo, con lo que se descartó y por qué, está en
`estimulos/README.md`, y es reproducible con `estimulos/preparar_aifaces.py`.

**No hay condición magrebí.** De las 18 caras de chicos etiquetadas como
norteafricanas o de Oriente Medio, los jueces perciben como tales solo 3; nueve
las ven blancas. En las 1.152 imágenes de la base entera solo hay cuatro caras
de chico percibidas mayoritariamente como magrebíes con edad aparente entre 12 y
17 años. Es la condición más pertinente para el debate español y el material
abierto no la soporta. Se estudia con la variante de nombre.

**Criterio de emparejamiento aplicado.** Dentro de cada nivel de expresión,
ninguna variable de emoción difiere entre fenotipos más de 0,25 desviaciones
típicas, y ninguna del resto más de 0,60:

| Nivel | Caras por fenotipo | Peor dif. en emoción | Peor dif. en el resto |
|---|---|---|---|
| Contento | 7 | 0,10 DT | 0,47 DT (masculinidad) |
| Afligido | 4 | 0,16 DT | 0,45 DT (masculinidad) |

La masculinidad y el realismo quedan por encima de lo deseable y entran como
covariables de nivel de imagen en la comprobación de robustez del apartado 9.3.

### 6.3 Lo que el material no permite

Tres limitaciones se declaran por adelantado porque condicionan lo que se puede
concluir:

1. **Adultificación no contrastable.** En el conjunto completo las caras negras
   de 15 años se perciben 1,2 años más mayores que las blancas (p = .030). Tras
   el emparejamiento el desajuste baja a 0,27 y 0,43 años según el estrato, y
   sigue apuntando en la dirección de la hipótesis.
2. **El nivel afligido mezcla tristeza y enfado.** Las caras ceñudas son las
   genuinamente tristes pero solo hay cuatro por fenotipo y no se dejan
   emparejar. Por eso el cuestionario pregunta de forma expresa cómo se percibe
   la emoción, en vez de darla por supuesta.
3. **Normas estadounidenses.** La matriz normativa la dieron jueces de Estados
   Unidos. Se recomienda replicarla con jueces españoles antes del campo
   (`docs/norming.html`).

## 7. Variables

### 7.1 Antes de la viñeta

| Clave | Ítem | Formato |
|---|---|---|
| `emocion_percibida` | ¿Cómo se le ve? | Triste / Enfadado / Serio / Contento / Normal |
| `edad_percibida` | ¿Qué edad dirías que tiene? | 6 a 30 años |
| `origen_atribuido` | ¿De dónde dirías que es? | 7 opciones |

`emocion_percibida` es la comprobación de la manipulación de expresión, y es la
razón de que el nivel afligido pueda interpretarse aunque mezcle dos emociones:
se sabrá qué vieron los participantes en lugar de suponerlo. La edad percibida
se mide aquí porque la viñeta declara que tiene 14 años y anclaría la estimación.

### 7.2 Tras la viñeta

| Clave | Ítem | Formato |
|---|---|---|
| `decision` | ¿Qué debería hacer la policía esta misma noche? | 4 opciones, orden aleatorio |
| `proteccion` | Debe abrirse expediente de protección y pasar la noche en un centro de acogida | 0 a 100 |
| `devolucion` | Debe devolverse al chico con su familia lo antes posible | 0 a 100 |
| `credibilidad` | ¿Cuánto te crees lo que cuenta? | 0 a 100 |
| `peligro` | ¿Qué probabilidad hay de que haya cometido algún delito? | 0 a 100 |

**Variable de respuesta principal.** `indice_proteccion`, media de `proteccion`
y `100 - devolucion`. Se informará la correlación entre los dos ítems y su
Spearman-Brown. Si r < .30 se analizará `proteccion` en solitario y se hará
constar la desviación.

Las escalas se presentan sin posición inicial visible del cursor: hasta que el
participante lo mueve no aparece ningún valor ni relleno en la barra, y no puede
avanzar sin haberlo movido. Esto evita el anclaje en el punto medio.

### 7.3 Moderadores y demografía

Ideología (0 a 10), contacto intergrupal (5 puntos), amenaza percibida (0 a 100).
Edad, género, comunidad autónoma y autoadscripción como persona racializada.

### 7.4 Control de calidad

Un ítem de atención con respuesta instruida, una pregunta de sospecha abierta y
una pregunta final de seriedad (Aust, Diedenhofen, Ullrich y Musch, 2013). Se
registran latencias por pantalla y abandono por pantalla y casilla.

## 8. Procedimiento

1. Información y consentimiento.
2. Instrucciones.
3. Fotografía sola, con exposición mínima de 3 segundos, y tres preguntas.
4. Viñeta con la misma fotografía y cinco preguntas de decisión.
5. Control de atención.
6. Moderadores.
7. Demografía.
8. Sospecha y seriedad.
9. Debriefing completo con opción de retirada de datos.

## 9. Plan de análisis

Todo el análisis se ejecuta con los scripts de `analisis/`, escritos y probados
sobre datos simulados antes de abrir el campo.

### 9.1 Modelo principal

```
indice_proteccion ~ fenotipo * expresion + (1 | cara)
```

Estimación por máxima verosimilitud restringida, grados de libertad de
Satterthwaite. El intercepto aleatorio por cara es obligatorio: cada cara
pertenece a una sola casilla, de modo que la variación entre caras entra entera
en el error de los contrastes. Sin él, la comparación se haría contra la
variación entre participantes, que es mucho menor.

H2 mediante regresión logística mixta sobre `decision == "devolucion"` con la
misma estructura. H3 y H4 con el mismo modelo lineal sobre `credibilidad` y
`peligro`.

### 9.2 Multiplicidad

Corrección de Holm **dentro de cada familia de efectos** (fenotipo, expresión,
interacción), no sobre las doce pruebas juntas: los tres efectos responden a
preguntas distintas y no se corrigen unos por otros.

### 9.3 Comprobaciones de robustez preregistradas

1. **Permutación entre caras**, 10 000 remuestreos, barajando la etiqueta de
   fenotipo entre caras dentro de cada nivel de expresión. La unidad de análisis
   es la cara. Reproduce exactamente la aleatoriedad que el diseño no tiene: las
   caras no fueron asignadas al azar a su fenotipo.
2. **Covariables de imagen.** Reajuste con las medias normativas de masculinidad
   y realismo de cada cara, que son las que quedan peor emparejadas.
3. **Sin exclusiones.** El análisis principal se repite sin los criterios 3 a 6
   del apartado 10.

### 9.4 Comprobaciones de la manipulación

- `emocion_percibida` por nivel de expresión, y su independencia del fenotipo
  dentro de cada nivel. Si la emoción percibida difiere entre fenotipos dentro de
  un mismo nivel, la interacción deja de ser interpretable y se declara así.
- `origen_atribuido` por fenotipo.
- Equilibrio de las cuatro casillas.

### 9.5 Exploratorio

Moderación del efecto de fenotipo por ideología, contacto y amenaza percibida.
Extranjería atribuida por casilla. Edad percibida. Todo marcado como
exploratorio en el informe.

### 9.6 Datos ausentes

La aplicación exige respuesta en todos los ítems salvo `sospecha`, de modo que
solo hay ausencia por abandono. Los abandonos se analizan como resultado: tasa
por casilla y pantalla, contrastada con chi cuadrado. Un abandono diferencial
sería en sí mismo un hallazgo y obligaría a acompañar el análisis principal con
límites de Manski.

## 10. Criterios de exclusión

Se decide antes de mirar ninguna variable de respuesta:

1. Sin consentimiento o menor de 18 años.
2. Cuestionario incompleto.
3. Fallo en el ítem de atención.
4. Duración total inferior a 60 segundos o superior a 60 minutos.
5. Declara en la pregunta de seriedad que no se deben usar sus respuestas.
6. Solicita la retirada de sus datos en el debriefing.
7. Identifica correctamente la manipulación en la pregunta de sospecha, según
   codificación ciega a la casilla realizada por dos codificadores
   independientes, informando el acuerdo entre ellos.

## 11. Potencia

Simulación con 500 réplicas por escenario, código en `preregistro/potencia.R`,
salida completa en `preregistro/potencia_resultados.txt`. Semilla 20260826,
R 4.3.2, lme4 1.1.36.

El error de tipo I del modelo está bien controlado en los tres efectos, entre
.028 y .068 según el escenario, lo que valida la especificación del efecto
aleatorio por cara.

### 11.1 Potencia con el material real

Con 7 caras contentas y 4 afligidas por fenotipo, efectos verdaderos de d = 0.30
en fenotipo, d = 0.40 en expresión y d = 0.20 en la interacción. `tau` es la
desviación típica del efecto propio de cada cara:

| Participantes | Fenotipo | Expresión | Interacción |
|---|---|---|---|
| **tau = 0.10** | | | |
| 600 | .638 | .830 | .156 |
| 900 | .734 | .912 | .226 |
| 1200 | .832 | .962 | .250 |
| 2000 | .910 | .980 | .312 |
| **tau = 0.20** | | | |
| 600 | .432 | .544 | .144 |
| 900 | .472 | .666 | .128 |
| 1200 | .550 | .718 | .166 |
| 2000 | .620 | .740 | .178 |

### 11.2 El límite lo pone el número de caras

Con 900 participantes y tau = 0.20, variando el número de caras por casilla:

| Caras por casilla | Fenotipo | Interacción |
|---|---|---|
| 4 | .362 | .118 |
| 7 | .526 | .166 |
| 12 | .618 | .210 |
| 20 | .726 | .220 |
| 30 | .780 | .262 |

Con estímulos anidados, la variación entre caras es un componente irreducible
del error: añadir participantes reduce el error de muestreo dentro de cada cara
y no toca esa componente. Duplicar la muestra de 600 a 1200 sube la potencia del
efecto de fenotipo de .43 a .55; triplicar el material de 7 a 20 caras la sube de
.53 a .73 sin tocar la muestra.

### 11.3 Lo que esto obliga a declarar por adelantado

**La interacción no está potenciada para efectos pequeños.** Con el material
disponible, una interacción de d = 0.20 se detectaría entre el 13 % y el 31 % de
las veces. Un resultado no significativo en H6 **no será evidencia de ausencia
de interacción**, y así se informará: se dará el intervalo de confianza y se
dirá qué tamaños quedan descartados y cuáles no.

El efecto de expresión es el mejor potenciado, el de fenotipo queda en un rango
aceptable en el escenario optimista y justo en el pesimista.

### 11.4 Decisión

**N = 900 participantes válidos**, 225 por casilla. Con una retención esperada
del 88 al 92 %, hay que contratar entre 980 y 1030 cuestionarios completos.

Subir la muestra por encima de ahí rinde poco mientras el material siga siendo
de 22 caras. La vía para mejorar el estudio es generar más estímulos
emparejados, no reclutar más gente. Con 20 caras por casilla en lugar de 7, el
efecto de fenotipo pasaría de .53 a .73 con la misma muestra.

## 12. Detención de la recogida

Se detiene al alcanzar 900 casos válidos o en la fecha acordada con el proveedor
del panel, lo que ocurra antes. No se analiza ninguna variable de respuesta
antes de cerrar el campo. Las comprobaciones durante la recogida se limitan a
número de casos, tasa de abandono y reparto por casilla.

## 13. Desviaciones previsibles

Se informará cualquier desviación en un apartado propio del artículo. Las
previsibles: fallo de convergencia del modelo principal, correlación
insuficiente entre los dos ítems del índice de protección, y que la emoción
percibida resulte depender del fenotipo dentro de un mismo nivel de expresión.

## 14. Ética

Pendiente de aprobación por el comité de ética. El estudio implica ocultación
parcial del objetivo, imprescindible porque informar de la comparación anularía
la medida. Se compensa con debriefing completo y derecho de retirada posterior.
Documentación en `etica/`.

Las fotografías no corresponden a ninguna persona real. La atribución CC BY-NC
aparece en el pie de la aplicación y debe aparecer en el artículo.

El estudio no evalúa a ningún participante individualmente ni le devuelve
puntuación alguna. El debriefing lo dice de forma expresa.

## 15. Disponibilidad

Materiales, código de la aplicación, código de análisis y datos anonimizados en
el repositorio, bajo MIT el código y CC BY 4.0 los materiales. Los estímulos no
se redistribuyen: `preparar_aifaces.py` los reconstruye desde OSF.

## 16. Referencias

Aust, F., Diedenhofen, B., Ullrich, S. y Musch, J. (2013). Seriousness checks are
useful to improve data validity in online research. *Behavior Research Methods*,
45, 527-535.

Goff, P. A., Jackson, M. C., Di Leone, B. A. L., Culotta, C. M. y DiTomasso,
N. A. (2014). The essence of innocence: Consequences of dehumanizing Black
children. *Journal of Personality and Social Psychology*, 106, 526-545.

Judd, C. M., Westfall, J. y Kenny, D. A. (2012). Treating stimuli as a random
factor in social psychology: A new and comprehensive solution to a pervasive but
largely ignored problem. *Journal of Personality and Social Psychology*, 103,
54-69.

Todd, A. R., Thiem, K. C. y Neel, R. (2016). Does seeing faces of young Black
boys facilitate the identification of threatening stimuli? *Psychological
Science*, 27, 384-393.

AI-Faces by Illinois. University of Illinois. OSF: https://osf.io/vurm5/
Licencia CC BY-NC 4.0.
